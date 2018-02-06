library(datapackage.r)
library(testthat)
library(stringr)
library(crul)
library(webmockr)
library(httptest)

# Tests

###################################################
testthat::context("Load")
###################################################

test_that('initializes with Object descriptor', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  
  expect_equal(dataPackage$descriptor,expandPackageDescriptor(descriptor))
})

test_that('initializes with URL descriptor', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(
    'https://raw.githubusercontent.com/frictionlessdata/datapackage-js/master/data/dp1/datapackage.json')
  
  expect_equal(dataPackage$descriptor, expandPackageDescriptor(descriptor))
})


test_that('throws errors for invalid datapackage in strict mode', {
  expect_error(Package.load("{}",strict = TRUE))
})


test_that('stores errors for invalid datapackage', {
  dataPackage = Package.load()
  
  expect_type(dataPackage$errors, "list")
  expect_type(dataPackage$errors[[1]], "character")
  expect_match(dataPackage$errors[[1]], "Descriptor validation error")
  expect_false(dataPackage$valid)
})

test_that('loads relative resource', {
  
  descriptor = 'https://raw.githubusercontent.com/frictionlessdata/datapackage-js/master/data/dp1/datapackage.json'
  dataPackage = Package.load(descriptor)
  dataPackage$resources[[1]]$descriptor$profile = 'tabular-data-resource'
  data = dataPackage$resources[[1]]$table$read()
  
  expect_equal(data, list(list('gb', 100), list('us', 200), list('cn', 300)))
})


test_that('loads resource from absolute URL',  {
  
  descriptor = 'https://dev.keitaro.info/dpkjs/datapackage.json'
  dataPackage = Package.load(descriptor)
  dataPackage$resources[[1]]$descriptor$profile = 'tabular-data-resource'
  table = dataPackage$resources[[1]]$table
  data = table$read()
  
  expect_equal(data, list(list('gb', 100), list('us', 200), list('cn', 300)))
})

test_that('loads resource from absolute URL disregarding basePath', {
  
  descriptor = 'https://dev.keitaro.info/dpkjs/datapackage.json'
  dataPackage = Package.load(descriptor, basePath = 'local/basePath')
  dataPackage$resources[[1]]$descriptor$profile = 'tabular-data-resource'
  table = dataPackage$resources[[1]]$table
  data = table$read()
  
  expect_equal(data, list(list('gb', 100), list('us', 200), list('cn', 300)))
})


test_that('loads remote resource with basePath',  {
  
  descriptor = 'https://dev.keitaro.info/dpkjs/datapackage.json'
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata')
  dataPackage$resources[[2]]$descriptor$profile = 'tabular-data-resource'
  table = dataPackage$resources[[2]]$table
  data = table$read()
  
  expect_equal(data, list(list('gb', 105), list('us', 205), list('cn', 305)))
})



###################################################
testthat::context("Package #descriptor (retrieve)")
###################################################

test_that('object', {
  descriptor = '{"resources": [{"name": "name", "data": ["data"]}]}'
  dataPackage = Package.load(descriptor)
  
  expect_equal(dataPackage$descriptor, expandPackageDescriptor(helpers.from.json.to.list(descriptor)))
})

###################################
testthat::context("Package #load")
###################################

test_that('string remote path', {
  
  descriptor = 'http://example.com/data-package'
  # Mocks
  contents =  helpers.from.json.to.list(system.file('extdata/data-package.json', package = "datapackage.r"))
  httptest::with_mock_API({
    dataPackage = Package.load(descriptor)
  })
  
  expect_equal(dataPackage$descriptor, expandPackageDescriptor(contents))
})

test_that('string remote path bad', {
  descriptor = 'http://example.com/bad-path.json'
  
  expect_error(
    with_mock(
      `httr:::request_perform` = function()
        httptest::fakeResponse(httr::GET(descriptor), status_code = 500) ,
      `httptest::request_happened` = expect_message,
      eval.parent(Package.load(descriptor)),
      "Can not retrieve remote"
    )
  )
  
})


test_that('string local path', {
  contents =  system.file('extdata/data-package.json', package = "datapackage.r")
  descriptor = system.file('extdata/data-package.json', package = "datapackage.r")
  dataPackage = Package.load(descriptor)
  
  expect_equal(dataPackage$descriptor, expandPackageDescriptor(helpers.from.json.to.list(contents)))
})

