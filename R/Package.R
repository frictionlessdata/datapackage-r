#' Data Package class
#' 
#' @description A class for working with data packages. 
#' It provides various capabilities like loading local or 
#' remote data package, inferring a data package descriptor, 
#' saving a data package descriptor and many more.
#' 
#' @usage # Package.load(descriptor = list(),basePath = NA,strict = FALSE)
#' 
#' @section Methods:
#' 
#' \describe{
#' 
#' \item{\code{Package$new(descriptor = list(),basePath = NA,strict = FALSE)}}{
#' Use \code{\link{Package.load}} to instantiate \code{Package} class.}
#' 
#' 
#' \item{\code{getResource(name)}}{
#'   Get data package resource by name or null if not found.}
#' \itemize{
#'  \item{\code{name }}{Data resource name.}  
#'  }
#' 
#' \item{\code{addResource(descriptor)}}{
#'   Add new resource to data package. The data package descriptor will be 
#'   validated with newly added resource descriptor.}
#' \itemize{
#'  \item{\code{descriptor }}{Data resource descriptor.}  
#'  }
#' 
#' \item{\code{removeResource(name)}}{
#'   Remove data package resource by name. The data package descriptor will be 
#'   validated after resource descriptor removal.}
#' \itemize{
#'  \item{\code{name }}{Data resource name.}  
#'  }
#'  
#' \item{\code{infer(pattern=FALSE)}}{
#'   Infer a data package metadata. If \code{pattern} is not provided only existent 
#'   resources will be inferred (added metadata like encoding, profile etc). 
#'   If \code{pattern} is provided new resoures with file names mathing the pattern 
#'   will be added and inferred. It commits changes to data package instance.}
#' \itemize{
#'  \item{\code{pattern }}{Glob pattern for new resources.}  
#'  }
#'  
#' \item{\code{commit(strict)}}{
#' Update data package instance if there are in-place changes in the descriptor. Returns \code{TRUE} on success and \code{FALSE} if not modified.}
#' \itemize{
#'  \item{\code{strict }}{Boolean - Alter strict mode for further work.}
#'  }
#'  
#' \item{\code{save(target)}}{
#' For now only descriptor will be saved. Save descriptor to target destination.}
#' \itemize{
#'  \item{\code{target }}{String path where to save a data package.}
#'  }
#' }
#'  
#'
#' 
#' 
#' @section Properties:
#' \describe{
#'   \item{\code{valid}}{Returns validation status. It always \code{TRUE} in strict mode.}
#'   \item{\code{errors}}{Returns validation errors. It always empty in strict mode.}
#'   \item{\code{profile}}{Returns an instance of \code{\link{Profile}} class.}
#'   \item{\code{descriptor}}{Returns list of package descriptor.}
#'   \item{\code{resources}}{Returns list of Resource instances.}
#'   \item{\code{resourceNames}}{Returns list of resource names.}
#'  }
#' 
#'  
#'  
#' @section Details:
#' A Data Package consists of:
#' \itemize{ 
#' \item{Metadata that describes the structure and contents of the package.}
#' \item{Resources such as data files that form the contents of the package.}
#' }
#' 
#' The Data Package metadata is stored in a "descriptor". This descriptor is what 
#' makes a collection of data a Data Package. The structure of this descriptor is 
#' the main content of the specification below.
#' 
#' In addition to this descriptor a data package will include other resources such as 
#' data files. The Data Package specification does NOT impose any requirements on their 
#' form or structure and can therefore be used for packaging any kind of data.
#' 
#' The data included in the package may be provided as:
#' \itemize{    
#' \item{Files bundled locally with the package descriptor.}
#' \item{Remote resources, referenced by URL.}
#' \item{"Inline" data which is included directly in the descriptor.}
#' }
#'  
#' \href{https://CRAN.R-project.org/package=jsonlite}{Jsolite package} is internally used to convert json data to list objects. The input parameters of functions could be json strings, 
#' files or lists and the outputs are in list format to easily further process your data in R environment and exported as desired. 
#' It is recommended to use \code{\link{helpers.from.json.to.list}} or \code{\link{helpers.from.list.to.json}} to convert json objects to lists and vice versa.
#' More details about handling json you can see jsonlite documentation or vignettes \href{https://CRAN.R-project.org/package=jsonlite}{here}.
#' 
#' @section Language:
#' The key words \code{MUST}, \code{MUST NOT}, \code{REQUIRED}, \code{SHALL}, \code{SHALL NOT}, 
#' \code{SHOULD}, \code{SHOULD NOT}, \code{RECOMMENDED}, \code{MAY}, and \code{OPTIONAL} 
#' in this package documents are to be interpreted as described in \href{https://www.ietf.org/rfc/rfc2119.txt}{RFC 2119}.
#'
#' @seealso \code{\link{Package.load}}, 
#' \href{https://frictionlessdata.io/specs/data-package/}{Data Package Specifications}
#' 
#'  
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @keywords data
#' @return Object of \code{\link{R6Class}}
#' @format \code{\link{R6Class}} object
#' 

