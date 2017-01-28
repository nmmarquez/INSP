# Simulate data at the municipality level and then sample from teh state level
# to get state level prevelance.

rm(list=ls())
set.seed(123)
pacman::p_load(data.table, sp, rgeos, leaflet, surveillance, rgdal)

setwd("~/Documents/INSP/hta_analysis/hta_visual/shape_files/")
df <- readOGR("./")

# first we want to simulate the pop in each location
df$N <- sample(120:120000, nrow(df@data), replace=T)

# now the number of total death
df@data$D <- round(runif(nrow(df@data), .15, .20) * df@data$N)

# and number of HT related deaths
df@data$Dht <- round(runif(nrow(df@data), .05, .40) * df@data$D)

# now we need a model creating a link between the number of deaths in an area
# and the prevelance of HT obviously the pathology of HT doesnt operate this 
# way but we are using this as an imperfect proxy

B0 <- -.2
B1 <- 1.8
eps.sigma <- .1
RR <- exp(B0 + B1 * (df$Dht / df$D) + rnorm(nrow(df@data), 0, eps.sigma))
summary(RR)

