library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)

# Tests
# 
# testthat::context("infer")
# 
# 
#   test_that('it infers local data package', async function() {
#     
#     if (process.env.USER_ENV === 'browser') this.skip()
#     
#     descriptor = infer('**/*.csv', {basePath: 'data/dp1'})
#     
#     expect_equal(descriptor.profile, 'tabular-data-package')
#     expect_equal(descriptor.resources.length, 1)
#     expect_equal(descriptor.resources[0].path, 'data.csv')
#     expect_equal(descriptor.resources[0].format, 'csv')
#     expect_equal(descriptor.resources[0].encoding, 'utf-8')
#     expect_equal(descriptor.resources[0].profile, 'tabular-data-resource')
#     expect_equal(descriptor.resources[0].schema.fields[0].name, 'name')
#     expect_equal(descriptor.resources[0].schema.fields[1].name, 'size')
#     
#   })
#   
