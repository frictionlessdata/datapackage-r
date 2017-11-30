
Package2 <- R6::R6Class(
  
  "Package2",
  lock_object = FALSE,
  class = TRUE,
  public=list( 
    #strict=FALSE,
    initialize = function (descriptor = "{}", basePath=NULL, pattern=NULL, strict = FALSE, profile = config::get("DEFAULT_DATA_PACKAGE_PROFILE")  ) {
      
      private$currentDescriptor_ = descriptor
      private$nextDescriptor_ = descriptor
      private$profile_ = profile
      private$strict_ = strict
    },
    
    descriptor = function(){
      return(private$nextDescriptor_)
    },
    
    
    profile = function(){
      if (is.json(private$currentDescriptor_)|is.character(private$currentDescriptor_)) {
        private$profile_ = jsonlite::fromJSON(private$currentDescriptor_)$profile 
        if (is.null(private$profile_)) private$profile_ = jsonlite::fromJSON(private$currentDescriptor_)$resources$profile 
      }
      
      return(private$profile_)
    },
    
    valid = function () {
      return (isTRUE(length(private$errors_) == 0 && unlist(purrr::map(q, function(x) validate(jsonlite::toJSON(x))$valid)) )) #&& unlist(purrr::map(q, function(x) validate(jsonlite::toJSON(x))$valid))
    },
    
    commit = function (strict=FALSE) {
      
      if (is.logical(strict)) private$strict_ = strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_)) return (FALSE)
      private$currentDescriptor_ = private$nextDescriptor_
      # private$currentDescriptor_json = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = F)
      # private$build_()
      return (private$strict_)
    },
    
    save = function(target, type = "json") { #add name descriptor
      
      if (!is.json(private$currentDescriptor_)) private$currentDescriptor_ = jsonlite::toJSON(private$currentDescriptor_, pretty = TRUE)
      
      # if(type == "zip"){
      #   
      # write.csv(private$currentDescriptor_, file=stringr::str_c(target, "package.txt",sep = "/"))
      # 
      # } 
      else write(private$currentDescriptor_, file = stringr::str_c(target,"package.json", sep = "/"))
      
      save=stringr::str_interp('Package saved at: "${target}"')
      return(save)
      
    }
    
    
    ),
  private = list(
    currentDescriptor_ = NULL,
    nextDescriptor_ = NULL,
    profile_ = NULL,
    strict_ = NULL,
    build_ = function() {
      
      # Process descriptor
      
      ## think of making lists at this point
      
      if (!is.json(private$currentDescriptor_)) private$currentDescriptor_ = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = TRUE)
      private$currentDescriptor_ = expandPackageDescriptor(private$currentDescriptor_)
      private$nextDescriptor_ = private$currentDescriptor_
      
      
      # Instantiate profile
      private$profile_ = Profile.load(private$currentDescriptor_)$profile
      
      # Validate descriptor
      
      private$errors_ = list()
      
      valid_errors= private$profile_$validate(private$currentDescriptor_)
      
      if (!isTRUE(valid_errors$valid)) {
        private$errors_ = valid_errors$errors
        
        if (isTRUE(private$strict_)) {
          message = stringr::str_interp("There are ${length(valid_errors$errors)} validation errors (see 'valid_errors$errors')")
          DataPackageError$new(message)
        }
      }
      
      # Update resources
      
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


Package.load2 = function (descriptor="{}", basePath=NULL, strict = FALSE ) {
  
  # Get base path
  
  if (is.null(basePath)) {
    basePath = "C:/Users/Kleanthis-Okf/Documents/datapackage-r/inst/data" #locateDescriptor(descriptor)
  }
  
  # Process descriptor
  descriptor = jsonlite::toJSON(jsonlite::fromJSON(descriptor)) #retrieveDescriptor(descriptor)
  #descriptor = dereferencePackageDescriptor(descriptor, basePath)
  
  # Get profile
  
  fromjson = jsonlite::fromJSON(stringr::str_replace_all(descriptor, "[\r\n  ]" , "") )
  
  map_profile = purrr::compact(purrr::map(fromjson,"profile"))
  
  if ( (is.list(map_profile) & !purrr::is_empty(map_profile)) | (is.character(map_profile) & isTRUE(map_profile != "")) ) {
    
    descriptor.profile = unlist(map_profile)
    profile = Profile.load(descriptor.profile)
    
  } else profile = Profile.load(config::get("DEFAULT_DATA_PACKAGE_PROFILE") )
  
  
  return (Package2$new(descriptor, basePath, strict, profile) )
  
}
      