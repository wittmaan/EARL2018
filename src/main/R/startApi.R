library(plumber)

r <- plumb("api.R")

r$run(port=7000)