test_that('string local path bad', {
  descriptor = 'inst/extdata/bad-path.json'
  
  expect_error(Package.load(descriptor),  'Can not retrieve local')
})

######################################################
testthat::context("Package #descriptor (dereference)")
######################################################

test_that('mixed', {
  
  descriptor = system.file('extdata/data-package-dereference.json', package = "datapackage.r")
  dataPackage = Package.load(descriptor)
  target =
    purrr::map(helpers.from.json.to.list('[
                                         {"name": "name1", "data": ["data"], "schema": {"fields": [{"name": "name"}]}},
                                         {"name": "name2", "data": ["data"], "dialect": {"delimiter": ","}}
                                         ]'),expandResourceDescriptor)
  
  expect_equal( dataPackage$descriptor$resources, target)
  
})

test_that('pointer', {
  descriptor = '{
                  "resources": [{
                    "name": "name1",
                    "data": ["data"],
                    "schema": "#/schemas/main"
                  },
                  {
                    "name": "name2",
                    "data": ["data"],
                    "dialect": "#/dialects/0"
                  }
                  ],
                  "schemas": {
                    "main": {
                      "fields": [{
                        "name": "name"
                      }]
                    }
                  },
                  "dialects": [{
                    "delimiter": ","
                  }]
                }'
  
  dataPackage = Package.load(descriptor)
  
  expect_equal(dataPackage$descriptor$resources,  purrr::map(list(list(name = 'name1', data = list('data'), schema = list(fields = list(list(name = 'name')))),
                                                                  list(name = 'name2', data = list('data'), dialect = list(delimiter = ','))), expandResourceDescriptor))
  })

test_that('pointer bad', {
  descriptor = '{
                  "resources": [{
                    "name": "name1",
                    "data": ["data"],
                    "schema": "#/schemas/main"
                  }]
                }'
  
  expect_error(Package.load(descriptor), 'Not resolved Pointer URI')
})


test_that('remote', {
  descriptor = '{
                  "resources": [{
                    "name": "name1",
                    "data": ["data"],
                    "schema": "http://example.com/schema"
                  },
                  {
                    "name": "name2",
                    "data": ["data"],
                    "dialect": "http://example.com/dialect"
                  }
                  ]
                }'
  
  dataPackage <-  with_mock(
    `curl::curl` = function(url, ...) {
      if (url == "http://example.com/schema") {
        httptest::fakeResponse(
          httr::GET("http://example.com/schema"),
          status_code = 200,
          content = list(fields = list(list(name = "name")))
        )
      }
      else if (url == "http://example.com/dialect") {
        httptest::fakeResponse(
          httr::GET("http://example.com/dialect"),
          status_code = 200,
          content = list(delimiter = ",")
        )
      }
    },
    Package.load(descriptor)
)
  
  expect_equal(dataPackage$descriptor$resources,  purrr::map(list(
    list(name = 'name1', data = list('data'), schema = list(fields = list(list(name = 'name')))),
    list(name = 'name2', data = list('data'), dialect = list(delimiter = ',')
    )), expandResourceDescriptor))
})


test_that('remote bad', {
  descriptor = '{
                  "resources": [{
                    "name": "name1",
                    "data": ["data"],
                    "schema": "http://example.com/schema"
                  }]
                }'
  
  expect_error(
    with_mock(
      `curl::curl` = function(url, ...) {
        if (url == "http://example.com/schema") {
          stop('Could not resolve host')
          
        }
        
      },
      Package.load(descriptor)
    ),
    'Not resolved Remote URI')
})


test_that('local', {
  descriptor = '{
                  "resources": [{
                    "name": "name1",
                    "data": ["data"],
                    "schema": "table-schema.json"
                  },
                  {
                    "name": "name2",
                    "data": ["data"],
                    "dialect": "csv-dialect.json"
                  }
                  ]
                }'
  
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata')
  
  expect_equal(dataPackage$descriptor$resources, 
               purrr::map(list(
                 list(name = 'name1', data = list('data'), schema = list(fields = list(list(name = 'name')))),
                 list(name = 'name2', data = list('data'), dialect = list(delimiter = ','))), 
                 expandResourceDescriptor))
  
})

test_that('local bad', {
  descriptor = '{
                  "resources": [{
                    "name": "name1",
                    "data": ["data"],
                    "schema": "bad-path.json"
                  }]
                }'
  
  expect_error(Package.load(descriptor, basePath = 'inst/extdata'), 'Not resolved Local URI')
})

