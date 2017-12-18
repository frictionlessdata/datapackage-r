library(datapackage.r)
library(testthat)
library(foreach)
library(stringr)
library(crul)
library(webmockr)

# Tests

testthat::context("Package")

###################################
testthat::context("Package #load")
###################################

test_that('initializes with Object descriptor', {
  descriptor = 'inst/data/dp1/datapackage.json'
  dataPackage = Package.load(descriptor, basePath= 'inst/data/dp1')
  expect_true(identical(dataPackage$descriptor,expandPackageDescriptor(jsonlite::fromJSON(descriptor))))
  # expect_true(identical(lapply(dataPackage$descriptor,unlist,use.names=F, recursive = FALSE), lapply(expandPackageDescriptor(jsonlite::fromJSON(descriptor)),unlist,use.names=F, recursive = FALSE)))
})

test_that('initializes with URL descriptor', {
  descriptor = 'inst/data/dp1/datapackage.json'
  dataPackage = Package.load(
    'https://raw.githubusercontent.com/frictionlessdata/datapackage-js/master/data/dp1/datapackage.json')
  expect_equal(dataPackage$descriptor, expandPackageDescriptor(descriptor))
})

# test_that('throws errors for invalid datapackage in strict mode', {
#   expect_error(Package.load(list(),strict=TRUE))
# })
# 
# test_that('stores errors for invalid datapackage', {
#   dataPackage = Package.load()
#   # assert.instanceOf(dataPackage.errors, Array)
#   # assert.instanceOf(dataPackage.errors[0], Error)
#   # assert.include(dataPackage.errors[0].message, 'required property')
#   expect_false(dataPackage$valid)
# })
# 
# # test_that('loads relative resource', {
# #   # TODO: For now tableschema doesn't support in-browser table.read
# #   # if (process.env.USER_ENV === 'browser') {
# #   #   this.skip()
# #   # }
# #   descriptor = 'https://raw.githubusercontent.com/frictionlessdata/datapackage-js/master/data/dp1/datapackage.json'
# #   dataPackage = Package.load(descriptor)
# #   
# #   dataPackage.resources[0].descriptor.profile = 'tabular-data-resource'
# #   data = dataPackage.resources[0].table.read()
# #   expect_equal(data, [['gb', 100], ['us', 200], ['cn', 300]])
# # })
# 
# # 
# # test_that('loads resource from absolute URL', async function() {
# #   # TODO: For now tableschema doesn't support in-browser table.read
# #   if (process.env.USER_ENV === 'browser') {
# #     this.skip()
# #   }
# #   descriptor = 'https://dev.keitaro.info/dpkjs/datapackage.json'
# #   dataPackage = Package.load(descriptor)
# #   dataPackage.resources[0].descriptor.profile = 'tabular-data-resource'
# #   table = dataPackage.resources[0].table
# #   data = table.read()
# #   expect_equal(data, [['gb', 100], ['us', 200], ['cn', 300]])
# # })
# # 
# # test_that('loads resource from absolute URL disregarding basePath', async function() {
# #   # TODO: For now tableschema doesn't support in-browser table.read
# #   if (process.env.USER_ENV === 'browser') {
# #     this.skip()
# #   }
# #   descriptor = 'https://dev.keitaro.info/dpkjs/datapackage.json'
# #   dataPackage = Package.load(descriptor, {basePath: 'local/basePath'})
# #   dataPackage.resources[0].descriptor.profile = 'tabular-data-resource'
# #   table = dataPackage.resources[0].table
# #   data = table.read()
# #   expect_equal(data, [['gb', 100], ['us', 200], ['cn', 300]])
# # })
# # 
# # test_that('loads remote resource with basePath', async function() {
# #   # TODO: For now tableschema doesn't support in-browser table.read
# #   if (process.env.USER_ENV === 'browser') {
# #     this.skip()
# #   }
# #   descriptor = 'https://dev.keitaro.info/dpkjs/datapackage.json'
# #   dataPackage = Package.load(descriptor, {basePath: 'data'})
# #   dataPackage.resources[1].descriptor.profile = 'tabular-data-resource'
# #   table = dataPackage.resources[1].table
# #   data = table.read()
# #   expect_equal(data, [['gb', 105], ['us', 205], ['cn', 305]])
# # })
# # 
# # })
# 
# ###################################################
# testthat::context("Package #descriptor (retrieve)")
# ###################################################
# 
# test_that('object', {
#   descriptor = jsonlite::fromJSON('{"resources": [{"name": "name", "data": ["data"]}]}')
#   dataPackage = Package.load(descriptor)
#   expect_equal(dataPackage$descriptor, expandPackageDescriptor(descriptor))
# })
# 
# test_that('string remote path', {
#   target.contents = jsonlite::fromJSON('inst/data/data-package.json',flatten = T,simplifyVector = T)
#   descriptor = 'https://httpbin.org/data-resource.json'
#   # Mocks
#   (x = HttpClient$new(url = descriptor))
#   (res = x$patch(path = "patch",
#                  encode = "json",
#                  body = target.contents
#   ))
#   ##
#   target.contents=jsonlite::fromJSON(res$parse("UTF-8"))$json
#   descriptor.response=jsonlite::fromJSON(res$parse("UTF-8"))$json
#   dataPackage = Package.load(descriptor.response)
#   
#   expect_equal(dataPackage$descriptor, expandPackageDescriptor(target.contents))
# })
#  
# # test_that('string remote path bad', {
# #   descriptor = 'http://example.com/bad-path.json'
# #   http.onGet(descriptor).reply(500)
# #   error = catchError(Package.load, descriptor)
# #   assert.instanceOf(error, Error)
# #   assert.include(error.message, 'Can not retrieve remote')
# # })
# # 
# 
# test_that('string local path', {
#   contents =  jsonlite::fromJSON('inst/data/data-package.json')
#   descriptor = 'inst/data/data-package.json'
#   dataPackage = Package.load(descriptor)
#   expect_equal(dataPackage$descriptor, expandPackageDescriptor(contents))
#  })
# 
# test_that('string local path bad', {
#   descriptor = 'inst/data/bad-path.json'
#   expect_error(Package.load(descriptor))
# })
# 
# ######################################################
# testthat::context("Package #descriptor (dereference)")
# ######################################################
# 
# # 
# # test_that('mixed', {
# #   descriptor = jsonlite::fromJSON('inst/data/data-package-dereference.json',flatten = F)
# #   str(descriptor)
# #     dataPackage = Package.load(descriptor)
# #     
# #     expect_equal( dataPackage.descriptor.resources, 
# #                   [
# #       {name: 'name1', data: ['data'], schema: {fields: [{name: 'name'}]}},
# #       {name: 'name2', data: ['data'], dialect: {delimiter: ','}},
# #       ].map(expandResourceDescriptor))
# # 
# # })
# # 
# # test_that('pointer', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: '#/schemas/main'},
# #       {name: 'name2', data: ['data'], dialect: '#/dialects/0'},
# #       ],
# #     schemas: {main: {fields: [{name: 'name'}]}},
# #     dialects: [{delimiter: ','}],
# #   }
# #   dataPackage = Package.load(descriptor)
# #   expect_equal(dataPackage.descriptor.resources, [
# #     {name: 'name1', data: ['data'], schema: {fields: [{name: 'name'}]}},
# #     {name: 'name2', data: ['data'], dialect: {delimiter: ','}},
# #     ].map(expandResource))
# # })
# # 
# # test_that('pointer bad', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: '#/schemas/main'},
# #       ],
# #   }
# #   error = catchError(Package.load, descriptor)
# #   assert.instanceOf(error, Error)
# #   assert.include(error.message, 'Not resolved Pointer URI')
# # })
# # 
# # test_that('remote', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: 'http://example.com/schema'},
# #       {name: 'name2', data: ['data'], dialect: 'http://example.com/dialect'},
# #       ],
# #   }
# #   http.onGet('http://example.com/schema').reply(200, {fields: [{name: 'name'}]})
# #   http.onGet('http://example.com/dialect').reply(200, {delimiter: ','})
# #   dataPackage = Package.load(descriptor)
# #   expect_equal(dataPackage.descriptor.resources, [
# #     {name: 'name1', data: ['data'], schema: {fields: [{name: 'name'}]}},
# #     {name: 'name2', data: ['data'], dialect: {delimiter: ','}},
# #     ].map(expandResource))
# # })
# # 
# # test_that('remote bad', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: 'http://example.com/schema'},
# #       ],
# #   }
# #   http.onGet('http://example.com/schema').reply(500)
# #   error = catchError(Package.load, descriptor)
# #   assert.instanceOf(error, Error)
# #   assert.include(error.message, 'Not resolved Remote URI')
# # })
# # 
# # test_that('local', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: 'table-schema.json'},
# #       {name: 'name2', data: ['data'], dialect: 'csv-dialect.json'},
# #       ],
# #   }
# #   if (process.env.USER_ENV !== 'browser') {
# #     dataPackage = Package.load(descriptor, {basePath: 'data'})
# #     expect_equal(dataPackage.descriptor.resources, [
# #       {name: 'name1', data: ['data'], schema: {fields: [{name: 'name'}]}},
# #       {name: 'name2', data: ['data'], dialect: {delimiter: ','}},
# #       ].map(expandResource))
# #   } else {
# #     error = catchError(Package.load, descriptor, {basePath: 'data'})
# #     assert.instanceOf(error, Error)
# #     assert.include(error.message, 'in browser')
# #   }
# # })
# # 
# # test_that('local bad', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: 'bad-path.json'},
# #       ],
# #   }
# #   error = catchError(Package.load, descriptor, {basePath: 'data'})
# #   assert.instanceOf(error, Error)
# #   if (process.env.USER_ENV !== 'browser') {
# #     assert.include(error.message, 'Not resolved Local URI')
# #   } else {
# #     assert.include(error.message, 'in browser')
# #   }
# # })
# # 
# # test_that('local bad not safe', {
# #   descriptor = {
# #     resources: [
# #       {name: 'name1', data: ['data'], schema: '../data/table-schema.json'},
# #       ],
# #   }
# #   error = catchError(Package.load, descriptor, {basePath: 'data'})
# #   assert.instanceOf(error, Error)
# #   if (process.env.USER_ENV !== 'browser') {
# #     assert.include(error.message, 'Not safe path')
# #   } else {
# #     assert.include(error.message, 'in browser')
# #   }
# # })
# # 
# # 
# #################################################
# testthat::context("Package #descriptor (expand)")
# #################################################
# 
# test_that('resource', {
#   descriptor = jsonlite::fromJSON('{
#     "resources": [
#       {
#         "name": "name",
#         "data": ["data"]
#       }
#       ]
#   }')
#   
#   target = jsonlite::fromJSON('{
#     "profile": "data-package",
#     "resources": [
#       {
#         "name": "name",
#         "data": ["data"],
#         "profile": "data-resource",
#         "encoding": "utf-8"
#       }
#       ]
#   }')
#   
#   dataPackage = Package.load(descriptor)
#   expect_equal(dataPackage$descriptor[sort(names(target))],target) # sort names by target to match
# })
# 
# test_that('tabular resource schema', {
# 
#   descriptor = jsonlite::fromJSON( '{
#   	"resources": [{
#   		"name": "name",
#   		"data": ["data"],
#   		"profile": "tabular-data-resource",
#   		"schema": {
#   			"fields": [{"name": "name"}]
#   		}
#   	}]
#   }')
# 
#   target = jsonlite::fromJSON('{
#       "profile": "data-package",
#       "resources": [{
#         "name": "name",
#         "data": ["data"],
#         "profile": "tabular-data-resource",
#         "encoding": "utf-8",
#         "schema": {
#           "fields": {"name": "name", "type": "string", "format": "default"},
#           "missingValues": ""
#         }
#       }]
#     }')
# 
#   dataPackage = Package.load(descriptor)
#   #target$resources = target$resources[names(dataPackage$descriptor$resources)] #sort target resources to match
#   target = target[names(dataPackage$descriptor)] #sort target to match
#   target$resources = target$resources[names(dataPackage$descriptor$resources)] #sort target to match
#   expect_equal(dataPackage$descriptor, target)
# })
# 
# # test_that('tabular resource dialect', {
# # 
# #   descriptor = jsonlite::fromJSON('{
# #     "resources": [
# #       {
# #         "name": "name",
# #         "data": ["data"],
# #         "profile": "tabular-data-resource",
# #         "dialect": {"delimiter": "custom"}
# #       }
# #       ]
# #   }')
# # 
# #   target = jsonlite::fromJSON('{
# #     "profile": "data-package",
# #     "resources": [{
# #     "name": "name",
# #     "data": ["data"],
# #     "profile": "tabular-data-resource",
# #     "encoding": "utf-8",
# #     "dialect": {
# #         "delimiter": "custom",
# #         "doubleQuote": "TRUE",
# #         "lineTerminator": "\\r\\n",
# #         "quoteChar": "\\"",
# #         "escapeChar": "\\\\",
# #         "skipInitialSpace": "TRUE",
# #         "header": "TRUE",
# #         "caseSensitiveHeader": "FALSE"
# #     }
# #   }]
# #  }')
# # 
# #   dataPackage = Package.load(descriptor)
# # 
# #   expect_equal(dataPackage$descriptor, target)
# # })
# 
# ###################################################
# # testthat::context("Package #resources")
# ###################################################
# 
# # test_that('names', {
# #   descriptor = jsonlite::fromJSON('inst/data/data-package-multiple-resources.json')
# #   dataPackage = Package.load(descriptor, basePath = 'inst/data')
# #   expect_length(dataPackage$resources, 2)
# #   expect_equal(dataPackage$resourceNames, jsonlite::fromJSON('["name1", "name2"]'))
# # })
# #
# # test_that('add', {
# #   descriptor = jsonlite::fromJSON('inst/data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, basePath='inst/data/dp1')
# #   resource = dataPackage.addResource({name: 'name', data: ['test']})
# #   assert.isOk(resource)
# #   assert.lengthOf(dataPackage.resources, 2)
# #   expect_equal(dataPackage.resources[1].source, ['test'])
# # })
# # 
# # test_that('add invalid - throws array of errors in strict mode', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {
# #     basePath: 'data/dp1', strict: true,
# #   })
# #   error = catchError(dataPackage.addResource.bind(dataPackage), {})
# #   assert.instanceOf(error, Error)
# #   assert.instanceOf(error.errors[0], Error)
# #   assert.include(error.errors[0].message, 'Data does not match any schemas')
# # })
# # 
# # test_that('add invalid - save errors in not a strict mode', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data/dp1'})
# #   dataPackage.addResource({})
# #   assert.instanceOf(dataPackage.errors[0], Error)
# #   assert.include(dataPackage.errors[0].message, 'Data does not match any schemas')
# #   assert.isFalse(dataPackage.valid)
# # })
# # 
# # test_that('add tabular - can read data', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data/dp1'})
# #   dataPackage.addResource({
# #     name: 'name',
# #     data: [['id', 'name'], ['1', 'alex'], ['2', 'john']],
# #     schema: {
# #       fields: [
# #         {name: 'id', type: 'integer'},
# #         {name: 'name', type: 'string'},
# #         ],
# #     },
# #   })
# #   rows = dataPackage.resources[1].table.read()
# #   expect_equal(rows, [[1, 'alex'], [2, 'john']])
# # })
# # 
# # test_that('add with not a safe path - throw an error', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data/dp1'})
# #   try {
# #     dataPackage.addResource({
# #       name: 'name',
# #       path: ['../dp1/data.csv'],
# #     })
# #     assert.isNotOk(true)
# #   } catch (error) {
# #     assert.instanceOf(error, Error)
# #     assert.include(error.message, 'not safe')
# #   }
# # })
# # 
# # test_that('get existent', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data/dp1'})
# #   resource = dataPackage.getResource('random')
# #   expect_equal(resource.name, 'random')
# # })
# # 
# # test_that('get non existent', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data/dp1'})
# #   resource = dataPackage.getResource('non-existent')
# #   assert.isNull(resource)
# # })
# # 
# # test_that('remove existent', {
# #   descriptor = require('../data/data-package-multiple-resources.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data'})
# #   assert.lengthOf(dataPackage.resources, 2)
# #   assert.lengthOf(dataPackage.descriptor.resources, 2)
# #   expect_equal(dataPackage.resources[0].name, 'name1')
# #   expect_equal(dataPackage.resources[1].name, 'name2')
# #   resource = dataPackage.removeResource('name2')
# #   assert.lengthOf(dataPackage.resources, 1)
# #   assert.lengthOf(dataPackage.descriptor.resources, 1)
# #   expect_equal(dataPackage.resources[0].name, 'name1')
# #   expect_equal(resource.name, 'name2')
# # })
# # 
# # test_that('remove non existent', {
# #   descriptor = require('../data/dp1/datapackage.json')
# #   dataPackage = Package.load(descriptor, {basePath: 'data/dp1'})
# #   resource = dataPackage.removeResource('non-existent')
# #   assert.isNull(resource)
# #   assert.lengthOf(dataPackage.resources, 1)
# #   assert.lengthOf(dataPackage.descriptor.resources, 1)
# # })
# # 
# # 
# # ###################################################
# # testthat::context("Package #save")
# # ###################################################
# # 
# # 
# # # TODO: recover stub with async writeFile
# # it.skip('general', async function () {
# #   # TODO: check it trows correct error in browser
# #   if (process.env.USER_ENV === 'browser') {
# #     this.skip()
# #   }
# #   descriptor = {resources: [{name: 'name', data: ['data']}]}
# #   dataPackage = Package.load(descriptor)
# #   writeFile = sinon.stub(fs, 'writeFile')
# #   dataPackage.save('target')
# #   writeFile.restore()
# #   sinon.assert.calledWith(writeFile,
# #                           'target', JSON.stringify(expand(descriptor)))
# # })
# # 
# # 
# # ###################################################
# # testthat::context("Package #commit")
# # ###################################################
# # 
# # 
# # test_that('modified', {
# #   descriptor = {resources: [{name: 'name', data: ['data']}]}
# #   dataPackage = Package.load(descriptor)
# #   dataPackage.descriptor.resources[0].name = 'modified'
# #   expect_equal(dataPackage.resources[0].name, 'name')
# #   result = dataPackage.commtest_that()
# #   expect_equal(dataPackage.resources[0].name, 'modified')
# #   assert.isTrue(result)
# # })
# # 
# # test_that('modified invalid in strict mode', {
# #   descriptor = {resources: [{name: 'name', path: 'data.csv'}]}
# #   dataPackage = Package.load(descriptor, {
# #     basePath: 'data', strict: true,
# #   })
# #   dataPackage.descriptor.resources = []
# #   error = catchError(dataPackage.commit.bind(dataPackage), {})
# #   assert.instanceOf(error, Error)
# #   assert.instanceOf(error.errors[0], Error)
# #   assert.include(error.errors[0].message, 'Array is too short')
# # })
# # 
# # test_that('not modified', {
# #   descriptor = {resources: [{name: 'name', data: ['data']}]}
# #   dataPackage = Package.load(descriptor)
# #   result = dataPackage.commtest_that()
# #   expect_equal(dataPackage.descriptor, expand(descriptor))
# #   assert.isFalse(result)
# # })
# # 
# # 
# # ###################################################
# # testthat::context("Package #foreignKeys")
# # ###################################################
# # 
# # DESCRIPTOR = {
# #   resources: [
# #     {
# #       name: 'main',
# #       data: [
# #         ['id', 'name', 'surname', 'parent_id'],
# #         ['1', 'Alex', 'Martin', ''],
# #         ['2', 'John', 'Dockins', '1'],
# #         ['3', 'Walter', 'White', '2'],
# #         ],
# #       schema: {
# #         fields: [
# #           {name: 'id'},
# #           {name: 'name'},
# #           {name: 'surname'},
# #           {name: 'parent_id'},
# #           ],
# #         foreignKeys: [
# #           {
# #             fields: 'name',
# #             reference: {resource: 'people', fields: 'firstname'},
# #           },
# #           ],
# #       },
# #     }, {
# #       name: 'people',
# #       data: [
# #         ['firstname', 'surname'],
# #         ['Alex', 'Martin'],
# #         ['John', 'Dockins'],
# #         ['Walter', 'White'],
# #         ],
# #     },
# #     ],
# # }
# # 
# # test_that('should read rows if single field foreign keys is valid', {
# #   resource = (Package.load(DESCRIPTOR)).getResource('main')
# #   rows = resource.read({relations: true})
# #   expect_equal(rows, [
# #     ['1', {firstname: 'Alex', surname: 'Martin'}, 'Martin', null],
# #     ['2', {firstname: 'John', surname: 'Dockins'}, 'Dockins', '1'],
# #     ['3', {firstname: 'Walter', surname: 'White'}, 'White', '2'],
# #     ])
# # })
# # 
# # test_that('should throw on read if single field foreign keys is invalid', {
# #   descriptor = cloneDeep(DESCRIPTOR)
# #   descriptor.resources[1].data[2][0] = 'Max'
# #   resource = (Package.load(descriptor)).getResource('main')
# #   error1 = catchError(resource.read.bind(resource), {relations: true})
# #   error2 = catchError(resource.checkRelations.bind(resource))
# #   assert.include(error1.message, 'Foreign key')
# #   assert.include(error2.message, 'Foreign key')
# # })
# # 
# # test_that('should read rows if single self field foreign keys is valid', {
# #   descriptor = cloneDeep(DESCRIPTOR)
# #   descriptor.resources[0].schema.foreignKeys[0].fields = 'parent_id'
# #   descriptor.resources[0].schema.foreignKeys[0].reference.resource = ''
# #   descriptor.resources[0].schema.foreignKeys[0].reference.fields = 'id'
# #   resource = (Package.load(descriptor)).getResource('main')
# #   keyedRows = resource.read({keyed: true, relations: true})
# #   expect_equal(keyedRows, [
# #     {
# #       id: '1',
# #       name: 'Alex',
# #       surname: 'Martin',
# #       parent_id: null,
# #     },
# #     {
# #       id: '2',
# #       name: 'John',
# #       surname: 'Dockins',
# #       parent_id: {id: '1', name: 'Alex', surname: 'Martin', parent_id: null},
# #     },
# #     {
# #       id: '3',
# #       name: 'Walter',
# #       surname: 'White',
# #       parent_id: {id: '2', name: 'John', surname: 'Dockins', parent_id: '1'},
# #     },
# #     ])
# # })
# # 
# # test_that('should throw on read if single self field foreign keys is invalid', {
# #   descriptor = cloneDeep(DESCRIPTOR)
# #   descriptor.resources[0].schema.foreignKeys[0].fields = 'parent_id'
# #   descriptor.resources[0].schema.foreignKeys[0].reference.resource = ''
# #   descriptor.resources[0].schema.foreignKeys[0].reference.fields = 'id'
# #   descriptor.resources[0].data[2][0] = '0'
# #   resource = (Package.load(descriptor)).getResource('main')
# #   error1 = catchError(resource.read.bind(resource), {relations: true})
# #   error2 = catchError(resource.checkRelations.bind(resource))
# #   assert.include(error1.message, 'Foreign key')
# #   assert.include(error2.message, 'Foreign key')
# # })
# # 
# # test_that('should read rows if multi field foreign keys is valid', {
# #   descriptor = cloneDeep(DESCRIPTOR)
# #   descriptor.resources[0].schema.foreignKeys[0].fields = ['name', 'surname']
# #   descriptor.resources[0].schema.foreignKeys[0].reference.fields = ['firstname', 'surname']
# #   resource = (Package.load(descriptor)).getResource('main')
# #   keyedRows = resource.read({keyed: true, relations: true})
# #   expect_equal(keyedRows, [
# #     {
# #       id: '1',
# #       name: {firstname: 'Alex', surname: 'Martin'},
# #       surname: {firstname: 'Alex', surname: 'Martin'},
# #       parent_id: null,
# #     },
# #     {
# #       id: '2',
# #       name: {firstname: 'John', surname: 'Dockins'},
# #       surname: {firstname: 'John', surname: 'Dockins'},
# #       parent_id: '1',
# #     },
# #     {
# #       id: '3',
# #       name: {firstname: 'Walter', surname: 'White'},
# #       surname: {firstname: 'Walter', surname: 'White'},
# #       parent_id: '2',
# #     },
# #     ])
# # })
# # 
# # test_that('should throw on read if multi field foreign keys is invalid', {
# #   descriptor = cloneDeep(DESCRIPTOR)
# #   descriptor.resources[0].schema.foreignKeys[0].fields = ['name', 'surname']
# #   descriptor.resources[0].schema.foreignKeys[0].reference.fields = ['firstname', 'surname']
# #   descriptor.resources[1].data[2][0] = 'Max'
# #   resource = (Package.load(descriptor)).getResource('main')
# #   error1 = catchError(resource.read.bind(resource), {relations: true})
# #   error2 = catchError(resource.checkRelations.bind(resource))
# #   assert.include(error1.message, 'Foreign key')
# #   assert.include(error2.message, 'Foreign key')
# # })