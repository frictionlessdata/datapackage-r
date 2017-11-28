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
    
    initialize = function (descriptor = "{}", basePath=NULL, pattern=NULL, strict = FALSE ) {

      # Set attributes
      private$descriptor_=descriptor
      private$currentDescriptor_ = descriptor
      private$nextDescriptor_ = descriptor
      private$basePath_ = basePath
      private$strict_ = strict
      #private$profile_ = NULL
      private$resources_ = list()
      private$errors_ = list()
      private$pattern_ = pattern

    },
    
    infer = function (pattern = FALSE) {
      
      # Files
      if (!isUndefined(pattern)) {
        
        # No base path
        if (is.null(private$basePath_)) {
          stop(DataPackageError$new('Base path is required for pattern infer'))
        }
        
        # Add resources
        files = findFiles(pattern, private$basePath_)
        for (file in files) {
        self$addResource( list(path = files[file]) )
        }
        
      }
      
      # Resources
      for (index in private$resources_) {
        descriptor = private$resources_[index]$infer #()
        private$currentDescriptor_$resources[index] = descriptor
        private$build_()
      }
      
      # Profile
      if(!isUndefined(private$nextDescriptor_$profile )){
      if (private$nextDescriptor_$profile == config::get("DEFAULT_DATA_PACKAGE_PROFILE") ) {
        if (length(private$resources)>=1 ){#&& private$resources.every(resouce => resouce.tabular)) {
          private$currentDescriptor_$profile = 'tabular-data-package'
          private$build_()
        }
      }}
      
      return (private$currentDescriptor_)
    },
    
    commit = function (strict=NULL) {
      if (is.logical(strict)) private$strict_ = strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_)) return (FALSE)
      private$currentDescriptor_ = private$nextDescriptor_
      private$currentDescriptor_json = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = F)
      private$build_()
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
      private$build_()
      return (private$resources_)
    },
    resourceNames = function () {
      return (purrr::map(private$resources_, names))
    },
    
    getResource = function (name) {
      private$resources_ = jsonlite::fromJSON(private$resources_)
      return (jsonlite::toJSON(purrr::compact(purrr::map(private$resources_, function (x) { i<-names(x) == name; x[which(i==TRUE)] } ))))
    },
    
    addResource = function (descriptor) {
      
      if (isUndefined(private$currentDescriptor_[["resources"]]) ) private$currentDescriptor_[["resources"]] = list()
      private$currentDescriptor_[["resources"]] = append(private$currentDescriptor_[["resources"]], self$descriptor)
      self$commit()
      return (private$resources_[[length(private$resources_) - 1]])
    },
    
    removeResource = function (name) {
      resource = self$getResource(name)
      if (!null(resource)){
        predicat = names(resource) != name
        private$currentDescriptor_$resources = purrr::keep(private$currentDescriptor_$resources, predicat)
        private$build_()
      }
      return (resource)
    }
    
    ),
  
  private = list(
    
    # # Handle deprecated resource.path.url
    # descriptor = jsonlite::fromJSON(descriptor)
    # for (resource in descriptor$resources) {
    #   if (!is.null(resource$url)) {
    #     warning(stringr::str_interp(
    #       'Resource property "url: <url>" is deprecated.
    #       Please use "path: <url>" instead.')
    #     resource$path = resource$url
    #     rm(resource.url)
    #   }
    # }
    # Set attributes
    currentDescriptor_ = NULL,
    nextDescriptor_ = NULL,
    basePath_ = NULL,
    strict_ = NULL,
    profile_ = NULL,
    resources_ = NULL,
    errors_ = NULL,
    descriptor_=NULL,
    pattern_=NULL,
    currentDescriptor_json = NULL,
    resources_length= NULL,
    build_ = function () {
      
      # Process descriptor
      
      #private$currentDescriptor_json = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = TRUE)
      private$currentDescriptor_ = expandPackageDescriptor(self$descriptor_)
      private$nextDescriptor_ = private$currentDescriptor_
      
      # Validate descriptor
      
      private$errors_ = list()
      
      valid_errors= private$profile_$validate(this._currentDescriptor)
      
      if (!isTRUE(valid_errors$valid)) {
        private$errors_ = valid_errors$errors
        
        if (isTRUE(private$strict_)) {
          message = stringr::str_interp("There are ${length(valid_errors$errors)} validation errors (see 'valid_errors$errors')")
          stop(DataPackageError$new(message))
        }
      }
      
      # Update resources
      private$resources_length = if (isUndefined(private$currentDescriptor_$resources)) length(list()) else length(private$currentDescriptor_$resources)
      descriptor = private$currentDescriptor_$resources
      
      for (index in private$currentDescriptor_$resources) {
        resource = private$resources_[index]
        
        if (isUndefined(resource) || !identical(resource$descriptor[index], private$descriptor$resources[index]) ||
            (!isUndefined(resource$schema) && length(resource$schema$foreignKeys>1))) {
          
          private$resources_[index] = Resource$new(descriptor, list(
            strict = private$strict_, basePath = private$basePath_, dataPackage = self
          ))
        }
      }
      
    }
    
  )
  
  )

#' Package.load
#' @param descriptor descriptor
#' @param basePath basePath
#' @param strict strict
#' @rdname Package.load
#' @export
Package.load = function (descriptor, basePath=NULL, strict = FALSE ) {
  
  # Get base path
  
  if (isUndefined(basePath)) {
    basePath = locateDescriptor(descriptor)
  }
  
  # Process descriptor
  #descriptor = retrieveDescriptor(descriptor)
  #descriptor = dereferencePackageDescriptor(descriptor, basePath)
  
  # Get profile
  
  fromjson = jsonlite::fromJSON(stringr::str_replace_all(descriptor, "[\r\n  ]" , "") )
  
  map_profile = purrr::map(fromjson,"profile")
  
  if (!isUndefined(map_profile) ) {
    descriptor.profile = unlist(map_profile)
    profile = Profile.load(descriptor.profile)
  } else profile = Profile.load(config::get("DEFAULT_DATA_PACKAGE_PROFILE") )
  
  
  return (Package$new(descriptor, basePath, strict, profile) )
  
}
