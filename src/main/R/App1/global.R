
library(data.table)
library(dplyr)
library(leaflet)

dat <- fread("data/route.csv")

dat.aug <- dat[, {
  data.table(lat=lat + rnorm(10) / 10000, 
             lon=lon + rnorm(10) / 10000)
}, by = 1:nrow(dat)]