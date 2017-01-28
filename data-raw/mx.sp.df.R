library(rdrop2)
library(sp)
library(rgdal)
library(rgeos)
library(surveillance)
library(INSP)

token <- load_token()
shape_files <- drop_dir("Mapas/Municipios", dtoken=token)$path
shape_files <- grep("Municipios\\.", shape_files, value=TRUE)
tdir <- tempdir()
for(f in shape_files){
    f_split <- strsplit(f, "/")[[1]]
    f_ <- paste(tdir, f_split[length(f_split)], sep="/")
    drop_get(f, f_, dtoken=token)
}

df <- readOGR(tdir)
unlink(tdir)
# translate to desired proj4 string
p4s <- "+title=WGS 84 (long/lat) +proj=longlat +ellps=WGS84 +datum=WGS84"
df2 <- spTransform(gSimplify(df, 25), CRS(p4s))
df2 <- SpatialPolygonsDataFrame(df2, df@data)
df2@data$muni <- paste(df2$CVE_ENT, df2$CVE_MUN, sep="")
df2@data$muni <- as.integer(df2@data$muni)
mx.sp.df <- df2
devtools::use_data(mx.sp.df)

