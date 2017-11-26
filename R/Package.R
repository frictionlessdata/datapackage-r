#' Package class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @keywords data
#' @return Object of \code{\link{R6Class}}
#' @format \code{\link{R6Class}} object

Package <- R6::R6Class(
  
  "Package",
  
  public=list( 
    
    load = function (descriptor = list(), basePath, strict = FALSE ) {
      
      # Get base path
      
      if (isUndefined(basePath)) {
        basePath = locateDescriptor(descriptor)
      }
      
      # Process descriptor
      descriptor = retrieveDescriptor(descriptor)
      descriptor = dereferencePackageDescriptor(descriptor, basePath)
      
      # Get profile
      if (!is.null(descriptor[["profile"]])) {
        profile = Profile$public_methods$load(descriptor[["profile"]] )
      } else profile = Profile$public_methods$load(config::get("DEFAULT_DATA_PACKAGE_PROFILE") )
      
      
      return (Package$new(descriptor, basePath, strict, profile) )
      
    },
    
    valid = function () {
      return (length(private$errors_) == 0 ) #&& purrr::map(private$resources, valid)
        },
    
    errors = function () {
      # errors = this.errors_
      # for ( resource in purrr::list_along(private$resources)) {
      #   if (!isTRUE(valid(resource))) {
      #     Error = push(errors,(stringr::str_interp('Resource "${private$resources[[resource]][["name"]] || resource}" validation error(s)')) )
      #     stop(Error)
      #   }
      # }
      return (private$errors_) # Error
    }, 
    
    profile = function () {
      return (private$profile_)
    },
    
    descriptor = function () {
      # Never use this.descriptor inside this class (!!!)
      return (private$nextDescriptor_)
    },
    
    resources = function () {
      return (private$resources_)
    },
    
    infer = function(pattern=FALSE) {
      
      # Files
      if (pattern) {
        
        # No base path
        if (is.null(private$basePath_)) {
          DataPackageError$new('Base path is required for pattern infer')
        }
        
        # Add resources
        files = findFiles(pattern, private$basePath_)
        for (file in files) {
          self$addResource(list(path = file))
        }
        
      }
      
      # Resources
      # for (const [index, resource] of this.resources.entries()) {
      #   const descriptor = await resource.infer()
      #   this._currentDescriptor.resources[index] = descriptor
      #   this._build()
      # }
      
      # Profile
      if (private$nextDescriptor_$profile == config::get("DEFAULT_DATA_PACKAGE_PROFILE") ) {
        if (length(private$resources)>=1 ){#&& private$resources.every(resouce => resouce.tabular)) {
          private$currentDescriptor_$profile = 'tabular-data-package'
          private$build_()
        }
      }
      
      return (private$currentDescriptor_)
    },
    
    commit = function(strict=list()) {
      
      if (is_logical(strict)) self$strict = strict
      else if ( identical(private$currentDescriptor_, private$nextDescriptor_) ) return (FALSE)
      private$currentDescriptor_ = private$nextDescriptor_
      private$build()
      return (TRUE)
    },
    
    
    save = function(target) {
      contents = jsonlite::toJSON(private$currentDescriptor_, pretty = TRUE)
      deferred_ = future::future( function() {
        base::save(contents, file = target)
      })
      return(deferred_)
    }
    
    ),
  
  active = list(
    
    resourceNames = function () {
      return (purrr::map(private$resources_, names))
    },
    
    getResource = function (name) {
      return (compact(purrr::map(private$resources_, function (x) { i<-names(x) == name; x[which(i==TRUE)] } )))
    },
    
    addResource = function (descriptor) {
      if (is.null(private$currentDescriptor_[["resources"]]) ) private$currentDescriptor_$resources = list()
      push(descriptor, private$currentDescriptor_$resources)
      private$build_()
      return (private$resources_[- 1])
    },
    
    removeResource = function (name) {
      resource = self$getResource(name)
      if (!null(resource)){
        predicat = names(resource) != name
        private$currentDescriptor_$resources = keep(private$currentDescriptor_$resources, predicat)
        private$build_()
      }
      return (resource)
    }
    
    ),
  
  private = list(
    
    # Set attributes
    currentDescriptor_ = NULL,
    nextDescriptor_ = NULL,
    basePath_ = NULL,
    strict_ = NULL,
    profile_ = NULL,
    resources_ = NULL,
    errors_ = NULL,
    
    build_ = function () {
      
      # Process descriptor
      
      #private$currentDescriptor_json = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = TRUE)
      private$currentDescriptor_ = expandPackageDescriptor(descriptor)
      private$nextDescriptor_ = private$currentDescriptor_
      
      # Validate descriptor
      
      private$errors_ = list()
      
      
      private$currentDescriptor_json =  retrieveDescriptor(private$currentDescriptor_json)
      if(inherits(private$currentDescriptor_json, "simpleError")) {
        stop(private$currentDescriptor_json$message)
      }
      
      descriptor = jsonlite::fromJSON(private$currentDescriptor_json, simplifyVector = FALSE)
      current = private$profile_$validate(private$currentDescriptor_json)
      
      if (!current[['valid']]) {
        private$errors_ = current[['errors']]
        
        if (private$strict_ == TRUE) {
          message = stringr::str_interp(
            "There are ${length(current[['errors']])} validation errors (see 'error$errors')"
          )
          stop((message))
        }
      }
      
      # Update resources
      #this._resources.length = (this._currentDescriptor.resources || []).length
      descriptor = private$currentDescriptor_$resources
      for (index in purrr::list_along(private$currentDescriptor_$resources)) {
        resource = private$resources_[index]
        
        if (is.null(resource) || !identical(resource$descriptor, descriptor) ||
            (!is.null(resource$schema) && length(resource$schema$foreignKeys>1))) {
          
          private$resources_[index] = Resource$new(descriptor, list(
            strict = private$strict_, basePath = private$basePath_#, dataPackage = this
          ))
        }
      }
      
    }
    
  )
  
  )

   
  # # Handle deprecated resource.path.url
  # for (resource in purrr::list_along(descriptor$resources)) {
  #   if (!is.null(resource$url)) {
  #     warning(
  #       'Resource property "url: <url>" is deprecated.
  #       Please use "path: <url>" instead.')
  #     resource$path = resource$url
  #     rm(resource.url)
  #   }
  # }
