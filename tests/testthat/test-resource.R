library(datapackage.r)
library(testthat)
library(httptest)
library(httr)
library(curl)
library(jsonlite)


# Tests

testthat::context("Resource")

#######################################################
testthat::context("Resource #load")
########################################################

test_that('works with base descriptor', {
  
  descriptor <- '{"name":"name","data":["data"]}'
  resource <- Resource.load(descriptor)
  
  expect_equal(resource$name, 'name')
  expect_false(resource$tabular)
  expect_equal(resource$descriptor, 
               expandResourceDescriptor(helpers.from.json.to.list(descriptor)))
  expect_true(resource$inline)
  expect_equal(resource$source, list("data"))
  expect_null(resource$table)
})

test_that('works with tabular descriptor', {
  
  descriptor <- '{"name":"name","data":["data"],"profile":"tabular-data-resource"}' 
  resource <- Resource.load(descriptor)
  
  expect_equal(resource$name, 'name')
  expect_true(resource$tabular)
  expect_equal(resource$descriptor,
               expandResourceDescriptor(helpers.from.json.to.list(descriptor)))
  expect_true(resource$inline)
  expect_true(resource$checkRelations())
  expect_equal(resource$source, list("data"))
})


#######################################################
testthat::context('Resource #descriptor (retrieve)')
########################################################

test_that('object', {
  
  descriptor <- '{"name": "name","data": "data"}'
  resource <- Resource.load(descriptor)
  
  expect_equal(resource$descriptor,
               expandResourceDescriptor(helpers.from.json.to.list(descriptor)))
})


test_that('string remote path', {
  
  fileName <- system.file('extdata/data-resource.json', package = "datapackage.r")
  contents <- helpers.from.json.to.list(fileName)
  
  descriptor <- 'https://httpbin.org/data-resource/'
  
  httptest::with_mock_API({
    resource <- Resource.load(descriptor)
  })
  
  expect_equal(resource$descriptor,
               expandResourceDescriptor(descriptor = contents))
})


test_that('string remote path bad', {
  
  descriptor <- 'https://httpbin.org/bad-path.json'
  
  expect_error(
    with_mock(
      `httr:::request_perform` = function()
        httptest::fake_response(httr::GET(descriptor), status_code = 500) ,
      `httptest::request_happened` = expect_message,
      eval.parent(Resource.load(descriptor)),
      "Can not retrieve remote"
    )
  )
})

test_that('string local path', {
  
  fileName <- system.file('extdata/data-resource.json', package = "datapackage.r")
  contents <- helpers.from.json.to.list(fileName)
  descriptor  <- 'inst/extdata/data-resource.json'
  resource <- Resource.load(descriptor)
  
  expect_equal(resource$descriptor, expandResourceDescriptor(contents))
})

test_that('string local bad path', {
  
  descriptor <- 'bad-path.json'
  expect_error(Resource.load(descriptor))
})

#########################################################
testthat::context('Resource #descriptor (dereference)')
#########################################################

test_that('general', {
  descriptor <- system.file('extdata/data-resource-dereference.json', package = "datapackage.r")
  resource <- Resource.load(descriptor)
  
  expect_equal(resource$descriptor,
               expandResourceDescriptor(
                 helpers.from.json.to.list(
                   '{"name": "name",  "data": "data","schema": {"fields": [{"name": "name"}]},"dialect": {"delimiter": ","},"dialects": {"main": {"delimiter": ","}}}'
                 )
               ))
})

test_that('general strict', {
  descriptor <- system.file('extdata/data-resource-dereference.json', package = "datapackage.r")
  resource <- Resource.load(descriptor,strict = TRUE)
  
  expect_equal(resource$descriptor,
               expandResourceDescriptor(
                 helpers.from.json.to.list(
                   '{"name": "name",  "data": "data","schema": {"fields": [{"name": "name"}]},"dialect": {"delimiter": ","},"dialects": {"main": {"delimiter": ","}}}'
                 )
               ))
})


test_that('pointer', {
  descriptor <- '{"name": "name","data": "data","schema": "#/schemas/main","schemas": {"main": {"fields": [{"name": "name"}]}}}'
  resource <- Resource.load(descriptor)
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
  descriptor <- '{"name": "name", "data": "data", "schema": "#/schemas/main"}'
  expect_error(Resource.load(descriptor), 'Not resolved Pointer URI')
  
})