Package <- R6::R6Class(
  "Package",
  class = TRUE,
  public = list(
    initialize = function(descriptor = list(),
                          basePath = NULL,
                          strict = FALSE,
                         profile = NULL) {
      # Handle deprecated resource.path.url

      if (length(descriptor$resources) > 0) {
        for (i in 1:length(descriptor$resources)) {
          if ("url" %in% names(descriptor$resources[[i]])) {
            message(
              'Resource property "url: <url>" is deprecated.
              Please use "path: <url>" instead.')
            descriptor$resources[[i]]$path = descriptor$resources[[i]]$url
            rlist::list.remove(descriptor$resources[[i]], "url")
          }
        }
      }
      
      private$currentDescriptor_ = descriptor
      private$nextDescriptor_ = descriptor
      private$basePath_ = basePath
      private$profile_ = profile
      private$strict_ = strict
      private$resources_ = list()
      private$errors_ = list()
      

      # Build instance
      private$build_()
      
      
    },
    addResource = function(descriptor) {
      if (is.null(private$currentDescriptor_$resources)) private$currentDescriptor_$resources = list()
      private$currentDescriptor_$resources = rlist::list.append(private$currentDescriptor_$resources, descriptor)

      private$build_()
      return(private$resources_[[length(private$resources_)]])
    },
    
    getResource = function(name) {
      resources = Filter(function(x) x$name == name, private$resources_)
      if (length(resources) > 0) return(resources[[1]])
      else return(NULL)

    },
    
    removeResource = function(name) {
      resource = self$getResource(name)
      if (!is.null(resource)) {
        predicat = function(resource) { return(resource$name != name) }
        private$currentDescriptor_$resources = Filter(predicat, private$currentDescriptor_$resources)

        private$build_()
      }
     return(resource)
      
    },
    
    
    infer = function(pattern) {

      if (isTRUE(!is.null(pattern)) && stringr::str_length(pattern) > 0) {
        # No base path
        if (is.null(private$basePath_) || stringr::str_length(private$basePath_) < 1) {
         stop('Base path is required for pattern infer')
        }
        
        # Add resources

        files = findFiles(pattern, private$basePath_)
        for (file in files) {
          self$addResource(list(path = file))
        }
      }
      
      # Resources
      if (length(private$resources_) > 0) {
        for (index in 1:length(private$resources_)) {
          descriptor = private$resources_[[index]]$infer()
          private$currentDescriptor_$resources[[index]] = descriptor
          private$build_()
        }
      }

      # Profile

      if (isTRUE(private$nextDescriptor_$profile == config::get("DEFAULT_DATA_PACKAGE_PROFILE", file = system.file("config/config.yaml", package = "datapackage.r")))) {
        if (length(private$resources_) >= 1 && rlist::list.all(private$resources_, r ~ isTRUE(r$tabular))) {
          
          private$currentDescriptor_$profile = 'tabular-data-package'
          private$build_()
        }
      }
      
      
      
      return(private$currentDescriptor_)
    },
    
    commit = function(strict = NULL) {
 
      if (is.logical(strict))
        private$strict_ = strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_))
        return(FALSE)
      private$currentDescriptor_ = private$nextDescriptor_

      private$build_()
      return(TRUE)
    },
    
    save = function(target, type = "json") {
      #add name descriptor
      
      # if(type == "zip"){
      # write.csv(private$currentDescriptor_, file=stringr::str_c(target, "package.txt",sep = "/"))
      # }
      write.json(private$currentDescriptor_,
            file = stringr::str_c(target, "package.json", sep = "/"))
      save = stringr::str_interp('Package saved at: "${target}"')
      return(save)
      
      # if (!is.json(private$currentDescriptor_)) private$currentDescriptor_ = jsonlite::toJSON(private$currentDescriptor_, pretty = TRUE)
      # # if(type == "zip"){
      # # write.csv(private$currentDescriptor_, file=stringr::str_c(target, "package.txt",sep = "/"))
      # # }
      # else write(private$currentDescriptor_, file = stringr::str_c(target,"package.json", sep = "/"))
      # save=stringr::str_interp('Package saved at: "${target}"')
      # return (save)
    }
  ),
  
  active = list(
    descriptor = function(x) {
      if (!missing(x)) private$nextDescriptor_ = x
      return(private$nextDescriptor_)
    },
    
    resourceNames = function() {
      return(purrr::map(self$resources, "name")) 
    },
    
    profile = function() {
      if (is.null(private$profile_))
        private$profile_ = private$currentDescriptor_$resources$profile
      return(private$profile_)
      
      # if (is.json(private$currentDescriptor_)|is.character(private$currentDescriptor_)) {
      #   private$profile_ = jsonlite::fromJSON(private$currentDescriptor_)$profile
      #   if (is.null(private$profile_)) private$profile_ = jsonlite::fromJSON(private$currentDescriptor_)$resources$profile
      # }
      # return (private$profile_)
    },
    
    valid = function() {
      return(isTRUE(length(private$errors_) < 1)) #== 0 && unlist(purrr::map(private$resources_, function(x) validate(jsonlite::toJSON(x))$valid)) ))
      
      #&& unlist(purrr::map(q, function(x) validate(jsonlite::toJSON(x))$valid))
      # return (isTRUE(length(private$errors_) == 0 && unlist(purrr::map(private$resources_, function(x) validate(jsonlite::toJSON(x))$valid)) )) #&& unlist(purrr::map(q, function(x) validate(jsonlite::toJSON(x))$valid))
    },
    
    errors = function() {
      errors = private$errors_
      if (length(private$resources_) > 0) {
      for (index in 1:length(private$resources_)) {
        if (!isTRUE(private$resources_[[index]]$valid)) {
          errors = append(
            errors,
            DataPackageError$new(
              'Resource "${private$resources_[[index]]$name || index}" validation error(s)'
            )$message
          )
        }
      }
    }
      return(errors)
    },
    
    resources = function(value) {
      if (missing(value)) {
              return(private$resources_)
      }
      else {
        private$resources_ = value
        return(private$resources_)
      }

    }
    
  ),
  
  private = list(
    
    
    currentDescriptor_ = NULL,
    nextDescriptor_ = NULL,
    profile_ = NULL,
    basePath_ = NULL,
    strict_ = NULL,
    resources_ = list(),
    errors_ = NULL,
    descriptor_ = NULL,
    pattern_ = NULL,
    currentDescriptor_json = NULL,
    resources_length = NULL,
    build_ = function() {

      private$currentDescriptor_ = expandPackageDescriptor(private$currentDescriptor_)
      private$nextDescriptor_ = private$currentDescriptor_
      
      
      # Validate descriptor
      
      private$errors_ = list()
      valid_errors = private$profile_$validate(private$currentDescriptor_)
      
      
      if (!isTRUE(valid_errors$valid)) {
        private$errors_ = valid_errors$errors
        
        if (isTRUE(private$strict_)) {
          message = stringr::str_interp(
            "There are ${length(valid_errors$errors)} validation errors: ${paste(private$errors_, collapse = ', ')}"
          )
          stop(message)
        }
      }
      
      
      
      
      
      # Update resources
      length(private$resources_) <- if (is.null(private$currentDescriptor_$resources)) {
        length(list())
      } else {
        length(private$currentDescriptor_$resources)
      }
      

      if ( length(private$resources_) > 0) {
        for (index in 1: length(private$resources_)) {
          descriptor = private$currentDescriptor_$resources[[index]]
       
          if (index > length(private$resources_) ||
              !identical(private$resources_[[index]], descriptor) ||
              (!is.null(private$resources_[[index]]$schema) &&
               length(private$resources_[[index]]$schema$foreignKeys >= 1)) ) {
            
            private$resources_[[index]] = Resource$new(
              descriptor,
                strict = private$strict_,
                basePath = private$basePath_,
                dataPackage = self
              
            )
          }
        }
      }

      
    }
    
  )
)

