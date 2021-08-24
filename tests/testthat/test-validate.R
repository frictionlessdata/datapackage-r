library(datapackage.r)
library(testthat)

# Tests

testthat::context("validate")

test_that("returns true for valid descriptor", {
  descriptor <- '{"resources": [{"name": "name", "data": ["data"]}]}'
  valid <- validate(descriptor)
  expect_true(valid$valid)
})

test_that("returns true for valid remote descriptor", {
  descriptor <- "inst/extdata/dp1/datapackage.json"
  valid <- validate(descriptor)
  expect_true(valid$valid)
})

test_that("returns array of errors for invalid descriptor", {
  descriptor <- '{"resource": [{"name": "name"}]}'
  valid_errors <- validate(descriptor)
  expect_false(validate(valid_errors)$valid)
  expect_equal(length(valid_errors$errors), 1)
})
