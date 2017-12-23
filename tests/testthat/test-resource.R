library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)
library(crul)
library(webmockr)
library(httptest)

# Tests
testthat::context("Resource")


#######################################################
testthat::context("Resource #load")
########################################################



test_that('works with base descriptor', {
  
  descriptor = '{"name":"name","data":["data"]}'
  resource = Resource.load(descriptor)
  
  expect_equal(resource$name, 'name')
  expect_false(resource$tabular)
  expect_equal(resource$descriptor, 
               expandResourceDescriptor(descriptor))
  expect_true(resource$inline)
  expect_equal(resource$source, list("data"))
  expect_null(resource$table)
})

test_that('works with tabular descriptor', {
  descriptor = '{"name":"name","data":["data"],"profile":"tabular-data-resource"}' #tabular-
  resource = Resource.load(descriptor)
  expect_equal(resource$name, 'name')
  expect_true(resource$tabular)
  expect_equal(resource$descriptor,
               expandResourceDescriptor(helpers.from.json.to.list(descriptor)))
  expect_true(resource$inline)
  
  expect_equal(resource$source, list("data"))
  # expect_null(resource$table)
  
})



#######################################################
testthat::context('Resource #descriptor (retrieve)')
########################################################

test_that('object', {
  descriptor = '{"name": "name","data": "data"}'
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor,
               expandResourceDescriptor(helpers.from.json.to.list(descriptor)))
})


# test_that('string remote path', {
#   fileName = system.file('data/data-resource.json', package = 'datapackage.r')
#   contents = helpers.from.json.to.list(fileName)
#   
#   descriptor = 'https://httpbin.org/data-resource.json'
#   
#   httptest::with_mock_API({
#     resource = Resource.load(descriptor)
#     
#   })
#   
#   expect_equal(resource$descriptor,
#                expandResourceDescriptor(descriptor = contents))
#   
# })


test_that('string remote path bad', {
  descriptor = 'https://httpbin.org/bad-path.json'
  
  expect_error(
    with_mock(
      `httr:::request_perform` = function()
        httptest::fakeResponse(httr::GET(descriptor), status_code = 500) ,
      `httptest::request_happened` = expect_message,
      eval.parent(Resource.load(descriptor)),
      "Can not retrieve remote"
    )
  )
})

test_that('string local path', {
  fileName = 'inst/data/data-resource.json'
  
  contents = helpers.from.json.to.list(fileName)
  descriptor  = 'inst/data/data-resource.json'
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor, expandResourceDescriptor(contents))
  
})

test_that('string local bad path', {
  descriptor = 'bad-path.json'
  expect_error(Resource.load(descriptor))#, "Can not retrieve local")
  
})



#########################################################
testthat::context('Resource #descriptor (dereference)')
#########################################################
test_that('general', {
  descriptor = 'inst/data/data-resource-dereference.json'
  resource = Resource.load(descriptor)
  
  expect_equal(resource$descriptor,
               expandResourceDescriptor(
                 helpers.from.json.to.list(
                   '{"name": "name",  "data": "data","schema": {"fields": [{"name": "name"}]},"dialect": {"delimiter": ","},"dialects": {"main": {"delimiter": ","}}}'
                 )
               )
  )
})


test_that('pointer', {
  descriptor = '{"name": "name","data": "data","schema": "#/schemas/main","schemas": {"main": {"fields": [{"name": "name"}]}}}'
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor,
               expandResourceDescriptor(
                 helpers.from.json.to.list(
                   '{
                   "name": "name",
                   "data": "data",
                   "schema": {"fields": [{"name": "name"}]},
                   "schemas": {"main": {"fields": [{"name": "name"}]}}
}'
)
                 ))
  })


test_that('pointer bad', {
  descriptor = '{"name": "name", "data": "data", "schema": "#/schemas/main"}'
  expect_error(Resource.load(descriptor))
  
})


# test_that('remote', {
#   descriptor = helpers.from.json.to.list('{"name": "name", "data": "data", "schema": "http://example.com/schema"}')
#   
#   resource = with_mock(
#     `curl:::curl` = function(txt, handle) {
#       httptest::fakeResponse(
#         httr::GET(descriptor$schema),
#         status_code = 200,
#         content = list(fields = list(list(name = "name")))
#       )
#     },
#     `httptest::request_happened` = expect_message,
#     eval.parent(Resource.load(descriptor))
#   )
#   expect_equal(resource$descriptor,
#                expandResourceDescriptor(descriptor = list(
#                  name = 'name',
#                  data = 'data',
#                  schema = list(fields = list(list(name = 'name')))
#                )))
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
test_that('local', {
  descriptor ='{
  "name": "name",
  "data": "data",
  "schema": "table-schema.json"
}'
  resource = Resource.load(descriptor, basePath = 'inst/data')
  expect_equal(resource$descriptor, 
               expandResourceDescriptor(
                 helpers.from.json.to.list(
                   '{"name": "name","data": "data","schema": {"fields": [{"name": "name"}]} }')))
  })

