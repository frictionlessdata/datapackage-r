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
  lock_object = FALSE,
  class = TRUE,
  public=list( 
    #strict=FALSE,
    initialize = function (descriptor = list(), basePath=NULL, pattern=NULL, strict = FALSE, profile = config::get("DEFAULT_DATA_PACKAGE_PROFILE",file = "config.yaml")  ) {
      
      private$currentDescriptor_ = descriptor
      private$nextDescriptor_ = descriptor
      private$profile_ = profile
      private$strict_ = strict
      private$resources_=list()
      
    },
    
    infer = function (pattern = FALSE) {
      
      if (isTRUE(pattern)) {
        
        # No base path
        if (is.empty(private$basePath_)) {
          DataPackageError$new('Base path is required for pattern infer')
        }
        
        # Add resources
        files = findFiles(pattern, private$basePath_)
        for (file in files) {
          self$addResource( list(path = files[file]) )
        }
      }
      
      # Resources
      for (index in length(private$resources_)) {
        descriptor = private$resources_[[index]]$infer()
        private$currentDescriptor_$resources[[index]] = descriptor
        private$build_()
      }
      # Profile
      if (isTRUE(private$nextDescriptor_$profile == config::get("DEFAULT_DATA_PACKAGE_PROFILE",file = "config.yaml"))) {
        
        if (length(private$resources)>=1 && isTRUE(purrr::every(private$resources_, function(resource) !is.empty(resource$tabular))) ) {
          private$currentDescriptor_$profile = 'tabular-data-package'
          private$build_()
      }}
        
      
    },
    
    getResource = function (name) {
      return (purrr::compact(purrr::map(private$resources_, function (x) { i<-names(x) == name; x[which(i==TRUE)] } )))
      # if(is.json(private$resources_)|is.character(private$resources_)) private$resources_ = jsonlite::fromJSON(private$resources_)
      # return (jsonlite::toJSON(purrr::compact(purrr::map(private$resources_, function (x) { i<-names(x) == name; x[which(i==TRUE)] } ))))
    },
    
    addResource = function (descriptor) {
      if ( is.empty(private$currentDescriptor_[["resources"]]) ) private$currentDescriptor_[["resources"]] = list()
      private$currentDescriptor_[["resources"]] = push(private$currentDescriptor_[["resources"]], descriptor)
      private$build_()
      # descriptor = jsonlite::fromJSON(descriptor)
      # if ( is.empty(private$currentDescriptor_[["resources"]]) ) private$currentDescriptor_[["resources"]] = list()
      # private$currentDescriptor_[["resources"]] = push(private$currentDescriptor_[["resources"]], descriptor)
      # private$build_()
      return (private$resources_)
    },
    
    removeResource = function (name) {
      resource = self$getResource(name)
      if (!is.empty(resource)|exists(resource)){
        private$currentDescriptor_$resources = purrr::compact(purrr::map(resource, function (x) { i<-names(x) == name; x[which(i==TRUE)] } ))
        private$build_()
      }
      # resource = self$getResource(name)
      # if (is.json(resource)|is.character(resource)) resource = jsonlite::fromJSON(resource)
      # if (!is.empty(resource)|exists(resource)){
      #   private$currentDescriptor_$resources = purrr::compact(purrr::map(resource, function (x) { i<-names(x) == name; x[which(i==TRUE)] } ))
      #   private$build_()
      # }
      return (resource)
    },
    
    commit = function (strict=FALSE) {
      
      if (is.logical(strict)) private$strict_ = strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_)) return (FALSE)
      private$currentDescriptor_ = private$nextDescriptor_
      private$table_=NULL
      private$build_()
      return (private$strict_)
    },
    
    save = function(target, type = "json") { #add name descriptor
      
      # if(type == "zip"){
      # write.csv(private$currentDescriptor_, file=stringr::str_c(target, "package.txt",sep = "/"))
      # } 
      write(private$currentDescriptor_, file = stringr::str_c(target,"package.txt", sep = "/"))
      save=stringr::str_interp('Package saved at: "${target}"')
      return (save)
      
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
    
    descriptor = function() {
      return (private$nextDescriptor_)
    },
    
    resourceNames = function () {
      return (purrr::compact(lapply(private$resources_, names))) # maybe $resources
      # if(is.json(private$resources_)|is.character(private$resources_)) private$resources_ = jsonlite::fromJSON(private$resources_)
      # return (jsonlite::toJSON(purrr::compact(lapply(private$resources_, names)))) # maybe $resources
    },
    
    profile = function() {
      if (is.null(private$profile_)) private$profile_ = private$currentDescriptor_$resources$profile 
      return (private$profile_)
      
      # if (is.json(private$currentDescriptor_)|is.character(private$currentDescriptor_)) {
      #   private$profile_ = jsonlite::fromJSON(private$currentDescriptor_)$profile 
      #   if (is.null(private$profile_)) private$profile_ = jsonlite::fromJSON(private$currentDescriptor_)$resources$profile 
      # }
      # return (private$profile_)
    },
    
    valid = function () {
      return (isTRUE(length(private$errors_) == 0 && unlist(purrr::map(private$resources_, function(x) validate(jsonlite::toJSON(x))$valid)) )) #&& unlist(purrr::map(q, function(x) validate(jsonlite::toJSON(x))$valid))
      # return (isTRUE(length(private$errors_) == 0 && unlist(purrr::map(private$resources_, function(x) validate(jsonlite::toJSON(x))$valid)) )) #&& unlist(purrr::map(q, function(x) validate(jsonlite::toJSON(x))$valid))
    },
    
    errors = function() {
      
    }, 
    
    resources = function() {
      return (private$resources_)
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
    
    currentDescriptor_ = NULL,
    nextDescriptor_ = NULL,
    profile_ = NULL,
    strict_ = NULL,
    errors_ = list(),
    resources_=NULL,
    build_ = function() {
      
      # Process descriptor
      
      ## think of making lists at this point
      
      #if (!is.json(private$currentDescriptor_)) private$currentDescriptor_ = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = TRUE)
      private$currentDescriptor_ = expandPackageDescriptor(private$currentDescriptor_)
      private$nextDescriptor_ = private$currentDescriptor_
      
      
      # Instantiate profile
      private$profile_ = Profile.load(private$currentDescriptor_)$profile
      
      # Validate descriptor
      #private$errors_=list()
      
      valid_errors= private$profile_$validate(private$currentDescriptor_)
      
      if (!isTRUE(valid_errors$valid)) {
        private$errors_ = valid_errors$errors
        
        if (isTRUE(private$strict_)) {
          message = stringr::str_interp("There are ${length(valid_errors$errors)} validation errors (see 'valid_errors$errors')")
          DataPackageError$new(message)
        }
      }
      
      # Update resources
      # list current descriptor
      for (index in private$currentDescriptor_$resources) {
        #private$resources_[index]
        
        if ( purrr::is_empty(private$resources_[index]) || 
             !identical(private$resources_[index]$descriptor, private$currentDescriptor_$resources[index]) ||
             (!purrr::is_empty((private$resources_[index]$schema)) && length(private$resources_[index]$schema$foreignKeys)>1)) {
          
          private$resources_[index] = Resource.load( private$currentDescriptor_$resources[index],
                                                     strict = private$strict_, 
                                                     basePath = private$basePath_, 
                                                     dataPackage = self)
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

Package.load = function (descriptor=list(), basePath=NULL, strict = FALSE ) {
  
  # Get base path
  
  if (is.null(basePath)) {
    basePath = locateDescriptor(descriptor)
  }
  
  # Process descriptor
  descriptor = retrieveDescriptor(descriptor)
  descriptor = dereferencePackageDescriptor(descriptor, basePath)
  
  # Get profile
  
  # fromjson = jsonlite::fromJSON(stringr::str_replace_all(descriptor, "[\r\n  ]" , "") )
  # 
  # map_profile = purrr::compact(purrr::map(fromjson,"profile"))
  # 
  # if ( (is.list(map_profile) & !purrr::is_empty(map_profile)) | (is.character(map_profile) & isTRUE(map_profile != "")) ) {
  #   
  #   descriptor.profile = unlist(map_profile)
    # profile = Profile.load(descriptor.profile)
    
  # } else 
    descriptor.profile = if (is.null(descriptor$profile)) config::get("DEFAULT_DATA_PACKAGE_PROFILE",file = "config.yaml") else descriptor$profile
    profile = Profile.load(descriptor.profile)
    
  # descriptor = jsonlite::fromJSON(descriptor)
  return (Package$new(descriptor, basePath, strict, profile) )
  
}
