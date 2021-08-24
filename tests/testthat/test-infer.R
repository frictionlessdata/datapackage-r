library(datapackage.r)
library(testthat)

# Tests

testthat::context("infer")

test_that("it infers local data package", {
  descriptor <- infer(pattern = "csv", basePath = "inst/extdata/dp1") # '**/*.csv'

  expect_equal(descriptor$profile, "tabular-data-package")
  expect_equal(length(descriptor$resources), 1)
  expect_equal(descriptor$resources[[1]]$path, "data.csv")
  expect_equal(descriptor$resources[[1]]$format, "csv")
  expect_equal(descriptor$resources[[1]]$encoding, "utf-8")
  expect_equal(descriptor$resources[[1]]$profile, "tabular-data-resource")
  expect_equal(descriptor$resources[[1]]$schema$fields[[1]]$name, "name")
  expect_equal(descriptor$resources[[1]]$schema$fields[[2]]$name, "size")
})
