library(datapackage.r)
library(testthat)
library(foreach)

# Tests

testthat::context("DataPackageError")



test_that('should work with one error', {
  error = DataPackageError$new('message')
  expect_equivalent(error$message, 'message')
  expect_equivalent(error$multiple(), FALSE)
  expect_equivalent(error$errors(), list())
})



test_that('should work with multiple errors', {
  errors = list('error1', 'error2')
  error = DataPackageError$new('message', errors)
  expect_equivalent(error$message, 'message')
  expect_equivalent(error$multiple(), TRUE)
  expect_equivalent(length(error$errors()), 2)
  expect_equivalent(error$errors()[1], 'error1')
  expect_equivalent(error$errors()[2], 'error2')
})

test_that('should be catchable as a normal error', {
  tryCatch({
    DataPackageError$new('message')
  }, error = function(e) {
      expect_equivalent(error$message, 'message')
      #expect_equivalent(methods::is(error,"Error") , true)
      expect_equivalent(methods::is(error,"DataPackageError"), TRUE)
    })
  })
  
# test_that('should work with table schema error', {
#     tryCatch({
#       tableschema.r::TableSchemaError$new('message')$errors()
#     }, error = function(e) {
#       expect_equivalent(error.message, 'message')
#       expect_equivalent(methods::is(error, "Error"), TRUE)
#       expect_equivalent(methods::is(error,DataPackageError), TRUE)
#       expect_equivalent(methods::is(error, tableschema.r::TableSchemaError$errors()), TRUE)
#     })
#   })
  