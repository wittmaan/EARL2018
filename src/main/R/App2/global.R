
library(data.table)
library(dplyr)
library(leaflet)

Sys.setenv(no_proxy="*")


## see geosphere::mercator
calcTile = function(zoom, lat, lon) {
  latRad <- pi/180 * lat
  n <- 2^zoom
  xTile <- n * ((lon + 180) / 360)
  yTile <- n * (1 - (log(tan(latRad) + 1 / cos(latRad)) / pi)) / 2
  return(data.table(x=xTile, y=yTile))
}
