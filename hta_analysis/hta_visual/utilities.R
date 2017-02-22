rm(list=ls())

library(sp)
library(data.table)
library(rgdal)
library(maptools)
library(leaflet)
library(spdep)
library(ggplot2)
library(rgeos)
library(dplyr)
library(rdrop2)
library(plotly)
library(INSP)

DF <- fread("./models/models_limpia.csv")
DF[,GEOID:=sprintf("%05d", GEOID)]

hist_plot <- function(df){
    ggplot(df@data, aes(x=data)) + geom_histogram(fill="seagreen") + 
        xlab("County Simulation Values") + ylab("Count")
}

data_map <- function(age, sex, model){
    df <- subset(DF, edad == age & sexo == sex & model_name==model)
    map_df <- mx.sp.df
    map_df@data <- left_join(map_df@data, df)
    map_df@data$data <- map_df@data$prevalencia_cor
    map_df
}

contra_ENS <- function(df){
    df <- df@data
    df <- subset(df, select=c(prev_ent_cor, prev_ENS, ent_num))
    df <- unique(df)
    corv <- stats::cor(df$prev_ent_cor, df$prev_ENS)
    gg1 <- ggplot(data=df, aes(x=prev_ENS, y=prev_ent_cor, label=ent_num)) + 
        geom_point() + labs(title=paste0("Corr: ", corv)) + 
        geom_abline()
    ggplotly(gg1)
}

spdf2leafnuevo <- function(df){
    popup <- paste0("Loc Name: ", df@data$NOM_MUN, "<br> Prevalencia: ", 
                    round(df@data$prevalencia_cor, 3),
                    "(",round(df@data$`_ci_lb`,3), "-", round(df@data$`_ci_ub`,3), ")",   
                    "<br> Poblacion: ", 
                    df@data$pop)
    pal <- colorNumeric(palette = "YlGnBu", domain = df@data$prevalencia_cor)
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(prevalencia_cor), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomright", pal = pal, values = df$prevalencia_cor, 
                  title = "Prevalencia", opacity = 1)
    map1
}