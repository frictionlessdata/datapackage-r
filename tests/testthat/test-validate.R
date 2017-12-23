library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)

# Tests

testthat::context("validate")



# test_that('returns true for valid descriptor', {
#     descriptor = '{"resources": [{"name": "name", "data": ["data"]}]}' # '/inst/data/dp1/datapackage.json'
#     valid = validate(descriptor)
#     expect_true(valid$valid)
#   })

# test_that('returns array of errors for invalid descriptor', {
#   descriptor = "{resource: [{name: 'name'}]}"
#   valid_errors = validate(descriptor)
#   expect_equal(valid_errors[1], FALSE)
#   expect_equal(length(attributes(valid_errors)$err), 1)
#   })

test_that('returns array of errors for invalid descriptor', {
  #descriptor = "{resource: [{name: 'name'}]}"
  #valid_errors = validate(descriptor)
  expect_error(validate("{resource: [{name: 'name'}]}")$valid)
  #expect_equal(length(valid_errors$errors), 1)
})
