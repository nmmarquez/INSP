rm(list=ls()) # remove everything from the workspace
set.seed(123)
pacman::p_load(INSP, data.table)

# pull the data files from drop box
home_dir <- "ANALÍSIS SIC-MIDO/"
muni_file_path <- paste0(home_dir, "1 BASES DE DATOS/matriz_muni.dta")
hta_file_path <- paste0(home_dir, "1 BASES DE DATOS/HTA Ensanut 2012.dta")

# load in data sets from the temp files
muni_df <- read_drop_dta(muni_file_path)
hta_data <- read_drop_dta(hta_file_path)

# get the age cat variables to be the same
hta_data$edad_cat2 <- hta_data$edad_cat / 5 - 3

# see the models inputs
pred_vars <- c("edad_cat2", "sexo")
res_var <- "ht_con_dxprevio"
table(hta_data$ht_con_dxprevio)

get_demog <- name <- function(age, sex, muni, value="pop"){
    row_df <- subset(muni_df, muni == nmuni)
    if(value == "pop"){
        return(row_df[1,"pop"])
    }
    sexo <- ifelse(sex == "mujer", "mujeres", "hombres")
    return(row_df[1,paste0("p_edad", age)] * row_df[1,paste0("p_", sexo)])
}

for(var_ in pred_vars){
    hta_data[,var_] <- as.factor(hta_data[,var_])
    print(table(hta_data[,var_]))
}

# run the model as per specified and Ale's code
model_form <- as.formula(paste(res_var, paste(pred_vars, collapse="*"), sep="~"))
lm1 <- glm(model_form, data=hta_data, family="binomial")
summary(lm1)

# now we need to predict at the municipal level
# municipal sex-age is the same the only difference is the percentage of 
# individuals in each group
unique_vars <- c(lapply(pred_vars, function(x) unique(na.omit(hta_data[,x]))),
                 list("muni"=unique(muni_df$nmuni)))
names(unique_vars)[1:length(pred_vars)] <- pred_vars 
df_predict <- expand.grid(unique_vars)
df_predict$y_hat <- rje::expit(predict(lm1, newdata=df_predict))
df_predict$pop_total <- apply(df_predict, 1, function(y) 
    get_demog(y['edad_cat2'], y['sexo'], y['muni']))
df_predict$pop_perc <- apply(df_predict, 1, function(y) 
    get_demog(y['edad_cat2'], y['sexo'], y['muni'], value="percent"))
df_predict$pop_specific <- df_predict$pop_perc * df_predict$pop_total
df_predict$pop_affl <- df_predict$pop_specific * df_predict$y_hat
df_predict$prevelance <- df_predict$pop_affl / df_predict$pop_specific

df_predict <- as.data.table(df_predict)
df_predict$edad_cat2 <- as.character(df_predict$edad_cat2)
df_predict$sexo <- as.character(df_predict$sexo)

# now we need to aggregate by sex, age then both
df_sex <- copy(df_predict)
df_sex[,pop_specific:=sum(pop_specific),by=list(sexo, muni)]
df_sex[,pop_affl:=sum(pop_affl),by=list(sexo, muni)]
df_sex[,prevelance:= pop_affl / pop_specific]
df_sex <- unique(df_sex, by=c("sexo", "muni"))
df_sex[,edad_cat2:= "0"] 
df_sex


df_age <- copy(df_predict)
df_age[,pop_specific:=sum(pop_specific),by=list(edad_cat2, muni)]
df_age[,pop_affl:=sum(pop_affl),by=list(edad_cat2, muni)]
df_age[,prevelance:= pop_affl / pop_specific]
df_age <- unique(df_age, by=c("edad_cat2", "muni"))
df_age[,sexo:= "juntos"]

df_global <- copy(df_predict)
df_global[,pop_specific:=sum(pop_specific),by=list(muni)]
df_global[,pop_affl:=sum(pop_affl),by=list(muni)]
df_global[,prevelance:= pop_affl / pop_specific]
df_global <- unique(df_global, by=c("muni"))
df_global[,sexo:= "juntos"]
df_global[,edad_cat2:= "0"] 

df_todo <- rbindlist(list(df_predict, df_age, df_sex, df_global))

# write the file in a relative file path using this files location
write_home <- paste0(dirname(sys.frame(1)$ofile), "/hta_visual/models/")

if(!dir.exists(write_home)){
    dir.create(write_home)
}

fwrite(df_todo, file=paste0(write_home, "simple_model_data.csv"))
