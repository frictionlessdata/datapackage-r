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
    
    infer = function(pattern) {
      if (isTRUE(!is.null(pattern))) {
        # No base path
        if (is.null(private$basePath_)) {
          DataPackageError$new('Base path is required for pattern infer')
        }
        
        # Add resources
        files = findFiles(pattern, private$basePath_)
        for (file in files) {
          self$addResource(path = list(files[file]))
        }
      }
      
      # Resources
      for (index in length(private$resources_)) {
        descriptor = private$resources_[[index]]$infer()
        private$currentDescriptor_$resources[[index]] = descriptor
        private$build_()
      }
      # Profile
      if (!isUndefined(private$nextDescriptor_$profile)) {
        if (private$nextDescriptor_$profile == config::get("DEFAULT_DATA_PACKAGE_PROFILE")) {
          if (length(private$resources) >= 1) {
            #&& private$resources.every(resouce => resouce.tabular)) {
            private$currentDescriptor_$profile = 'tabular-data-package'
            private$build_()
          }
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
      private$table_ = NULL
      private$build_()
      return(TRUE)
    },
    
    save = function(target, type = "json") {
      #add name descriptor
      
      # if(type == "zip"){
      # write.csv(private$currentDescriptor_, file=stringr::str_c(target, "package.txt",sep = "/"))
      # }
      write(private$currentDescriptor_,
            file = stringr::str_c(target, "package.txt", sep = "/"))
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
      return(purrr::compact(lapply(private$resources_, names))) # maybe $resources
      # if(is.json(private$resources_)|is.character(private$resources_)) private$resources_ = jsonlite::fromJSON(private$resources_)
      # return (jsonlite::toJSON(purrr::compact(lapply(private$resources_, names)))) # maybe $resources
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
      
      for (index in private$resources_) {
        if (!isTRUE(private$resources_[index]$valid)) {
          errors = append(
            errors,
            DataPackageError$new(
              'Resource "${private$resources_[index]$name || index}" validation error(s)'
            )$message
          )
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
      private$resources_length = if (is.null(private$currentDescriptor_$resources)) {
        length(list())
      } else {
        length(private$currentDescriptor_$resources)
      }
      

      if (private$resources_length > 0) {
        for (index in 1:private$resources_length) {
          descriptor = private$currentDescriptor_$resources[[index]]
       
          if (index > length(private$resources_) ||
              !identical(resource$descriptor, descriptor) ||
              (!is.null(resource$schema) &&
               length(resource$schema$foreignKeys >= 1))) {
            
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

#' Package.load
#' @param descriptor descriptor
#' @param basePath basePath
#' @param strict strict
#' @rdname Package.load
#' @export
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

  profile.to.load = if (is.null(descriptor$profile))
    config::get("DEFAULT_DATA_PACKAGE_PROFILE", file = "config.yaml")
  else
    descriptor$profile
  
  profile = Profile.load(profile.to.load)
  
  
  return(Package$new(descriptor, basePath, strict = strict, profile = profile))
  
}
