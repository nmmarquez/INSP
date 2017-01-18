rm(list=ls())
library(sp)
library(data.table)
library(rgdal)
library(maptools)
library(leaflet)
library(surveillance)
library(spdep)
library(MASS)
library(sparseMVN)
library(Matrix)
library(ggplot2)
library(readstata13)

DF <- fread("./prev_data.csv")

# pull the shape file into mem
read_map_data <- function(){
    df <- readOGR("/home/nmarquez/Downloads/Mapas/Municipios/")
    
    # translate to desired proj4 string
    p4s <- "+title=WGS 84 (long/lat) +proj=longlat +ellps=WGS84 +datum=WGS84"
    df2 <- spTransform(rgeos::gSimplify(df, 250), CRS(p4s))
    df2 <- SpatialPolygonsDataFrame(df2, df@data)
    df2@data$muni <- paste(df2$CVE_ENT, df2$CVE_MUN, sep="")
    df2@data$muni <- as.integer(df2@data$muni)
    df2
}

MAP_DF <- read_map_data()

hist_plot <- function(df){
    ggplot(df@data, aes(x=data)) + geom_histogram(fill="seagreen") + 
        xlab("County Simulation Values") + ylab("Count")
}

data_map <- function(age, sex){
    df <- subset(DF, edad_cat2 == age & sexo == sex)
    map_df <- MAP_DF
    map_df@data <- dplyr::left_join(map_df@data, df)
    map_df@data$data <- map_df@data$prevelance
    map_df
}

leaf_map <- function(df){
    # pop up info
    popup <- paste0("County Name: ", df@data$NOM_MUN, 
                    "<br> Value: ", df@data$data)
    
    # color palette
    pal <- colorNumeric(palette="YlGnBu", domain=df@data$data)
    
    # see map
    map1<-leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        addPolygons(data=df, fillColor=~pal(data), color="#b2aeae", weight=0.3,
                    fillOpacity=0.7, smoothFactor=0.2, popup=popup) %>%
        addLegend("bottomright", pal=pal, values=df$data,
                  title = "Prevelencia", opacity = 1)
    map1
}