library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)
# library(crul)
# library(webmockr)

# Tests
testthat::context("Resource")


#######################################################
testthat::context("Resource #load")
########################################################


test_that('works with base descriptor', {
  descriptor=jsonlite::fromJSON('{"name":"name","data":["data"]}')
  resource = Resource.load(descriptor)

  expect_equal(resource$name,'name')
  expect_equal(resource$tabular, FALSE)
  expect_equal(resource$descriptor, expandResourceDescriptor(descriptor))
  expect_equal(resource$inline, TRUE)
  expect_equal(resource$source, "data")
  expect_null(resource$table)
})

test_that('works with tabular descriptor', {
  descriptor=jsonlite::fromJSON('{"name":"name","data":["data"],"profile":"tabular-data-resource"}')
  resource = Resource.load(descriptor)
  expect_equal(resource$name, 'name')
  expect_equal(resource$tabular, TRUE)
  expect_equal(resource$descriptor, expandResourceDescriptor(descriptor))
  expect_equal(resource$inline, TRUE)
  expect_equal(resource$source, "data")
  # expect(resource$table_, succeed())
})


#######################################################
testthat::context('Resource #descriptor (retrieve)')
########################################################

test_that('object', {
  descriptor=jsonlite::fromJSON('{"name":"name","data":"data"}')
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor, expandResourceDescriptor(descriptor))
})

######## 
# test_that('string path', {
#   contents = jsonlite::fromJSON(system.file('data/data-resource.json',package = "datapackage.r"))
#   descriptor = 'https://httpbin.org/data-resource.json'
#   
#   # Mocks
#   (x = HttpClient$new(url = descriptor))
#   (res = x$patch(path = "patch",
#                   encode = "json",
#                   body = jsonlite::fromJSON('{"name": "name","data": "data"}')
#   ))
#   contents=jsonlite::fromJSON(res$parse("UTF-8"))$json
#   ##
#   
#   resource = Resource.load(descriptor)
#   expect_equal(resource$descriptor, expandResourceDescriptor(contents))
# })


test_that('string remote path bad', {
  descriptor = 'http://example.com/bad-path.json'
  # http.onGet(descriptor).reply(500)
  # error = Resource.load(descriptor)
  #assert.instanceOf(error, Error)
  expect_error(Resource.load(descriptor))
})

test_that('string local path', {
  contents = jsonlite::fromJSON(readLines('inst/data/data-resource.json', encoding = "UTF-8", warn = FALSE, skipNul = T))
  descriptor = 'data/data-resource.json'
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor, expandResourceDescriptor(contents))

})

test_that('string local path bad', {
  descriptor = 'data/bad-path.json'
  #error = Resource.load(descriptor)
  #error = catchError(Resource.load, descriptor)
  #assert.instanceOf(error, Error)
  #if (process.env.USER_ENV != 'browser') {
    #assert.include(error.message, 'Can not retrieve local')
  #} else {
    expect_error(Resource.load(descriptor))
  # }
})



#######################################################
testthat::context('Resource #descriptor (dereference)')
########################################################
# test_that('general', {
# descriptor = jsonlite::fromJSON(readLines('inst/data/data-resource-dereference.json',warn = FALSE))
#   descriptor = 'inst/data/data-resource-dereference.json'
#     resource = Resource.load(descriptor)
#     desired_outcome = expandResourceDescriptor(jsonlite::fromJSON('{"name": "name",  "data": "data","schema": {"fields": [{"name": "name"}]},"dialect": {"delimiter": ","},"dialects": {"main": {"delimiter": ","}}}'))
#     expect_false(identical(resource$descriptor,desired_outcome ))
# 
# })

# '{"resources":[{"name":"name1","data":["data"],"schema":"table-schema.json"},{"name":"name2","data":["data"],"dialect":"#/dialects/main"}],"dialects":{"main":{"delimiter":","}}'

test_that('pointer', {
  descriptor = jsonlite::fromJSON('{"name": "name","data": "data","schema": "#/schemas/main","schemas": {"main": {"fields": [{"name": "name"}]}}}')
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor,
               expandResourceDescriptor( jsonlite::fromJSON('{"name":"name","data":"data","schema":{"fields":[{"name":"name"}]},"schemas":{"main":{"fields":[{"name":"name"}]}}}' )))
})
# 
# 
test_that('pointer bad', {
  descriptor = jsonlite::fromJSON('{"name": "name", "data": "data", "schema": "#/schemas/main"}')
  # error = Resource.load(descriptor)
  # assert.instanceOf(error, Error)
  expect_error(Resource.load(descriptor))#, 'Not resolved Pointer URI')
})
# 
# test_that('remote', {
#   descriptor = {name: 'name', data: 'data', schema: 'http://example.com/schema'}
#   http.onGet(descriptor.schema).reply(200, {fields: [{name: 'name'}]})
#   resource = Resoursce.load(descriptor)
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
testthat::context('Resource #descriptor (expand)')
# ########################################################

