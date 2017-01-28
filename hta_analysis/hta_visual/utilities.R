rm(list=ls())
pacman::p_load(sp, data.table, rgdal, maptools, leaflet, surveillance, spdep, 
               ggplot2, rgeos, dplyr, rdrop2, INSP)

models <- list.files("./models/", full.names=TRUE)
names(models) <- gsub(".csv", "", list.files("./models/"))

hist_plot <- function(df){
    ggplot(df@data, aes(x=data)) + geom_histogram(fill="seagreen") + 
        xlab("County Simulation Values") + ylab("Count")
}

data_map <- function(age, sex, model){
    model <- models[model]
    DF <- fread("./models/age_sex_model.csv")
    df <- subset(DF, edad_cat2 == age & sexo == sex)
    map_df <- mx.sp.df
    map_df@data <- left_join(map_df@data, df)
    map_df@data$data <- map_df@data$prevelance
    map_df
}