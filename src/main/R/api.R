
source("TileCreator.R")

#' @get /render/<z>/<x_from>/<x_to>/<y_from>/<y_to>
render <- function(z, x_from, x_to, y_from, y_to) {
  #cat(paste0("rendering tile zoom=", z, ", x_from=", x_from, ", x_to=", x_to, ", y_from=", y_from, ", y_to=", y_to, "\n"))
  tileCreator$render(z, x_from, x_to, y_from, y_to)
}