test_that('local bad', {
  descriptor = '{"name": "name",
  "data": "data",
  "schema": "bad-path.json"}'
  expect_error(Resource.load(descriptor, basePath = 'inst/data'))
  
  })

test_that('local bad not safe', {
  descriptor = '{"name": "name",
  "data": "data",
  "schema": "../data/table_schema.json"}'
  expect_error(Resource.load(descriptor, basePath = 'inst/data'))
  })



#######################################################
testthat::context('Resource #descriptor (expand)')
########################################################
test_that('general resource', {
  descriptor = '{
  "name": "name",
  "data": "data"
}'
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor, 
               helpers.from.json.to.list(
                 '{"name": "name","data": "data","profile": "data-resource","encoding": "utf-8"}'))
  })

test_that('tabular resource schema', {
  descriptor = '{
  "name": "name",
  "data": "data",
  "profile": "tabular-data-resource",
  "schema": {
  "fields": [{"name": "name"}]
  }
}'
  target_outcome = helpers.from.json.to.list('{
                                             "name": "name",
                                             "data": "data",
                                             "profile": "tabular-data-resource",
                                             "encoding": "utf-8",
                                             "schema": {
                                             "fields": [{"name": "name", "type": "string", "format": "default"}],
                                             "missingValues": [""]
                                             }
  }')
  
  resource = Resource.load(descriptor)
  
  expect_equal(resource$descriptor[sort(names(resource$descriptor))], target_outcome[sort(names(target_outcome))])
})



test_that('tabular resource dialect', {
  
  descriptor =  '{
  "name": "name",
  "data": "data",
  "profile": "tabular-data-resource",
  "dialect": {
  "delimiter": "custom"
  }
}'

  resource = Resource.load(descriptor)
  
  target = helpers.from.json.to.list('{
                                     "name": "name",
                                     "data": "data",
                                     "profile": "tabular-data-resource",
                                     "encoding": "utf-8",
                                     "dialect": {
                                     "delimiter": "custom",
                                     "doubleQuote": true,
                                     "lineTerminator": "\\r\\n",
                                     "quoteChar": "\\"",
                                     "escapeChar": "\\\\",
                                     "skipInitialSpace": true,
                                     "header": true,
                                     "caseSensitiveHeader": false
                                     }
}')
  
  expect_equal(resource$descriptor[sort(names(resource$descriptor))], target[sort(names(target))]) # extra sorting to match lists
  })




#######################################################
testthat::context('Resource #source/sourceType')
########################################################

test_that('inline', {
  descriptor = '{
  "name": "name",
  "data": "data",
  "path": ["path"]
}'
  resource = Resource.load(descriptor)
  expect_equal(resource$source, 'data')
  expect_true(resource$inline)
  })


test_that('local', {
  descriptor = '{
  "name": "name",
  "path": ["table.csv"]
}'
  resource = Resource.load(descriptor, basePath= 'data')
  expect_equal(resource$source, 'data/table.csv')
  expect_true(resource$local)
  })

test_that('local base no base path', {
  descriptor = '{
  name: "name",
  path: ["table.csv"]
}'

  expect_error(Resource.load (descriptor,basePath= NULL))
  })

test_that('local bad not safe absolute', {
  descriptor = '{
  "name": "name",
  "path": ["/fixtures/table.csv"]
}'
  expect_error(Resource.load (descriptor,basePath= 'data'))
  })


test_that('local bad not safe traversing', {
  descriptor = '{
  "name": "name",
  "path": ["../fixtures/table.csv"]
}'
  expect_error(Resource.load (descriptor,basePath= 'data'))
})

test_that('remote', {
  descriptor = '{
  "name": "name",
  "path": ["http://example.com//table.csv"]
}'
  resource = Resource.load(descriptor)
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_true(resource$remote)
})

test_that('remote path relative and base path remote', {
  descriptor = '{
  "name": "name",
  "path": ["table.csv"]
}'
  resource = Resource.load(descriptor, basePath='http://example.com/')
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_true(resource$remote)
})

test_that('remote path remote and base path remote', {
  descriptor = '{
  "name": "name",
  "path": ["http://example1.com/table.csv"]
}'
  resource = Resource.load(descriptor, basePath= 'http://example2.com/')
  expect_equal(resource$source, 'http://example1.com/table.csv')
  expect_true(resource$remote)
})

test_that('multipart local', {
  descriptor = '{
  "name": "name",
  "path": ["chunk1.csv", "chunk2.csv"]
}'
  resource = Resource.load(descriptor, basePath = 'data')
  expect_equal(resource$source, unlist(helpers.from.json.to.list('["data/chunk1.csv", "data/chunk2.csv"]')))
  expect_equal(resource$local, TRUE)
  expect_true(resource$multipart)
})