test_that('local bad not safe', {
  descriptor = '{
                   "resources": [{
                     "name": "name1",
                     "data": ["data"],
                     "schema": "../data/table-schema.json"
                   }]
                 }'
  
  expect_error(Package.load(descriptor, basePath = 'inst/data'), 'Not safe path')
})


#################################################
testthat::context("Package #descriptor (expand)")
#################################################

test_that('resource', {
  descriptor = helpers.from.json.to.list('{
                                             "resources": [{
                                               "name": "name",
                                               "data": ["data"]
                                             }]
                                           }')
  target = helpers.from.json.to.list('{
                                        	"profile": "data-package",
                                        		"resources": [{
                                        			"name": "name",
                                        			"data": ["data"],
                                        			"profile": "data-resource",
                                        			"encoding": "utf-8"
                                        		}]
                                        	}')

  dataPackage = Package.load(descriptor)
  
  expect_equal(dataPackage$descriptor[sort(names(target))],target) # sort names by target to match
})

test_that('tabular resource schema', {
  
  descriptor = helpers.from.json.to.list('{
                                            "resources": [{
                                                  "name": "name",
                                                  "data": ["data"],
                                                  "profile": "tabular-data-resource",
                                                  "schema": {
                                                    "fields": [{
                                                      "name": "name"
                                                    }]
                                                  }
                                                }]
                                              }')
  target = helpers.from.json.to.list('{
	                                      "resources": [{
	                                      		"name": "name",
	                                      		"data": ["data"],
	                                      		"profile": "tabular-data-resource",
	                                      		"schema": {
	                                      			"fields": [{
	                                      				"name": "name",
	                                      				"type": "string",
	                                      				"format": "default"
	                                      			}],
	                                      			"missingValues": [""]
	                                      		},
	                                      		"encoding": "utf-8"
	                                      	}],
	                                      	"profile": "data-package"
	                                      }')
  dataPackage = Package.load(descriptor)
  
  expect_equal(dataPackage$descriptor, target)
})

test_that('tabular resource dialect', {
  
  descriptor = helpers.from.json.to.list('{
                                          	"resources": [{
                                          			"name": "name",
                                          			"data": ["data"],
                                          			"profile": "tabular-data-resource",
                                          			"dialect": {
                                          				"delimiter": "custom"
                                          			}
                                          		}]
                                          	}')
  
  target = helpers.from.json.to.list('{
                                       	"resources": [{
                                       			"name": "name",
                                       			"data": ["data"],
                                       			"profile": "tabular-data-resource",
                                       	
                                       			"dialect": {
                                       				"delimiter": "custom",
                                       				"doubleQuote": true,
                                       				"lineTerminator": "\\r\\n",
                                       				"quoteChar": "\\"",
                                       				"escapeChar": "\\\\",
                                       				"skipInitialSpace": true,
                                       				"header": true,
                                       				"caseSensitiveHeader": false
                                       	
                                       			},
                                       			"encoding": "utf-8"
                                       		}],
                                       		"profile": "data-package"
                                       	}')
  dataPackage = Package.load(descriptor)
  
  expect_equal(dataPackage$descriptor, target)
})


###################################################
testthat::context("Package #resources")
###################################################

test_that('names', {
  descriptor = helpers.from.json.to.list(system.file('extdata/data-package-multiple-resources.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata')
  
  expect_length(dataPackage$resources, 2)
  expect_equal(dataPackage$resourceNames, helpers.from.json.to.list('["name1", "name2"]'))
})

test_that('add', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  resource = dataPackage$addResource(helpers.from.json.to.list('{"name": "name", "data": ["test"]}'))
  
  expect_failure(expect_null(resource))
  expect_length(dataPackage$resources, 2)
  expect_equal(dataPackage$resources[[2]]$source, list('test'))
})

test_that('add invalid - throws array of errors in strict mode', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1', strict = TRUE)
  
  expect_error(dataPackage$addResource(list()), 'schemas match')
})

test_that('add invalid - save errors in not a strict mode', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  dataPackage$addResource(list())
  
  expect_match(dataPackage$errors[[1]], "schemas match")
  expect_false(dataPackage$valid)
  
})

