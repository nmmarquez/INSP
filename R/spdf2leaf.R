#' render a spatial data frame in leaflet
#'
#' @description Takes a spatial data frame and turns it into an interactive 
#' leaflet instance.
#'
#' @return leaflet object
#' 
#' @export

spdf2leaf <- function(df, col="data", label=NULL){
    library(sp)
    library(leaflet)
    df@data$data <- df@data[,col]
    lab_label <- ifelse(is.null(label), col, label)
    
    # pop up info
    popup <- paste0("Loc Name: ", df@data$NOM_MUN, 
                    "<br> Value: ", df@data$data)
    
    # color palette
    pal <- colorNumeric(palette="YlGnBu", domain=df@data$data)
    
    # see map
    map1<-leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        addPolygons(data=df, fillColor=~pal(data), color="#b2aeae", weight=0.3,
                    fillOpacity=0.7, smoothFactor=0.2, popup=popup) %>%
        addLegend("bottomright", pal=pal, values=df$data,
                  title = lab_label, opacity = 1)
    map1
}