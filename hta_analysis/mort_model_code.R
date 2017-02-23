rm(list=ls())
pacman::p_load(data.table, INLA, readstata13, surveillance, dplyr, dtplyr)

DT <- fread("~/Desktop/mort_munrh_dm_1998_2015.csv")
DT[,ENT:=sapply(strsplit(location_id, "_"), function(x) sprintf("%02d", as.integer(x[1])))]
DT[,MUN:=sapply(strsplit(location_id, "_"), function(x) sprintf("%03d", as.integer(x[2])))]
DT[,GEOID:=paste0(ENT, MUN)]

DTsub <- subset(DT, MUN != "000" & sexo == "Female" & age_group_id %in% 9:20 & 
                    !is.na(MUN) & !is.na(ENT) & ENT != "999" & year == 2015)
sort(unique(DTsub$age_group_id))
sort(unique(DTsub$ENT))
sort(unique(DTsub$MUN))

DTpop <- as.data.table(read.dta13("~/Desktop/base_Intercensal_poptot_mujeres.dta"))
DTpop[,age_group_id:=edad_q + 4]
DTpop[,GEOID:=as.character(cod_mun)]
unique(DTpop$age_group_id)
DTpopsub <- subset(DTpop, age_group_id %in% 9:20, select=c(age_group_id, GEOID, pop_tot))

DTdb <- merge(DTsub, DTpopsub, by=c("GEOID", "age_group_id"))

summary(DTdb$ind <= DTdb$pop_tot)

modelo1 <- glm(ind ~ as.factor(age_group_id) + offset(log(pop_tot)), data=DTdb, 
               family=poisson)
summary(modelo1)

modelo2 <- inla(ind ~ as.factor(age_group_id) + f(age_group_id,model="ar1"),
                data=DTdb, family="poisson", E=pop_tot)
summary(modelo2)

load("~/Documents/INSP/data/mx.sp.df.rda")
plot(mx.sp.df)
graph <- poly2adjmat(mx.sp.df)
graph[1:10, 1:10]
mx.sp.df@data$N <- 1:nrow(mx.sp.df@data)
head(mx.sp.df@data)

DTdb1 <- left_join(DTdb, as.data.table(mx.sp.df@data[,c("GEOID", "N")]))


modelo3 <- inla(ind ~ as.factor(age_group_id) + f(age_group_id,model="ar1") +
                    f(N, model="besag", graph=graph), 
                data=subset(DTdb1, GEOID != "23010"), family="poisson", 
                E=pop_tot, control.predictor = list(link = 1))

summary(modelo3)
plot(modelo3$summary.fitted.values$mean * subset(DTdb1, GEOID != "23010")$pop_tot, 
     subset(DTdb1, GEOID != "23010")$ind)
