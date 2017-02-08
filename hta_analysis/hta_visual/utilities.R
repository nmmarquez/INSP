rm(list=ls())
pacman::p_load(sp, data.table, rgdal, maptools, leaflet, spdep, 
               ggplot2, rgeos, dplyr, rdrop2, INSP)

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