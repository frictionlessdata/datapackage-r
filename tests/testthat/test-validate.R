library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)

# Tests

testthat::context("validate")


  
# test_that('returns true for valid descriptor', {
#     descriptor = '{"resources": [{"name": "name", "data": ["data"]}]}'
#     valid = validate(descriptor)
#     expect_success(valid)
#   })
#   
#   test_that('returns array of errors for invalid descriptor', {
#     descriptor = '{"resource": [{"name": "name"}]}'
#     valid_errors = validate(descriptor)
#     names(valid_errors) = c("valid", "errors")
#     expect_equal(valid, FALSE)
#     expect_equal(length(errors), 1)
#   })
