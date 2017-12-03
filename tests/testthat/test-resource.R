library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)
library(crul)
library(webmockr)

# Tests
testthat::context("Resource")


#######################################################
testthat::context("Resource #load")
########################################################


test_that('works with base descriptor', {
  descriptor=jsonlite::fromJSON('{"name":"name","data":["data"]}')
  resource = Resource.load(descriptor)

  expect_equal(resource$name,'name')
  expect_false(resource$tabular)
  expect_equal(resource$descriptor, expandResourceDescriptor(descriptor))
  expect_true(resource$inline)
  expect_equal(resource$source, "data")
  expect_null(resource$table)
})

test_that('works with tabular descriptor', {
  descriptor=jsonlite::fromJSON('{"name":"name","data":["data"],"profile":"tabular-data-resource"}')
  resource = Resource.load(descriptor)
  expect_equal(resource$name, 'name')
  expect_true(resource$tabular)
  expect_equal(resource$descriptor, expandResourceDescriptor(descriptor))
  expect_true(resource$inline)
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
test_that('string path', {
  contents = jsonlite::fromJSON('inst/data/data-resource.json')
  descriptor = 'https://httpbin.org/data-resource.json'

  # Mocks
  (x = HttpClient$new(url = descriptor))
  (res = x$patch(path = "patch",
                  encode = "json",
                  body = jsonlite::fromJSON('{"name": "name","data": "data"}')
  ))
  contents=jsonlite::fromJSON(res$parse("UTF-8"))$json
  ##
  
  resource = Resource.load(descriptor)
  
  # needs extra sorting
  expect_equal(resource$descriptor[sort(names(resource$descriptor))], 
               expandResourceDescriptor(contents)[sort(names(resource$descriptor))])
})


test_that('string remote path bad', {
  descriptor = 'https://httpbin.org/bad-path.json'
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
    expect_error(Resource.load(descriptor))
})



#######################################################
testthat::context('Resource #descriptor (dereference)')
########################################################

test_that('general', {
  descriptor = 'inst/data/data-resource-dereference.json'
    resource = Resource.load(descriptor)
    desired_outcome = expandResourceDescriptor(jsonlite::fromJSON('{"name": "name",  "data": "data","schema": {"fields": [{"name": "name"}]},"dialect": {"delimiter": ","},"dialects": {"main": {"delimiter": ","}}}'))
    expect_true(identical(resource$descriptor,desired_outcome ))

})

test_that('pointer', {
  descriptor = jsonlite::fromJSON('{"name": "name","data": "data","schema": "#/schemas/main","schemas": {"main": {"fields": [{"name": "name"}]}}}')
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor,
               expandResourceDescriptor( jsonlite::fromJSON('{"name":"name","data":"data","schema":{"fields":[{"name":"name"}]},"schemas":{"main":{"fields":[{"name":"name"}]}}}' )))
})


test_that('pointer bad', {
  descriptor = jsonlite::fromJSON('{"name": "name", "data": "data", "schema": "#/schemas/main"}')
  expect_error(Resource.load(descriptor)) # 'Not resolved Pointer URI'
})

test_that('remote', {
  descriptor = jsonlite::fromJSON('{"name": "name", "data": "data", "schema": "https://httpbin.org/schema"}')

  # Mocks
  (x = HttpClient$new(url = descriptor$schema))
  (res = x$patch(path = "patch",
                 encode = "json",
                 body = jsonlite::fromJSON('{"fields": [{"name": "name"}]}')
  ))
  contents=jsonlite::fromJSON(res$parse("UTF-8"))$json
  descriptor$schema=contents
  ##
  
  
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor, 
               expandResourceDescriptor( 
                 jsonlite::fromJSON('{"name": "name", "data": "data", "schema": {"fields": [{"name": "name"}]}}')))
})

test_that('remote bad', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "data": "data",
    "schema": "https://httpbin.org/schema"
  }')
  
  # Mocks
  (x = HttpClient$new(url = 'https://httpbin.org/status/404'))
  (res = x$get(
  ))
  contents=res$parse("UTF-8")
  descriptor$schema=contents
  ##
  expect_error(Resource.load(descriptor))
})

test_that('local', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "data": "data",
    "schema": "table-schema.json"
    }')
  resource = Resource.load(descriptor, basePath = 'inst/data')
  expect_equal(resource$descriptor, 
               expandResourceDescriptor(jsonlite::fromJSON('{"name": "name","data": "data","schema": {"fields": [{"name": "name"}]} }')))
})

test_that('local bad', {
  descriptor = jsonlite::fromJSON('{"name": "name",
                                    "data": "data",
                                    "schema": "bad-path.json"}')
  expect_error(Resource.load(descriptor, basePath = 'inst/data'))
  
})

test_that('local bad not safe', {
  descriptor = jsonlite::fromJSON('{"name": "name",
                                    "data": "data",
                                  "schema": "../data/table_schema.json"}')
  expect_error(Resource.load(descriptor, basePath = 'inst/data'))
})



# #######################################################
testthat::context('Resource #descriptor (expand)')
# ########################################################

test_that('general resource', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "data": "data"
  }')
  resource = Resource.load(descriptor)
  expect_equal(resource$descriptor,jsonlite::fromJSON('{"name": "name","data": "data","profile": "data-resource","encoding": "utf-8"}'))
})

