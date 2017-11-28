# library(datapackage.r)
# library(testthat)
# library(foreach)
# library(stringr)
# 
# # Tests
# 
# testthat::context("infer")
# 
# test_that('it infers local data package', {
# 
#   descriptor = infer(pattern='csv', basePath = 'data/dp1') # '**/*.csv'
#   descriptor = '{"profile": "data-package""}'
#   
#   expect_equal(descriptor$profile, 'tabular-data-package')
#   expect_equal(length(descriptor$resources), 1)
#   expect_equal(descriptor$resources[0]$path, 'data.csv')
#   expect_equal(descriptor$resources[0]$format, 'csv')
#   expect_equal(descriptor$resources[0]$encoding, 'utf-8')
#   expect_equal(descriptor$resources[0]$profile, 'tabular-data-resource')
#   expect_equal(descriptor$resources[0]$schema$fields[1].name, 'name')
#   expect_equal(descriptor$resources[0]$schema$fields[2].name, 'size')
# 
# })
# 
# 
# it('it infers local data package', async function() {
#   if (process.env.USER_ENV === 'browser') this.skip()
#   const descriptor = await infer('**/*.csv', {basePath: 'data/dp1'})
#   assert.deepEqual(descriptor.profile, 'tabular-data-package')
#   assert.deepEqual(descriptor.resources.length, 1)
#   assert.deepEqual(descriptor.resources[0].path, 'data.csv')
#   assert.deepEqual(descriptor.resources[0].format, 'csv')
#   assert.deepEqual(descriptor.resources[0].encoding, 'utf-8')
#   assert.deepEqual(descriptor.resources[0].profile, 'tabular-data-resource')
#   assert.deepEqual(descriptor.resources[0].schema.fields[0].name, 'name')
#   assert.deepEqual(descriptor.resources[0].schema.fields[1].name, 'size')
# })
# 
# # def test_infer():
# #   descriptor = infer('datapackage/*.csv', base_path='data')
# # assert descriptor == {
# #   'profile': 'tabular-data-package',
# #   'resources': [{'encoding': 'utf-8',
# #     'format': 'csv',
# #     'mediatype': 'text/csv',
# #     'name': 'data',
# #     'path': 'datapackage/data.csv',
# #     'profile': 'tabular-data-resource',
# #     'schema': {'fields': [
# #       {'format': 'default', 'name': 'id', 'type': 'integer'},
# #       {'format': 'default', 'name': 'city', 'type': 'string'}],
# #       'missingValues': ['']}}]}