test_that('add tabular - can read data', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  dataPackage$addResource(helpers.from.json.to.list('{
                                                          "name": "name",
                                                      		"data": [
                                                      			["id", "name"],
                                                      			["1", "alex"],
                                                      			["2", "john"]
                                                      		],
                                                      		"schema": {
                                                      			"fields": [{
                                                      					"name": "id",
                                                      					"type": "integer"
                                                      				},
                                                      				{
                                                      					"name": "name",
                                                      					"type": "string"
                                                      				}
                                                      			]
                                                      		}
                                                      	}'))
  rows = dataPackage$resources[[2]]$table$read()
  
  expect_equal(rows, list(list(1, 'alex'), list(2, 'john')))
  })

test_that('add with not a safe path - throw an error', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  
  expect_error( dataPackage$addResource(helpers.from.json.to.list('{
                                                                  "name": "name",
                                                                  "path": ["../dp1/data.csv"]}')), 'not safe')
})

test_that('get existent', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  resource = dataPackage$getResource('random')
  
  expect_equal(resource$name, 'random')
})

test_that('get non existent', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  resource = dataPackage$getResource('non-existent')
  
  expect_null(resource)
  
})

test_that('remove existent', {
  descriptor = helpers.from.json.to.list(system.file('extdata/data-package-multiple-resources.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/data')
  
  expect_length(dataPackage$resources, 2)
  expect_length(dataPackage$descriptor$resources, 2)
  expect_equal(dataPackage$resources[[1]]$name, 'name1')
  expect_equal(dataPackage$resources[[2]]$name, 'name2')
  
  resource = dataPackage$removeResource('name2')
  
  expect_length(dataPackage$resources, 1)
  expect_length(dataPackage$descriptor$resources, 1)
  expect_equal(dataPackage$resources[[1]]$name, 'name1')
  expect_equal(resource$name, 'name2')
})

test_that('remove non existent', {
  descriptor = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
  dataPackage = Package.load(descriptor, basePath = 'inst/extdata/dp1')
  resource = dataPackage$removeResource('non-existent')
  
  expect_null(resource)
  expect_length(dataPackage$resources, 1)
  expect_length(dataPackage$descriptor$resources, 1)
})

###################################################
testthat::context("Package #save")
###################################################

test_that("general", {
  descriptor = '{"resources": [{"name": "name", "data": ["data"]}]}'
  dataPackage = Package.load(descriptor)
  dataPackage$save("inst/extdata")
  
  expect_true(file.exists("inst/extdata/package.json"))
})

###################################################
testthat::context("Package #commit")
###################################################

test_that('modified', {
  descriptor = helpers.from.json.to.list('{"resources": [{"name": "name", "data": ["data"]}]}')
  dataPackage = Package.load(descriptor)
  dataPackage$descriptor$resources[[1]]$name = 'modified'
  expect_equal(dataPackage$resources[[1]]$name, 'name')
  result = dataPackage$commit()
  
  expect_equal(dataPackage$resources[[1]]$name, 'modified')
  expect_true(result)
})

test_that('modified invalid in strict mode', {
  descriptor = helpers.from.json.to.list('{"resources": [{"name": "name", "path": "data.csv"}]}')
  dataPackage = Package.load(descriptor, 
                             basePath = 'inst/extdata', strict = TRUE
  )
  dataPackage$descriptor$resources = list()
  
  expect_error(dataPackage$commit(), 'less items than allowed')
})

test_that('not modified', {
  descriptor = helpers.from.json.to.list('{"resources": [{"name": "name", "data": ["data"]}]}')
  dataPackage = Package.load(descriptor)
  result = dataPackage$commit()
  
  expect_equal(dataPackage$descriptor, expandPackageDescriptor(descriptor))
  expect_false(result)
})


###################################################
testthat::context("Package #foreignKeys")
###################################################

DESCRIPTOR = helpers.from.json.to.list('{
                                          "resources": [{
                                            "name": "main",
                                            "data": [
                                              ["id", "name", "surname", "parent_id"],
                                              ["1", "Alex", "Martin", ""],
                                              ["2", "John", "Dockins", "1"],
                                              ["3", "Walter", "White", "2"]
                                              ],
                                            "schema": {
                                              "fields": [{
                                                "name": "id"
                                              },
                                              {
                                                "name": "name"
                                              },
                                              {
                                                "name": "surname"
                                              },
                                              {
                                                "name": "parent_id"
                                              }
                                              ],
                                              "foreignKeys": [{
                                                "fields": "name",
                                                "reference": {
                                                  "resource": "people",
                                                  "fields": "firstname"
                                                }
                                              }]
                                            }
                                          }, {
                                            "name": "people",
                                            "data": [
                                              ["firstname", "surname"],
                                              ["Alex", "Martin"],
                                              ["John", "Dockins"],
                                              ["Walter", "White"]
                                              ]
                                          }]
                                        }')

test_that('should read rows if single field foreign keys is valid', {
  resource = (Package.load(DESCRIPTOR))$getResource('main')
  rows = resource$read(relations = TRUE)
  
  expect_equal(rows, list(
    list('1', list(firstname = 'Alex', surname = 'Martin'), 'Martin', NULL),
    list('2', list(firstname = 'John', surname = 'Dockins'), 'Dockins', '1'),
    list('3', list(firstname = 'Walter', surname = 'White'), 'White', '2')
  ))
})


test_that('should throw on read if single field foreign keys is invalid', {
  descriptor = DESCRIPTOR
  descriptor$resources[[2]]$data[[3]][[1]] = 'Max'
  resource = (Package.load(descriptor))$getResource('main')
  
  expect_error(resource$read(relations = TRUE, "Foreign key"))
}) 


test_that('should read rows if single self field foreign keys is valid', {
  descriptor = DESCRIPTOR
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$fields = 'parent_id'
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$resource = ''
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$fields = 'id'
  resource = (Package.load(descriptor))$getResource('main')
  keyedRows = resource$read(keyed = TRUE, relations = TRUE)
  
  expect_equal(keyedRows, list(
    list(
      id = '1',
      name = 'Alex',
      surname = 'Martin',
      parent_id = NULL
    ),
    list(
      id = '2',
      name = 'John',
      surname = 'Dockins',
      parent_id = list(id = '1', name = 'Alex', surname = 'Martin', parent_id = NULL)
    ),
    list(
      id = '3',
      name = 'Walter',
      surname = 'White',
      parent_id = list(id = '2', name = 'John', surname = 'Dockins', parent_id = '1')
    )
  ))
})


test_that('should read rows if single self field foreign keys is valid', {
  descriptor = DESCRIPTOR
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$fields = 'parent_id'
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$resource = ''
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$fields = 'id'
  resource = (Package.load(descriptor))$getResource('main')
  keyedRows = resource$read(keyed = TRUE, relations = TRUE)
  
  expect_equal(keyedRows, list(
    list(
      id = '1',
      name = 'Alex',
      surname = 'Martin',
      parent_id = NULL
    ),
    list(
      id = '2',
      name = 'John',
      surname = 'Dockins',
      parent_id = list(id = '1', name = 'Alex', surname = 'Martin', parent_id = NULL)
    ),
    list(
      id = '3',
      name = 'Walter',
      surname = 'White',
      parent_id = list(id = '2', name = 'John', surname = 'Dockins', parent_id = '1')
    )
  ))
})


test_that('should throw on read if single self field foreign keys is invalid', {
  descriptor = DESCRIPTOR
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$fields = 'parent_id'
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$resource = ''
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$fields = 'id'
  descriptor$resources[[1]]$data[[3]][[1]] = '0'
  resource = (Package.load(descriptor))$getResource('main')
  
  expect_error(resource$read(relations = TRUE), 'Foreign key')
})


test_that('should read rows if multi field foreign keys is valid', {
  descriptor = DESCRIPTOR
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$fields = list('name', 'surname')
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$fields = list('firstname', 'surname')
  resource = (Package.load(descriptor))$getResource('main')
  keyedRows = resource$read(keyed = TRUE, relations = TRUE)
  
  expect_equal(keyedRows, list(
    list(
      id = '1',
      name = list(firstname = 'Alex', surname = 'Martin'),
      surname = list(firstname = 'Alex', surname = 'Martin'),
      parent_id = NULL
    ),
    list(
      id = '2',
      name = list(firstname = 'John', surname = 'Dockins'),
      surname = list(firstname = 'John', surname = 'Dockins'),
      parent_id = '1'
    ),
    list(
      id = '3',
      name = list(firstname = 'Walter', surname = 'White'),
      surname = list(firstname = 'Walter', surname = 'White'),
      parent_id = '2'
    )
  ))
})


test_that('should throw on read if multi field foreign keys is invalid', {
  descriptor = DESCRIPTOR
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$fields = list('name', 'surname')
  descriptor$resources[[1]]$schema$foreignKeys[[1]]$reference$fields = list('firstname', 'surname')
  descriptor$resources[[2]]$data[[3]][[1]] = 'Max'
  resource = (Package.load(descriptor))$getResource('main')
  
  expect_error(resource$read(relations = TRUE), 'Foreign key')
})
