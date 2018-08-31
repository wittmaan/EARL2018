
source("TileCreator.R")

library(data.table)
dat <- fread("../../test/resources/route.csv")

dat[, id := .I]
dat.aug <- dat[, cbind(zoom=6:22, .SD), by = id]

dat.aug[, c("x", "y") := TileCreator$private_methods$calcTile(zoom, lat, lon), by = .(zoom)]

# Render Tiles for zoom-levels ranging from 6 to 22
for (z in 6:22) {
  tmp <- dat.aug[zoom == z, .(round(x), round(y))] %>% unique()
  for (i in 1:nrow(tmp)) {
    tileCreator$renderTile(z, tmp[i]$V1, tmp[i]$V2)
  }  
}

