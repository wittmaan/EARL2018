
library(testthat)
source("TileCreator.R")

test_that("cassandra get data", {
  dat <- tileCreator$getData(20, 557817, 363819)
  expect_equal(nrow(dat), 97)
})