test_that('remote', {
  descriptor <- helpers.from.json.to.list('{"name": "name", "data": "data", "schema": "http://example.com/schema"}')
  
  resource <- testthat::with_mock(
    `curl:::curl` = function(txt, handle) {
      httptest::fake_response(
        httr::GET(descriptor$schema),
        status_code = 200,
        content = list(fields = list(list(name = "name")))
      )
    },
    `httptest::request_happened` = expect_message,
    eval.parent(Resource.load(descriptor))
  )
  expect_equal(resource$descriptor,
               expandResourceDescriptor(descriptor = list(
                 name = 'name',
                 data = 'data',
                 schema = list(fields = list(list(name = 'name')))
               )))
})


test_that('remote bad', {
  descriptor <- helpers.from.json.to.list('{
                                         "name": "name",
                                         "data": "data",
                                         "schema": "http://example.com/schema"
}')
  
  expect_error(with_mock(
    `curl:::curl` = function(txt, handle) {
      stop('Could not resolve host')
    },
    `httptest::request_happened` = expect_message,
    eval.parent(Resource.load(descriptor))
  ), 'Not resolved Remote URI')
  
  
})

#
test_that('local', {
  descriptor <- '{
                  "name": "name",
                  "data": "data",
                  "schema": "table-schema.json"
                }'
  resource <- Resource.load(descriptor, basePath = 'inst/extdata')
  expect_equal(resource$descriptor, 
               expandResourceDescriptor(helpers.from.json.to.list('{"name": "name","data": "data","schema": {"fields": [{"name": "name"}]} }')))
})

test_that('local bad', {
  descriptor <- '{
                  "name": "name",
                  "data": "data",
                  "schema": "bad-path.json"
                }'
  expect_error(Resource.load(descriptor, basePath = 'inst/extdata'))
  
})

test_that('local bad not safe', {
  descriptor <- '{
                  "name": "name",
                  "data": "data",
                  "schema": "../extdata/table-schema.json"
                }'
  expect_error(Resource.load(descriptor, basePath = 'inst/extdata'), "Not safe path")
})



#######################################################
testthat::context('Resource #descriptor (expand)')
########################################################

test_that('general resource', {
  descriptor <- '{
                  "name": "name",
                  "data": "data"
                }'
  resource <- Resource.load(descriptor)
  expect_equal(resource$descriptor, helpers.from.json.to.list('{"name": "name","data": "data","profile": "data-resource","encoding": "utf-8"}'))
})

test_that('tabular resource schema', {
  descriptor <- helpers.from.json.to.list('{
                                            "name": "name",
                                            "data": "data",
                                            "profile": "tabular-data-resource",
                                            "schema": {
                                              "fields": [{"name": "name"}]
                                            }
                                          }')
  target_outcome <- helpers.from.json.to.list('{
                                             "name": "name",
                                             "data": "data",
                                             "profile": "tabular-data-resource",
                                             "encoding": "utf-8",
                                             "schema": {
                                                  "fields": [{"name": "name", "type": "string", "format": "default"}],
                                                  "missingValues": [""]
                                             }
                                            }')
  
  resource <- Resource.load(descriptor)
  
  expect_equal(resource$descriptor[sort(names(resource$descriptor))], target_outcome[sort(names(target_outcome))])
})

test_that('tabular resource dialect', {
  descriptor <- helpers.from.json.to.list('{
     "name": "name",
     "data": "data",
     "profile": "tabular-data-resource",
     "dialect": {
       "delimiter": "custom"
     }
   }')
  resource <- Resource.load(descriptor)
  expect_equivalent(resource$descriptor, list(
    name = 'name',
    data = 'data',
    profile = 'tabular-data-resource',
    dialect = list(
      delimiter = 'custom',
      doubleQuote = TRUE,
      lineTerminator = '\r\n',
      quoteChar = '"',
      escapeChar = '\\',
      skipInitialSpace = TRUE,
      header = TRUE,
      caseSensitiveHeader = FALSE
    ),
    encoding = 'utf-8'
    
  ))
})



#######################################################
testthat::context('Resource #source/sourceType')
########################################################

test_that('inline', {
  descriptor <- '{
  "name": "name",
  "data": "data",
  "path": ["path"]
}'
  resource <- Resource.load(descriptor)
  expect_equal(resource$source, 'data')
  expect_true(resource$inline)
})


test_that('local', {
  descriptor <- '{
  "name": "name",
  "path": ["table.csv"]
}'
  resource <- Resource.load(descriptor, basePath = 'inst/extdata')
  expect_equal(resource$source, 'inst/extdata/table.csv')
  expect_true(resource$local)
})

test_that('local base no base path', {
  descriptor <- '{
  "name": "name",
  "path": ["table.csv"]
}'
  expect_error(Resource.load(descriptor, basePath = NULL), "requires base path")
})