test_that('tabular resource schema', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "data": "data",
    "profile": "tabular-data-resource",
    "schema": {
      "fields": [{"name": "name"}]
    }
  }')
  resource = Resource.load(descriptor)
  target_outcome = jsonlite::fromJSON('{
    "name": "name",
    "data": "data",
    "profile": "tabular-data-resource",
    "encoding": "utf-8",
    "schema": {
      "fields": [{"name": "name", "type": "string", "format": "default"}],
      "missingValues": [""]
    }
  }')
  expect_equal(resource$descriptor[sort(names(resource$descriptor))], target_outcome[sort(names(target_outcome))])
})

test_that('tabular resource dialect', {

  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "data": "data",
    "profile": "tabular-data-resource",
    "dialect": {
      "delimiter": "custom"
    }
  }')

  resource = Resource.load(descriptor)

  target = jsonlite::fromJSON('{
	"name": "name",
	"data": "data",
	"profile": "tabular-data-resource",
	"encoding": "utf-8",
	"dialect": {
		"delimiter": "custom",
		"doubleQuote": "TRUE",
		"lineTerminator": "\\r\\n",
		"quoteChar": "\\"",
		"escapeChar": "\\\\",
		"skipInitialSpace": "TRUE",
		"header": "TRUE",
		"caseSensitiveHeader": "FALSE"
	}
}')
  target$dialect$caseSensitiveHeader = FALSE
  target$dialect$header = TRUE
  target$dialect$skipInitialSpace = TRUE
  target$dialect$doubleQuote = TRUE
  expect_equal(resource$descriptor[sort(names(resource$descriptor))], target[sort(names(resource$descriptor))])

})


# #######################################################
testthat::context('Resource #source/sourceType')
# ########################################################

test_that('inline', {
  descriptor = jsonlite::fromJSON('{
  "name": "name",
  "data": "data",
  "path": ["path"]
  }')
  resource = Resource.load(descriptor)
  expect_equal(resource$source, 'data')
  expect_true(resource$inline)
})

test_that('local', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["table.csv"]
  }')
  resource = Resource.load(descriptor, basePath= 'data')
  expect_equal(resource$source, 'data/table.csv')
  expect_true(resource$local)
})

# test_that('local base no base path', {
#   descriptor = jsonlite::fromJSON('{"name": "name","path": ["table.csv"]}')
#   expect_error(Resource.load(descriptor))
# })
 
test_that('local bad not safe absolute', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["/fixtures/table.csv"]
  }')
  expect_error(Resource.load (descriptor,basePath= 'data'))
})

test_that('local bad not safe traversing', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["../fixtures/table.csv"]
  }')
  expect_error(Resource.load (descriptor,basePath= 'data'))
})

test_that('remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["http://example.com//table.csv"]
  }')
  resource = Resource.load(descriptor)
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_true(resource$remote)
})

test_that('remote path relative and base path remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["table.csv"]
  }')
  resource = Resource.load(descriptor, basePath='http://example.com/')
  expect_equal(resource$source, 'http://example.com//table.csv')
  expect_true(resource$remote)
})

test_that('remote path remote and base path remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["http://example1.com/table.csv"]
  }')
  resource = Resource.load(descriptor, basePath= 'http://example2.com/')
  expect_equal(resource$source, 'http://example1.com/table.csv')
  expect_true(resource$remote)
})

test_that('multipart local', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["chunk1.csv", "chunk2.csv"]
  }')
  resource = Resource.load(descriptor, basePath = 'data')
  expect_equal(resource$source, unlist(jsonlite::fromJSON('["data/chunk1.csv", "data/chunk2.csv"]')))
  #expect_equal(resource$local, TRUE)
  expect_true(resource$multipart)
})

# test_that('multipart local bad no base path', {
#   descriptor = jsonlite::fromJSON('{
#     "name": "name",
#     "path": ["chunk1.csv", "chunk2.csv"]
#   }')
#   expect_error(Resource.load(descriptor,basePath= ""))
# })

test_that('multipart local bad not safe absolute', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["/fixtures/chunk1.csv", "chunk2.csv"]
  }')
  expect_error(Resource.load(descriptor,basePath = 'data'))
})

test_that('multipart local bad not safe traversing', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["chunk1.csv", "../fixtures/chunk2.csv"]
  }')
  expect_error(Resource.load(descriptor,basePath = 'data'))
  
})

test_that('multipart remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]
  }')
  resource = Resource.load(descriptor)
  expect_equal(resource$source,
               jsonlite::fromJSON('["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]'))
  #expect_true(resource$remote)
  expect_true(resource$multipart)
})

test_that('multipart remote path relative and base path remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["chunk1.csv", "chunk2.csv"]
  }')
  resource = Resource.load(descriptor, basePath = 'http://example.com')
  expect_equal(resource$source,
              jsonlite::fromJSON('["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]'))
  #expect_true(resource$remote)
  expect_true(resource$multipart)
})

test_that('multipart remote path remote and base path remote', {
  descriptor = jsonlite::fromJSON('{
    "name": "name",
    "path": ["chunk1.csv", "http://example2.com/chunk2.csv"]
  }')
  resource = Resource.load(descriptor, basePath = 'http://example1.com')
  expect_equal(resource$source,
               jsonlite::fromJSON('["http://example1.com/chunk1.csv", "http://example2.com/chunk2.csv"]'))
  #expect_true(resource$remote)
  expect_true(resource$multipart)
})




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
