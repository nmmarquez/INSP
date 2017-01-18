rm(list=ls())
pacman::p_load(sp, data.table, rgdal, maptools, leaflet, surveillance, spdep, 
               ggplot2, rgeos, dplyr, rdrop2)
source("../../libraries/utils.R")

models <- list.files("./models/", full.names=TRUE)
names(models) <- gsub(".csv", "", list.files("./models/"))

# pull the shape file into mem
read_map_data <- function(){
    home <- "./shape_files/"
    if(!dir.exists(home)){
        dir.create(home)
        token <- load_token()
        shape_files <- drop_dir("Mapas/Municipios", dtoken=token)$path
        shape_files <- grep("Municipios\\.", shape_files, value=TRUE)
        for(f in shape_files){
            f_split <- strsplit(f, "/")[[1]]
            f_ <- paste0(home, f_split[length(f_split)])
            drop_get(f, f_)
        }
    }
    df <- readOGR(home)
    
    # translate to desired proj4 string
    p4s <- "+title=WGS 84 (long/lat) +proj=longlat +ellps=WGS84 +datum=WGS84"
    df2 <- spTransform(gSimplify(df, 25), CRS(p4s))
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

data_map <- function(age, sex, model){
    model <- models[model]
    DF <- fread("./models/age_sex_model.csv")
    df <- subset(DF, edad_cat2 == age & sexo == sex)
    map_df <- MAP_DF
    map_df@data <- left_join(map_df@data, df)
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