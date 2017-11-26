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
    
    load = function (descriptor = {}, basePath, strict = FALSE ) {
      
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

  ))