test_that('local bad not safe absolute', {
  descriptor <- '{
  "name": "name",
  "path": ["/fixtures/table.csv"]
}'
  expect_error(Resource.load(descriptor,basePath = 'extdata'), "not safe")
})


test_that('local bad not safe traversing', {
  descriptor <- '{
  "name": "name",
  "path": ["../fixtures/table.csv"]
}'
  expect_error(Resource.load(descriptor,basePath = 'extdata'), "not safe")
})

test_that('remote', {
  descriptor <- '{
  "name": "name",
  "path": ["http://example.com//table.csv"]
}'
  resource <- Resource.load(descriptor)
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_true(resource$remote)
})

test_that('remote path relative and base path remote', {
  descriptor <- '{
  "name": "name",
  "path": ["table.csv"]
}'
  resource <- Resource.load(descriptor, basePath = 'http://example.com/')
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_true(resource$remote)
})

test_that('remote path remote and base path remote', {
  descriptor <- '{
  "name": "name",
  "path": ["http://example1.com/table.csv"]
}'
  resource <- Resource.load(descriptor, basePath = 'http://example1.com/')
  expect_equal(resource$source, 'http://example1.com/table.csv')
  expect_true(resource$remote)
})


test_that('multipart local', {
  descriptor <- '{
  "name": "name",
  "path": ["chunk1.csv", "chunk2.csv"]
}'
  resource <- Resource.load(descriptor, basePath = 'extdata')
  expect_equal(resource$source, unlist(jsonlite::fromJSON('["extdata/chunk1.csv", "extdata/chunk2.csv"]')))
  expect_equal(resource$local, TRUE)
  expect_true(resource$multipart)
})



test_that('multipart local bad no base path', {
  descriptor <- helpers.from.json.to.list('{
     "name": "name",
     "path": ["chunk1.csv", "chunk2.csv"]
   }')
  
  expect_error(Resource.load(descriptor = descriptor, basePath = NULL), 'requires base path')
  
})

test_that('multipart local bad not safe absolute', {
  descriptor <- '{
  "name": "name",
  "path": ["/fixtures/chunk1.csv", "chunk2.csv"]
}'
  expect_error(Resource.load(descriptor,basePath = 'extdata'), 'not safe')
})

test_that('multipart local bad not safe traversing', {
  descriptor <- '{
  "name": "name",
  "path": ["chunk1.csv", "../fixtures/chunk2.csv"]
}'
  expect_error(Resource.load(descriptor,basePath = 'extdata'), 'not safe')
  
})

test_that('multipart remote', {
  descriptor <- '{
  "name": "name",
  "path": ["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]
}'
  resource <- Resource.load(descriptor)
  expect_equal(resource$source,
               jsonlite::fromJSON('["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]'))
  expect_true(resource$remote)
  expect_true(resource$multipart)
})

test_that('multipart remote path relative and base path remote', {
  descriptor <- '{
  "name": "name",
  "path": ["chunk1.csv", "chunk2.csv"]
}'
  resource <- Resource.load(descriptor, basePath = 'http://example.com')
  expect_equal(resource$source,
               jsonlite::fromJSON('["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]'))
  expect_true(resource$remote)
  expect_true(resource$multipart)
})


test_that('multipart remote path remote and base path remote', {
  descriptor <- '{
  "name": "name",
  "path": ["chunk1.csv", "http://example2.com/chunk2.csv"]
}'
  resource <- Resource.load(descriptor, basePath = 'http://example1.com')
  expect_equal(resource$source,
               jsonlite::fromJSON('["http://example1.com/chunk1.csv", "http://example2.com/chunk2.csv"]'))
  expect_true(resource$remote)
  expect_true(resource$multipart)
})

########################################################
testthat::context('Resource #rawRead')
########################################################

test_that('it raw reads local file source', {
  
  resource <- Resource.load('{"path": "inst/extdata/data.csv"}', basePath = getwd())
  bytes <- resource$rawRead()
  expect_true(grepl('name,size', intToUtf8(bytes), fixed = TRUE))
})


#######################################################
testthat::context('Resource #table')
########################################################


test_that('general resource', {
  descriptor <- '{
  "name": "name",
  "data": "data"
}'
  resource <- Resource.load(descriptor)
  expect_equal(resource$table, NULL)
})


