library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)
# Tests

testthat::context("helpers")

  testlist = list( 
    list('data.csv', TRUE),
    list('data/data.csv', TRUE),
    list('data/country/data.csv', TRUE),
    list('data\\data.csv', TRUE),
    list('data\\country\\data.csv', TRUE),
    #list('../data.csv', FALSE),
    list('~/data.csv', FALSE),
    list('~invalid_user/data.csv', FALSE),
    list('%userprofile%', FALSE),
    list('%unknown_windows_var%', FALSE),
    list('$HOME', FALSE),
    list('$UNKNOWN_VAR', FALSE)
  )


foreach(j = 1:length(testlist) ) %do% {
  
  testlist[[j]] = setNames(testlist[[j]], c("path", "isSafe") )
  
  test_that(stringr::str_interp('#isSafePath: ${testlist[[j]]$path} -> ${testlist[[j]]$isSafe}'), {
    
    expect_equal(isSafePath(testlist[[j]]$path), testlist[[j]]$isSafe)
  })
}

# Helpers
# 
# catchError  = function (func, args) {
#   #async
#   future::future(
#     tryCatch({
#       eval(parse(text=paste(func,"(",args,")")))
#     }, error =  function (exception) {
#       error = exception
#       error
#     }))
#   return (error)
# }