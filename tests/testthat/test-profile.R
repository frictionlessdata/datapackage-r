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
# 
# testthat::context("Profile")
# 
# describe('Profile', () => {
#   
#   describe('#load', () => {
#     let http
#     
#     beforeEach(() => {http = new AxiosMock(axios)})
#     afterEach(() => {http.restore()})
#     
# 
#     foreach(name = 1:length(PROFILES) ) %do% {
#       test_that(stringr::str_interp('load registry "${name}" profile'), {
#         jsonschema = system.file(stringr::str_interp('./inst/profiles/${name}.json'), package = "datapackage.r")
#         profile = Profile$load(name)
#         expect_equal(profile$jsonschema, jsonschema)
#       })
#     }
#     
#     
#     test_that('load remote profile', {
#       url = 'http://example.com/data-package.json'
#       jsonschema = system.file('./inst/profiles/data-package.json', package = "datapackage.r")
#       http.onGet(url).reply(200, jsonschema)
#       profile = Profile$load(url)
#       expect_equal(profile$name, 'data-package')
#       expect_equal(profile$jsonschema, jsonschema)
#     })
#     
#     
#     
#     
#     test_that('throw loading bad registry profile', {
#       const name = 'bad-data-package'
#       const error = catchError(Profile$load, name)
#       assert.instanceOf(error, Error)
#       assert.include(error$message, 'profile "bad-data-package"')
#     })
#     
#     
#     
#     test_that('throw loading bad remote profile', {
#       const name = 'http://example.com/profile.json'
#       http.onGet(name).reply(400)
#       const error = await catchError(Profile.load, name)
#       assert.instanceOf(error, Error)
#       assert.include(error.message, 'Can not retrieve remote')
#     })
#     
#     
#     
#   })
#   
#   
#   
#   
#   describe('#validate', () => {
#     
#     it('returns true for valid descriptor', async () => {
#       const descriptor = {resources: [{name: 'name', data: ['data']}]}
#       const profile = await Profile.load('data-package')
#       assert.isOk(profile.validate(descriptor))
#     })
#     
#     it('errors for invalid descriptor', async () => {
#       const descriptor = {}
#       const profile = await Profile.load('data-package')
#       const {valid, errors} = profile.validate(descriptor)
#       expect_equal(valid, false)
#       assert.instanceOf(errors[0], Error)
#       assert.include(errors[0].message, 'Missing required property')
#     })
#     
#   })
#   
#   describe('#up-to-date', () => {
#     
#     PROFILES.forEach(name => {
#       it(`profile ${name} should be up-to-date`, async function() {
#         if (process.env.USER_ENV === 'browser') this.skip()
#         if (process.env.TRAVIS_BRANCH !== 'master') this.skip()
#         const profile = await Profile.load(name)
#         const response = await axios.get(`https://specs.frictionlessdata.io/schemas/${name}.json`)
#         expect_equal(profile.jsonschema, response.data)
#       })
#     })
#     
#   })
#   
# })