test_that('multipart local bad no base path', {
  descriptor = '{
  name: "name",
  path: ["chunk1.csv", "chunk2.csv"],
}'

  expect_error(Resource.load(descriptor,basePath = NULL))
  })

test_that('multipart local bad not safe absolute', {
  descriptor = '{
  "name": "name",
  "path": ["/fixtures/chunk1.csv", "chunk2.csv"]
}'
  expect_error(Resource.load(descriptor,basePath = 'data'))
  })

test_that('multipart local bad not safe traversing', {
  descriptor = '{
  "name": "name",
  "path": ["chunk1.csv", "../fixtures/chunk2.csv"]
}'
  expect_error(Resource.load(descriptor,basePath = 'data'))
  
})

test_that('multipart remote', {
  descriptor = '{
  "name": "name",
  "path": ["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]
}'
  resource = Resource.load(descriptor)
  expect_equal(resource$source,
               unlist(helpers.from.json.to.list('["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]')))
  expect_true(resource$remote)
  expect_true(resource$multipart)
})

test_that('multipart remote path relative and base path remote', {
  descriptor = '{
  "name": "name",
  "path": ["chunk1.csv", "chunk2.csv"]
}'
  resource = Resource.load(descriptor, basePath = 'http://example.com')
  expect_equal(resource$source,
               unlist(helpers.from.json.to.list('["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]')))
  expect_true(resource$remote)
  expect_true(resource$multipart)
  })


test_that('multipart remote path remote and base path remote', {
  descriptor = '{
  "name": "name",
  "path": ["chunk1.csv", "http://example2.com/chunk2.csv"]
}'
  resource = Resource.load(descriptor, basePath = 'http://example1.com')
  expect_equal(resource$source,
               unlist(helpers.from.json.to.list('["http://example1.com/chunk1.csv", "http://example2.com/chunk2.csv"]')))
  expect_true(resource$remote)
  expect_true(resource$multipart)
  })

# #######################################################
# testthat::context('Resource #rawRead')
# ########################################################

# test_that('it raw reads local file source', {
#   descriptor = '{"path": "inst/data/data.csv"}'
#   resource = Resource.load(descriptor, basePath= "")
#   bytes = resource$rawRead()
#   assert.include(toString(bytes), 'name,size')
# })



#######################################################
testthat::context('Resource #table')
########################################################

test_that('general resource', {
  descriptor = '{
  "name": "name",
  "data": "data"
}'
  resource = Resource.load(descriptor)
  expect_equal(resource$table, NULL)
  })

# test_that('tabular resource inline', {
#   descriptor = '{
#   "name": "example",
#   "profile": "tabular-data-resource",
#   "data": [
#   ["height", "age", "name"],
#   [180, 18, "Tony"],
#   [192, 32, "Jacob"]
#   ],
#   "schema": {
#   "fields": [
#   {"name": "height", "type": "integer"},
#   {"name": "age", "type": "integer"},
#   {"name": "name", "type": "string"}
#   ]
#   }
# }'
# 
#   resource = Resource.load(descriptor)
#   # expect_equal(class(resource$table), c("Table","R6"))
#   expect_equal(resource$table$read(cast = FALSE),
#                helpers.from.json.to.list('[[180, 18, "Tony"], [192, 32, "Jacob"]]'))
# })


# test_that('tabular resource local', {
#   
#   # Prepare
#   descriptor = '{
#   "name": "example",
#   "profile": "tabular-data-resource",
#   "path": ["inst//data/dp1/data.csv"],
#   "schema": {
#   "fields": [
#   {"name": "name", "type": "string"},
#   {"name": "size", "type": "integer"}
#   ]
#   }
#   }'
#   
#   resource = Resource.load(descriptor, basePath ='inst/data')
# 
#   expect_equal(as.vector(class(resource$table)), c("Table","R6"))
#   
#   ### fix tableschema.r read from csv
#   # expect_equal(resource$table$read(cast = FALSE), helpers.from.json.to.list('[
#   #                                                                           ["gb", 100],
#   #                                                                           ["us", 200],
#   #                                                                           ["cn", 300]
#   #                                                                           ]'))
#   })



#######################################################
testthat::context('Resource #infer')
########################################################

test_that('preserve resource format from descriptor ', {
  descriptor= '{"path": "inst/data/data.csvformat", "format": "csv"}'
  resource = Resource.load(descriptor)
  expect_equal(resource$infer(),
               helpers.from.json.to.list(
                 '{
                 "path":"inst/data/data.csvformat",
                 "format":"csv",
                 "profile":"data-resource",
                 "encoding":"utf-8"
                 }')
)
})

# '{
# "encoding":"utf-8",
# "format":"csv",
# "mediatype":"text/csv",
# "name":"data",
# "path":"data/data.csvformat",
# "profile":"tabular-data-resource",
# "schema":{"fields":[
# {"format":"default","name":"city","type":"string"},
# {"format":"default","name":"population","type":"integer"}],
# "missingValues":[""]
# }}'