#' Instantiate \code{Data Package} class
#' 
#' @description Constructor to instantiate \code{Package} class.
#' 
#' @usage Package.load(descriptor = list(), basePath = NA, strict = FALSE)
#' 
#' @param descriptor Data package descriptor as local path, url or object.
#' @param basePath Base path for all relative paths
#' @param strict  Strict flag to alter validation behavior. 
#' Setting it to \code{TRUE} leads to throwing errors on any operation with invalid descriptor.
#' @rdname Package.load
#' @seealso \code{\link{Package}}, 
#' \href{https://frictionlessdata.io/specs/data-package/#specification}{Data Package Specifications}
#' @export
#' 
#' 
#' @examples
#' 
#' # Load URL descriptor
#' descriptor = 'https://raw.githubusercontent.com/frictionlessdata/datapackage-js/master/data/dp1/datapackage.json'
#' dataPackage = Package.load(descriptor)
#' dataPackage$descriptor
#' 
#' # Load resource from absolute URL
#' descriptor2 = 'https://dev.keitaro.info/dpkjs/datapackage.json'
#' dataPackage2 = Package.load(descriptor2)
#' dataPackage2$resources[[1]]$descriptor$profile = 'tabular-data-resource'
#' table2 = dataPackage2$resources[[1]]$table
#' data2 = table$read()
#' data2
#' 
#' # Retrieve Package Descriptor
#' descriptor3 = '{"resources": [{"name": "name", "data": ["data"]}]}'
#' dataPackage3 = Package.load(descriptor3)
#' dataPackage3$descriptor
#' 
#' # Expand Resource Descriptor
#' descriptor4 = helpers.from.json.to.list('{"resources": 
#'                                          [{
#'                                           "name": "name",
#'                                           "data": ["data"]
#'                                           }]
#'                                         }')
#' 
#' dataPackage4 = Package.load(descriptor4)
#' dataPackage4$descriptor
#' 
#' 
#' # Expand Tabular Resource Schema
#' descriptor5 = helpers.from.json.to.list('{
#'                                       "resources": [{
#'                                         "name": "name",
#'                                         "data": ["data"],
#'                                         "profile": "tabular-data-resource",
#'                                         "schema": {
#'                                           "fields": [{
#'                                             "name": "name"
#'                                           }]
#'                                         }
#'                                       }]
#'                                       }')
#' 
#' dataPackage5 = Package.load(descriptor5)
#' dataPackage5$descriptor
#' 
#' 
#' # Expand Tabular Resource Dialect
#' descriptor6 = helpers.from.json.to.list('{
#'                                          "resources": [{
#'                                            "name": "name",
#'                                            "data": ["data"],
#'                                            "profile": "tabular-data-resource",
#'                                            "dialect": {
#'                                              "delimiter": "custom"
#'                                              }
#'                                            }]
#'                                          }')
#' 
#' dataPackage6 = Package.load(descriptor6)
#' dataPackage6$descriptor
#' 
#' 
#' 
#' # Package Resources - Names
#' descriptor7 = helpers.from.json.to.list(system.file('extdata/data-package-multiple-resources.json', package = "datapackage.r"))
#' dataPackage7 = Package.load(descriptor7)
#' dataPackage7$resourceNames
#' 
#' 
#' 
#' # Add Tabular Package Resources
#' descriptor8 = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
#' dataPackage8 = Package.load(descriptor8)
#' dataPackage8$addResource(helpers.from.json.to.list('{"name": "name",
#'                                                  	 	"data": [
#'                                                  	 		["id", "name"],
#'                                                  	 		["1", "alex"],
#'                                                  	 		["2", "john"]
#'                                                  	 	],
#'                                                  	 	"schema": {
#'                                                  	 		"fields": [{
#'                                                  	 				"name": "id",
#'                                                  	 				"type": "integer"
#'                                                  	 			},
#'                                                  	 			{
#'                                                  	 				"name": "name",
#'                                                  	 				"type": "string"
#'                                                  	 			}
#'                                                  	 		]
#'                                                  	 	}
#'                                                  	 }'))
#' rows = dataPackage8$resources[[2]]$table$read()
#' rows
#' 
#' 
#' # Add Package Resources
#' descriptor9 = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
#' dataPackage9 = Package.load(descriptor9)
#' resource9 = dataPackage9$addResource(helpers.from.json.to.list('{"name": "name", "data": ["test"]}'))
#' dataPackage9$resources[[2]]$source
#' 
#' 
#' # Get Existent Package Resource
#' descriptor10 = helpers.from.json.to.list(system.file('extdata/dp1/datapackage.json', package = "datapackage.r"))
#' dataPackage10 = Package.load(descriptor10)
#' resource10 = dataPackage10$getResource('random')
#' 
#' 
#' # Remove  Existent Package Resource
#' descriptor11 = helpers.from.json.to.list(system.file('extdata/data-package-multiple-resources.json', package = "datapackage.r"))
#' dataPackage11 = Package.load(descriptor11)
#' dataPackage11$removeResource('name2')
#' dataPackage11$getResource('name2')
#' 
#' 
#' # Modify and Commit Data Package
#' descriptor12 = helpers.from.json.to.list('{"resources": [{"name": "name", "data": ["data"]}]}')
#' dataPackage12 = Package.load(descriptor12)
#' dataPackage12$descriptor$resources[[1]]$name = 'modified'
#' ## Name did not modified.
#' dataPackage12$resources[[1]]$name
#' ## Should commit the changes
#' dataPackage12$commit() # TRUE - successful commit 
#' 
#' dataPackage12$resources[[1]]$name
#' 

Package.load = function(descriptor = list(),
                        basePath = NA,
                        strict = FALSE) {
  
  
  # Get base path
  if (is.na(basePath)) {
    basePath = locateDescriptor(descriptor)
  }
  

  # Process descriptor
  descriptor = retrieveDescriptor(descriptor)

  descriptor = dereferencePackageDescriptor(descriptor, basePath)
  # Get profile

  profile.to.load = if (is.null(descriptor$profile)) {
    config::get("DEFAULT_DATA_PACKAGE_PROFILE", file = system.file("config/config.yaml", package = "datapackage.r"))
  } else {
    descriptor$profile
  }
  
  profile = Profile.load(profile.to.load)
  
  return(Package$new(descriptor, basePath, strict = strict, profile = profile))
  
}