test_that('tabular resource inline', {
  descriptor <- '{
                  "name": "example",
                  "profile": "tabular-data-resource",
                  "data": [
                    ["height", "age", "name"],
                    ["180", "18", "Tony"],
                    ["192", "32", "Jacob"]
                    ],
                  "schema": {
                    "fields": [{
                      "name": "height",
                      "type": "integer"
                    },
                    {
                      "name": "age",
                      "type": "integer"
                    },
                    {
                      "name": "name",
                      "type": "string"
                    }
                    ]
                  }
                }'
  resource <- Resource.load(descriptor)
  expect_equal(class(resource$table), c("Table","R6"))
  expect_equal(resource$table$read(), 
               helpers.from.json.to.list('[
                                            [180, 18, "Tony"],
                                            [192, 32, "Jacob"]
                                           ]'))
})

test_that('tabular resource local', {
  descriptor <- '{
    "name": "example",
    "profile": "tabular-data-resource",
    "path": ["inst/extdata/dp1/data.csv"],
    "schema": {
      "fields": [{
        "name": "name",
        "type": "string"
      },
      {
        "name": "size",
        "type": "integer"
      }
      ]
    }
  }'
  
  resource <- Resource.load(descriptor)
  expect_equal(class(resource$table), c("Table","R6"))
  expect_equal(resource$table$read(), 
               helpers.from.json.to.list('[
                                        ["gb", 100],
                                         ["us", 200],
                                         ["cn", 300]
                                         ]'))
})

#######################################################
testthat::context('Resource #infer')
#######################################################

test_that('preserve resource format from descriptor ', {
  descriptor <- '{"path": "inst/extdata/data.csvformat.txt", "format": "csv"}'
  resource <- Resource.load(descriptor)
  expect_equal(resource$infer(),
               helpers.from.json.to.list(
                 '{
"path": "inst/extdata/data.csvformat.txt",
"format": "csv",
"profile": "tabular-data-resource",
        "encoding": "utf-8",
                 "name": "data",
                 "mediatype": "text/csv",
                 "schema": {"fields": [
                 {"name": "city",  "type": "string","format": "default"},
                 { "name": "population","type": "integer",  "format": "default"}],
                 "missingValues": [""]
                 }
}'))
})

#######################################################
testthat::context('Resource #dialect')
#######################################################

test_that('it supports dialect.delimiter', {
  descriptor <-helpers.from.json.to.list('{
                                           "profile": "tabular-data-resource",
                                           "path": "inst/extdata/data.dialect.csv",
                                           "schema": {
                                             "fields": [{
                                               "name": "name"
                                             }, {
                                               "name": "size"
                                             }]
                                           },
                                           "dialect": {
                                             "delimiter": ","
                                           }
                                         }')
  resource <- Resource.load(descriptor)
  rows <- resource$read(keyed = TRUE)
  expect_equal(rows, helpers.from.json.to.list('[{
                                                   "name": "gb",
                                                   "size": "105"
                                                 },
                                                   {
                                                     "name": "us",
                                                     "size": "205"
                                                   },
                                                   {
                                                     "name": "cn",
                                                     "size": "305"
                                                   }
                                                   ]'))
})

test_that('it supports dialect.delimiter and true relations', {
  descriptor <-helpers.from.json.to.list('{
                                           "profile": "tabular-data-resource",
                                           "path": "inst/extdata/data.dialect.csv",
                                           "schema": {
                                             "fields": [{
                                               "name": "name"
                                             }, {
                                               "name": "size"
                                             }]
                                           },
                                           "dialect": {
                                             "delimiter": ","
                                           }
                                         }')
  resource <- Resource.load(descriptor)
  rows <- resource$read(keyed = TRUE, relations = TRUE)
  expect_equal(rows, helpers.from.json.to.list('[{
                                                   "name": "gb",
                                                   "size": "105"
                                                 },
                                                   {
                                                     "name": "us",
                                                     "size": "205"
                                                   },
                                                   {
                                                     "name": "cn",
                                                     "size": "305"
                                                   }]'))
})

#######################################################
testthat::context('Resource #commit')
#######################################################

test_that('commit', {
  descriptor <- '{"name":"name","data":["data"],"profile":"data-resource"}' 
  resource <- Resource.load(descriptor)
  expect_equal(resource$name, 'name')
  expect_equal(resource$profile$name, "data-resource")
  expect_false(resource$tabular)
  resource$descriptor$profile <- "tabular-data-resource"
  resource$commit()
  expect_true(resource$tabular)
  expect_equal(resource$profile$name, "tabular-data-resource")
})

###################################################
testthat::context("Package #save")
###################################################

test_that("general", {
  descriptor <- '{"resources": [{"name": "name", "data": ["data"]}]}'
  dataResource <- Resource.load(descriptor)
  dataResource$save("inst/extdata")
  
  expect_true(file.exists("inst/extdata/resource.json"))
})