library(datapackage.r)
library(tableschema.r)
library(testthat)

# Tests

######################################
testthat::context("DataPackageError")
######################################


test_that('should work with one error', {
  error <- DataPackageError$new('message')
  
  expect_equivalent(error$message, 'message')
  expect_equivalent(error$multiple, FALSE)
  expect_equivalent(error$errors, list())
})

test_that('should work with multiple errors', {
  errors <- list('error1', 'error2')
  error <- DataPackageError$new('message', errors)
  
  expect_equivalent(error$message, 'message')
  expect_equivalent(error$multiple, TRUE)
  expect_equivalent(length(error$errors), 2)
  expect_equivalent(error$errors[1], list('error1'))
  expect_equivalent(error$errors[2], list('error2'))
})

test_that('should be catchable as a normal error', {
  
  error <- tryCatch({
    DataPackageError$new('message')
    
  }, error = function(error) {
    error
  })
  expect_equivalent(error$message, 'message')
  expect_true("DataPackageError" %in% class(error))
})

test_that('should work with table schema error', {
  error <- tryCatch({
    tableschema.r::TableSchemaError$new('message')
    
  }, error = function(error) {
    error
  })
  expect_equivalent(error$message, 'message')
  expect_false("DataPackageError" %in% class(error))
  expect_true("TableSchemaError" %in% class(error))
})
