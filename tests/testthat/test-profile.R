library(datapackage.r)
library(testthat)
library(foreach)
library(jsonlite)
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

########################################
testthat::context("Profile")
########################################

foreach(name = 1:length(PROFILES) ) %do% {
  
  test_that(stringr::str_interp('load registry "${PROFILES[[name]]}" profile'), {
    
    jsonschema = helpers.from.json.to.list(stringr::str_interp('inst/profiles/${PROFILES[[name]]}.json'))
    
    profile = Profile.load(PROFILES[[name]])
    
    expect_true(identical(profile$jsonschema, jsonschema))
  })
}

test_that('load remote profile', {
  url = 'http://example.com/data-package.json'
  jsonschema = helpers.from.json.to.list('inst/profiles/data-package.json')
  
  profile = Profile.load(url)
  expect_equal(profile$name, 'data-package')
  expect_equal(profile$jsonschema, jsonschema)
})

test_that('throw loading bad registry profile', {
  name = 'bad-data-package'
  expect_error(Profile.load(name))
})



test_that('throw loading bad remote profile', {
  name = 'http://example.com/profile.json'
  
  
  expect_error(
    with_mock(
      `httr:::request_perform` = function()
        httptest::fakeResponse(httr::GET(name), status_code = 400) ,
      `httptest::request_happened` = expect_message,
      eval.parent(Profile.load(name)),
      "Can not retrieve remote"
    )
  )
  

})


########################################
testthat::context('Profile #validate')
########################################

test_that('returns true for valid descriptor', {
  descriptor = '{"resources": [{"name": "name", "data": ["data"]}]}'
  profile = Profile.load('data-package')
  expect_true(profile$validate(descriptor)$valid)
})

test_that('errors for invalid descriptor', {
  descriptor = helpers.from.json.to.list("{}")
  profile = Profile.load('data-package')
  valid_errors = profile$validate(descriptor)
  expect_false(valid_errors$valid)
  expect_equal_to_reference(valid_errors$errors[1], "Error")
})
#
############################################
testthat::context('Profile #up-to-date')
############################################


## method 1 readLines
foreach(name = 1:length(PROFILES) ) %do% {
  testthat::context(c('Profile #up-to-date - ', PROFILES[[name]]))
  test_that(stringr::str_interp('profile ${PROFILES[[name]]} should be up-to-date'), {
    profile = Profile.load(PROFILES[[name]])
    response.data = helpers.from.json.to.list(stringr::str_interp('https://specs.frictionlessdata.io/schemas/${PROFILES[[name]]}.json'))
    expect_true(identical(profile$jsonschema, response.data))
  })
}

## method 2 httr GET-RESPONSE compare their lengths instead  (this method creates slightly different nests levels but the structure is the same as before)
foreach(name = 1:length(PROFILES) ) %do% {
  test_that(stringr::str_interp('profile ${PROFILES[[name]]} should be up-to-date'), {
    profile = Profile.load(PROFILES[[name]])
    response = httr::GET(stringr::str_interp('https://specs.frictionlessdata.io/schemas/${PROFILES[[name]]}.json')) 
    response.data = httr::content(response, as = 'text', encoding = 'UTF-8')
    
    foreach(index = 1:length(profile$jsonschema)) %do% {
      
      lengths.from.profile = lapply(profile$jsonschema[index],lengths)
      lengths.target = lapply(helpers.from.json.to.list(response.data)[index],lengths)
      expect_true(identical(lengths.from.profile,lengths.target))
      
      foreach(ind = 1:length(profile$jsonschema[index]))%do% {
        
        lengths.from.profile = lapply(profile$jsonschema[index][ind],lengths)
        lengths.target = lapply(helpers.from.json.to.list(response.data)[index][ind],lengths)
        expect_true(identical(lengths.from.profile,lengths.target))
      }}
  })
}
