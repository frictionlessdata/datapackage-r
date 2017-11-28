library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)
#expand = expandResourceDescriptor

# Tests
testthat::context("Resource")


#######################################################
testthat::context("Resource #load")
########################################################


test_that('works with base descriptor', {
  descriptor = '{"name": "name","data": ["data"]}'
  resource = Resource.load(descriptor)
  
  expect_equal(resource$name(),'name')
  expect_equal(resource$tabular(), FALSE)
  # expect_equal(resource$descriptor(), expandResourceDescriptor(descriptor))
  # expect_equal(resource$inline(), TRUE)
  # expect_equal(resource$source(), "['data']")
  # expect_equal(resource$table(), NULL)
})

test_that('works with tabular descriptor', {
  descriptor = '{"name": "name","data": ["data"],"profile": "tabular-data-resource"}'
  resource = Resource.load(descriptor)

  expect_equal(resource$name(), 'name')
  expect_equal(resource$tabular(), TRUE)
  # expect_equal(resource$descriptor(), expandResourceDescriptor(descriptor))
#   expect_equal(resource$inline(), TRUE)
#   expect_equal(resource$source(), "['data']")
#   expect(resource$table)
})



#######################################################
testthat::context('Resource #descriptor (retrieve)')
########################################################

test_that('object', {
  descriptor = '{"name": "name","data": "data"}'
  resource = Resource.load(descriptor)
#   
#   expect_equal(resource$descriptor(), expandResourceDescriptor(descriptor))
})
# 
# test_that('string remote path', {
#   contents = readLines('inst/data/data-resource.json')
#   descriptor = 'http://example.com/data-resource.json'
# #   
# #   #http.onGet(descriptor).reply(200, contents)
#   resource = Resource$load(descriptor)
# #   expect_equal(resource.descriptor, expand(contents))
# # })
# 
# test_that('string remote path bad', {
#   descriptor = 'http://example.com/bad-path.json'
#  
#   http.onGet(descriptor).reply(500)
#   
#   error = catchError(Resource.load, descriptor)
#   #assert.instanceOf(error, Error)
#   #assert.include(error.message, 'Can not retrieve remote')
# })
# 
# test_that('string local path', {
#   contents = require('data/data-resource.json')
#   descriptor = 'inst/data/data-resource.json'
#   if (process.env.USER_ENV != 'browser') {
#     resource = Resource$load(descriptor)
#     expect_equal(resource.descriptor, expand(contents))
#   } else {
#     error = catchError(Resource.load, descriptor)
#     #assert.instanceOf(error, Error)
#     #assert.include(error.message, 'in browser is not supported')
#   }
# })
# 
# test_that('string local path bad', {
#   descriptor = 'data/bad-path.json'
#   error = catchError(Resource.load, descriptor)
#   #assert.instanceOf(error, Error)
#   if (process.env.USER_ENV != 'browser') {
#     #assert.include(error.message, 'Can not retrieve local')
#   } else {
#     #assert.include(error.message, 'in browser is not supported')
#   }
# })
# 
# 
# 
# #######################################################
# testthat::context('Resource #descriptor (dereference)')
# ########################################################
# test_that('general', {
#   descriptor = 'data/data-resource-dereference.json'
#   if (process.env.USER_ENV != 'browser') {
#     resource = Resource.load(descriptor)
#     expect_equal(resource.descriptor, 
#                  expand('{"name": "name",  "data": "data","schema": {"fields": [{"name": "name"}]},"dialect": {"delimiter": ","},"dialects": {"main": {"delimiter": ","}}}' ))
#   } else {
#     error = catchError(Resource.load, descriptor)
#     #assert.instanceOf(error, Error)
#     #assert.include(error.message, 'in browser')
#   }
# })
# 
# test_that('pointer', {
#   descriptor = '{"name": "name","data": "data","schema": "#/schemas/main","schemas": {"main": {"fields": [{"name": "name"}]}}}'
#   resource = Resource.load(descriptor)
#   expect_equal(resource.descriptor, expand({name: 'name', data: 'data',schema: {fields: [{name: 'name'}]},schemas: {main: {fields: [{name: 'name'}]}}} ))
# })
# 
# 
# test_that('pointer bad', {
#   descriptor = {name: 'name', data: 'data', schema: '#/schemas/main',}
#   error = catchError(Resource.load, descriptor)
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'Not resolved Pointer URI')
# })
# 
# test_that('remote', {
#   descriptor = {name: 'name', data: 'data', schema: 'http://example.com/schema'}
#   http.onGet(descriptor.schema).reply(200, {fields: [{name: 'name'}]})
#   resource = Resource.load(descriptor)
#   expect_equal(resource.descriptor, expand({name: 'name', data: 'data', schema: {fields: [{name: 'name'}]}}))
# })
# 
# test_that('remote bad', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#     schema: 'http://example.com/schema',
#   }
#   http.onGet(descriptor.schema).reply(500)
#   error = catchError(Resource.load, descriptor)
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'Not resolved Remote URI')
# })
# 
# test_that('local', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#     schema: 'table-schema.json',
#   }
#   if (process.env.USER_ENV !== 'browser') {
#     resource = Resource.load(descriptor, {basePath: 'data'})
#     expect_equal(resource.descriptor, expand({
#       name: 'name',
#       data: 'data',
#       schema: {fields: [{name: 'name'}]},
#     }))
#   } else {
#     error = catchError(Resource.load, descriptor, {basePath: 'data'})
#     assert.instanceOf(error, Error)
#     assert.include(error.message, 'in browser is not supported')
#   }
# })
# 
# test_that('local bad', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#     schema: 'bad-path.json',
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   if (process.env.USER_ENV !== 'browser') {
#     assert.include(error.message, 'Not resolved Local URI')
#   } else {
#     assert.include(error.message, 'in browser is not supported')
#   }
# })
# 
# test_that('local bad not safe', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#     schema: '../data/table_schema.json',
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   if (process.env.USER_ENV !== 'browser') {
#     assert.include(error.message, 'Not safe path')
#   } else {
#     assert.include(error.message, 'in browser is not supported')
#   }
# })
# 
# 
# 
# #######################################################
# testthat::context('Resource #descriptor (expand)')
# ########################################################
# 
# test_that('general resource', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#   }
#   resource = Resource.load(descriptor)
#   expect_equal(resource.descriptor, {
#     name: 'name',
#     data: 'data',
#     profile: 'data-resource',
#     encoding: 'utf-8',
#   })
# })
# 
# test_that('tabular resource schema', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#     profile: 'tabular-data-resource',
#     schema: {
#       fields: [{name: 'name'}],
#     },
#   }
#   resource = Resource.load(descriptor)
#   expect_equal(resource.descriptor, {
#     name: 'name',
#     data: 'data',
#     profile: 'tabular-data-resource',
#     encoding: 'utf-8',
#     schema: {
#       fields: [{name: 'name', type: 'string', format: 'default'}],
#       missingValues: [''],
#     },
#   })
# })
# 
# test_that('tabular resource dialect', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#     profile: 'tabular-data-resource',
#     dialect: {
#       delimiter: 'custom',
#     },
#   }
#   resource = Resource.load(descriptor)
#   expect_equal(resource.descriptor, {
#     name: 'name',
#     data: 'data',
#     profile: 'tabular-data-resource',
#     encoding: 'utf-8',
#     dialect: {
#       delimiter: 'custom',
#       doubleQuote: true,
#       lineTerminator: '\r\n',
#       quoteChar: '"',
#       escapeChar: '\\',
#       skipInitialSpace: true,
#       header: true,
#       caseSensitiveHeader: false,
#     },
#   })
# })
# 
#  
# 
# 
# #######################################################
# testthat::context('Resource #source/sourceType')
# ########################################################
# 
# test_that('inline', {
  # descriptor = '{
  #   "name": "name",
  #   "data": "data",
  #   "path": ["path"]
  # }'
#   resource = Resource.load(descriptor)
#   expect_equal(resource$source(), 'data')
#   expect_equal(resource$inline(), true)
# })
# 
# test_that('local', {
#   descriptor = {
#     name: 'name',
#     path: ['table.csv'],
#   }
#   resource = Resource.load(descriptor, {basePath: 'data'})
#   expect_equal(resource.source, 'data/table.csv')
#   expect_equal(resource.local, true)
# })
# 
# test_that('local base no base path', {
#   descriptor = {
#     name: 'name',
#     path: ['table.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: null})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'requires base path')
# })
# 
# test_that('local bad not safe absolute', {
#   descriptor = {
#     name: 'name',
#     path: ['/fixtures/table.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'not safe')
# })
# 
# test_that('local bad not safe traversing', {
#   descriptor = {
#     name: 'name',
#     path: ['../fixtures/table.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'not safe')
# })
# 
# test_that('remote', {
#   descriptor = {
#     name: 'name',
#     path: ['http://example.com/table.csv'],
#   }
#   resource = Resource.load(descriptor)
#   expect_equal(resource.source, 'http://example.com/table.csv')
#   expect_equal(resource.remote, true)
# })
# 
# test_that('remote path relative and base path remote', {
#   descriptor = {
#     name: 'name',
#     path: ['table.csv'],
#   }
#   resource = Resource.load(descriptor, {basePath: 'http://example.com/'})
#   expect_equal(resource.source, 'http://example.com/table.csv')
#   expect_equal(resource.remote, true)
# })
# 
# test_that('remote path remote and base path remote', {
#   descriptor = {
#     name: 'name',
#     path: ['http://example1.com/table.csv'],
#   }
#   resource = Resource.load(descriptor, {basePath: 'http://example2.com/'})
#   expect_equal(resource.source, 'http://example1.com/table.csv')
#   expect_equal(resource.remote, true)
# })
# 
# test_that('multipart local', {
#   descriptor = {
#     name: 'name',
#     path: ['chunk1.csv', 'chunk2.csv'],
#   }
#   resource = Resource.load(descriptor, {basePath: 'data'})
#   expect_equal(resource.source, ['data/chunk1.csv', 'data/chunk2.csv'])
#   expect_equal(resource.local, true)
#   expect_equal(resource.multipart, true)
# })
# 
# test_that('multipart local bad no base path', {
#   descriptor = {
#     name: 'name',
#     path: ['chunk1.csv', 'chunk2.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: null})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'requires base path')
# })
# 
# test_that('multipart local bad not safe absolute', {
#   descriptor = {
#     name: 'name',
#     path: ['/fixtures/chunk1.csv', 'chunk2.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'not safe')
# })
# 
# test_that('multipart local bad not safe traversing', {
#   descriptor = {
#     name: 'name',
#     path: ['chunk1.csv', '../fixtures/chunk2.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   # Assert
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'not safe')
# })
# 
# test_that('multipart remote', {
#   descriptor = {
#     name: 'name',
#     path: ['http://example.com/chunk1.csv', 'http://example.com/chunk2.csv'],
#   }
#   resource = Resource.load(descriptor)
#   expect_equal(resource.source,
#                ['http://example.com/chunk1.csv', 'http://example.com/chunk2.csv'])
#   expect_equal(resource.remote, true)
#   expect_equal(resource.multipart, true)
# })
# 
# test_that('multipart remote path relative and base path remote', {
#   descriptor = {
#     name: 'name',
#     path: ['chunk1.csv', 'chunk2.csv'],
#   }
#   resource = Resource.load(descriptor, {basePath: 'http://example.com'})
#   expect_equal(resource.source,
#                ['http://example.com/chunk1.csv', 'http://example.com/chunk2.csv'])
#   expect_equal(resource.remote, true)
#   expect_equal(resource.multipart, true)
# })
# 
# test_that('multipart remote path remote and base path remote', {
#   descriptor = {
#     name: 'name',
#     path: ['chunk1.csv', 'http://example2.com/chunk2.csv'],
#   }
#   resource = Resource.load(descriptor, {basePath: 'http://example1.com'})
#   expect_equal(resource.source,
#                ['http://example1.com/chunk1.csv', 'http://example2.com/chunk2.csv'])
#   expect_equal(resource.remote, true)
#   expect_equal(resource.multipart, true)
# })
# 
#   
# 
# 
# #######################################################
# testthat::context('Resource #rawRead')
# ########################################################
# 
# test_that('it raw reads local file source', {
#   if (process.env.USER_ENV === 'browser') this.skip()
#   resource = Resource.load({path: 'data/data.csv'}, {basePath: '.'})
#   bytes = resource.rawRead()
#   assert.include(bytes.toString(), 'name,size')
# })
# 
# 
# 
# #######################################################
# testthat::context('Resource #table')
# ########################################################
# 
# test_that('general resource', {
#   descriptor = {
#     name: 'name',
#     data: 'data',
#   }
#   resource = Resource.load(descriptor)
#   expect_equal(resource.table, null)
# })
# 
# test_that('tabular resource inline', {
#   descriptor = {
#     name: 'example',
#     profile: 'tabular-data-resource',
#     data: [
#       ['height', 'age', 'name'],
#       ['180', '18', 'Tony'],
#       ['192', '32', 'Jacob'],
#       ],
#     schema: {
#       fields: [
#         {name: 'height', type: 'integer'},
#         {name: 'age', type: 'integer'},
#         {name: 'name', type: 'string'},
#         ],
#     },
#   }
#   resource = Resource.load(descriptor)
#   assert.instanceOf(resource.table, Table)
#   expect_equal(resource.table.read(), [
#     [180, 18, 'Tony'],
#     [192, 32, 'Jacob'],
#     ])
# })
# 
# test_that('tabular resource local', {
#   #/ Skip test for browser
#   if (process.env.USER_ENV === 'browser') {
#     this.skip()
#   }
#   # Prepare
#   descriptor = {
#     name: 'example',
#     profile: 'tabular-data-resource',
#     path: ['dp1/data.csv'],
#     schema: {
#       fields: [
#         {name: 'name', type: 'string'},
#         {name: 'size', type: 'integer'},
#         ],
#     },
#   }
#   resource = Resource.load(descriptor, {basePath: 'data'})
#   # Assert
#   assert.instanceOf(resource.table, Table)
#   expect_equal(resource.table.read(), [
#     ['gb', 100],
#     ['us', 200],
#     ['cn', 300],
#     ])
# })
# 
#   
#   
# #######################################################
# testthat::context('Resource #infer')
# ########################################################
# 
test_that('preserve resource format from descriptor ', {
#   if (process.env.USER_ENV === 'browser') this.skip()
  resource = Resource.load('{"path": "data/data.csvformat", "format": "csv"}')
#   expect_equal(resource$infer(), {
#     encoding: 'utf-8',
#     format: 'csv',
#     mediatype: 'text/csv',
#     name: 'data',
#     path: 'data/data.csvformat',
#     profile: 'tabular-data-resource',
#     schema: {fields: [
#       {format: 'default', name: 'city', type: 'string'},
#       {format: 'default', name: 'population', type: 'integer'}],
#       missingValues: [''],
#     },
#   })
})
# 
#  