# test_that('general resource', {
#   descriptor = jsonlite::fromJSON('{
#     "name": "name",
#     "data": "data"
#   }')
#   resource = Resource.load(descriptor)
#   expect_equal(resource$descriptor, {
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
testthat::context('Resource #source/sourceType')
# ########################################################
# 
test_that('inline', {
  descriptor = jsonlite::fromJSON('{
  "name": "name",
  "data": "data",
  "path": ["path"]
  }')
  resource = Resource.load(descriptor)
  expect_equal(resource$source, 'data')
  expect_equal(resource$inline, TRUE)
})

test_that('local', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["table.csv"]
  }')
  resource = Resource.load(descriptor, basePath= 'data')
  expect_equal(resource$source, 'data/table.csv')
  expect_equal(resource$local, TRUE)
})

# test_that('local base no base path', {
#   
#   descriptor = jsonlite::fromJSON('{"name": "name","path": ["table.csv"]}')
#   err=Resource.load(descriptor, basePath= NULL)
#   error = catchError(Resource.load(descriptor, basePath= NULL))
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'requires base path')
# }
# )
 
# test_that('local bad not safe absolute', {
#   descriptor = {
#     name: 'name',
#     path: ['/fixtures/table.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'not safe')
# })

# test_that('local bad not safe traversing', {
#   descriptor = {
#     name: 'name',
#     path: ['../fixtures/table.csv'],
#   }
#   error = catchError(Resource.load, descriptor, {basePath: 'data'})
#   assert.instanceOf(error, Error)
#   assert.include(error.message, 'not safe')
# })

test_that('remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["http://example.com//table.csv"]
  }')
  resource = Resource.load(descriptor)
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_equal(resource$remote, TRUE)
})

test_that('remote path relative and base path remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["table.csv"]
  }')
  resource = Resource.load(descriptor, basePath='http://example.com/')
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_equal(resource$remote, TRUE)
})

test_that('remote path remote and base path remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["http://example1.com/table.csv"]
  }')
  resource = Resource.load(descriptor, basePath= 'http://example2.com/')
  expect_equal(resource$source, 'http://example1.com/table.csv')
  expect_equal(resource$remote, TRUE)
})

# test_that('multipart local', {
#   descriptor = jsonlite::fromJSON('{
#     "name": "name",
#     "path": ["chunk1.csv", "chunk2.csv"]
#   }')
#   resource = Resource.load(descriptor, basePath = 'data')
#   expect_equal(resource$source, "['data/chunk1.csv', 'data/chunk2.csv']")
#   expect_equal(resource$local, true)
#   expect_equal(resource$multipart, TRUE)
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
# # 
# test_that('it raw reads local file source', {
#   #if (process.env.USER_ENV === 'browser') this.skip()
#   path= 'data/data.csv'
#   resource = Resource.load(path , basePath = '.')
#   bytes = resource.rawRead()
#   assert.include(bytes.toString(), 'name,size')
# })
# 
# # 
# 
# #######################################################
# testthat::context('Resource #table')
# ########################################################
# # 
# test_that('general resource', {
#   descriptor = jsonlite::fromJSON('{
#     "name": "name",
#     "data": "data"
#   }')
#   resource = Resource.load(descriptor)
#   expect_equal(resource$table, NULL)
# })
# 
# test_that('tabular resource inline', {
#   descriptor = jsonlite::fromJSON('{
#     "name": "example",
#     "profile": "tabular-data-resource",
#     "data": [
#       ["height", "age", "name"],
#       ["180", "18", "Tony"],
#       ["192", "32", "Jacob"]
#       ],
#     "schema": {
#       "fields": [
#         {"name": "height", "type": "integer"},
#         {"name": "age", "type": "integer"},
#         {"name": "name", "type": "string"}
#         ]
#     }
#   }')
#   resource = Resource.load(descriptor)
#   assert.instanceOf(resource$table, Table)
#   expect_equal(resource$table$read(), [
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
# # 
# test_that('preserve resource format from descriptor ', {
# #   if (process.env.USER_ENV === 'browser') this.skip()
#   descriptor=jsonlite::fromJSON('{"path": "data/data.csvformat", "format": "csv"}')
#   resource = Resource.load(descriptor)
#   expect_equal(resource$infer(), 
# jsonlite::fromJSON('{"encoding":"utf-8",
# "format":"csv",
# "mediatype":"text/csv",
# "name":"data",
# "path":"data/data.csvformat",
# "profile":"tabular-data-resource",
# "schema":{"fields":[
# {"format":"default","name":"city","type":"string"},
# {"format":"default","name":"population","type":"integer"}],
# "missingValues":[""]
# }
# }')
#   )
# })
# # 
# #  
