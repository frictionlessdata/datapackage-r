library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)


# Constants

PROFILES = list(
  'data-package',
  'tabular-data-package',
  'fiscal-data-package',
  'data-resource',
  'tabular-data-resource'
)


# Tests

testthat::context("Profile")


# foreach(name = 1:length(PROFILES) ) %do% {
# 
#   test_that(stringr::str_interp('load registry "${PROFILES[[name]]}" profile'), {
# 
#     jsonschema = jsonlite::fromJSON(file.path(system.file(stringr::str_interp('profiles/${PROFILES[[name]]}.json'), package = "datapackage.r")))
#     
#     profile = Profile.load(PROFILES[[name]])
# 
#     expect_true(identical(profile$jsonschema, jsonschema))
#   })
# }

# test_that('load remote profile', {
#   url = 'http://example.com/data-package.json'
#   jsonschema = system.file('profiles/data-package.json', package = "datapackage.r")
#   #httr::GET(url)$status_code #200
#   #profile = Profile.load(url)
#   expect_equal(profile$name, 'data package')
#   expect_equal(profile$jsonschema, jsonschema)
# })
# 
# test_that('throw loading bad registry profile', {
#   name = 'bad-data-package'
#   # expect_error(Profile$load(name))
# })
# 
# 
# 
# test_that('throw loading bad remote profile', {
#   name = 'http://example.com/profile.json'
#   #http.onGet(name).reply(400)
#   # expect_error(Profile$load(name))
# })
# 
# 
# ##
# testthat::context('Profile #validate')
# 
# test_that('returns true for valid descriptor', {
#   descriptor = '{"resources": [{"name": "name", "data": ["data"]}]}'
#   #profile = Profile.load('data-package')
#   #expect_true(profile$validate(descriptor)$valid)
# })
# 
# # test_that('errors for invalid descriptor', {
# #   descriptor = "{}"
# #   profile = Profile.load('data-package')
# #   valid_errors = profile$validate(descriptor)
# #   
# #   expect_error(valid_errors.valid)
# #   expect_equal_to_reference(valid_errors$errors[1], "Error")
# # })
# 
# ##
# testthat::context('Profile #up-to-date')
# 
# # foreach(name = 1:length(PROFILES) ) %do% {
# #   test_that(stringr::str_interp('profile ${PROFILES[[name]]} should be up-to-date'), {
# #     # if (process.env.USER_ENV == 'browser') this.skip()
# #     # if (process.env.TRAVIS_BRANCH != 'master') this.skip()
# #     profile = Profile.load(PROFILES[[name]])
# #     response = httr::GET(stringr::str_interp('https://specs.frictionlessdata.io/schemas/${PROFILES[[name]]}.json'))
# #     response.data = httr::content(response, as = 'text')
# #     identical(profile$jsonschema.contents(), response.data)
# #   })
# # }
