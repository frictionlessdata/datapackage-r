#' Profile class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

# Module API

Profile <- R6::R6Class(
  
  "profile",
  
  # Public
  
  # https://github.com/frictionlessdata/datapackage-js#profile
  
  public = list(
    
    initialize = function (profile) {
      private$profile_ = private$build_(profile)

      },
    
    
    
    # https://github.com/frictionlessdata/datapackage-js#profile
    
    name = function() {
      
      base.name = basename(private$jsonschema_)
      file.ext = tools::file_ext(private$jsonschema_)
      remove.ext = stringr::str_replace(base.name, paste0(".",file.ext),"")
      private$jsonschema_.title = stringr::str_replace_all(remove.ext,"-"," ")
      if (is.null(private$jsonschema_.title)) return (NULL)
      
      return (tolower(private$jsonschema_.title))
      
    },
    
    # https://github.com/frictionlessdata/datapackage-js#profile
    
    jsonschema = function() {
      return (private$jsonschema_) # private$jsonschema.contents_
    },
    jsonschema.contents = function() {
      return (private$jsonschema.contents_) # private$jsonschema.contents_
    },
    
    # https://github.com/frictionlessdata/datapackage-js#profile
    
    validate = function(descriptor) {
      
      errors = list()
      
      # Basic validation
      #private$jsonschema_=private$build_(descriptor)
      validation = validate(descriptor)
      
      purrr::map(validation[["errors"]], function() {
        
        push(errors ,stringr::str_interp(
          'Descriptor validation error:
            ${validationError.message}
            at "${validationError.dataPath}" in descriptor and
            at "${validationError.schemaPath}" in profile')
        )
      })
      
      return ( 
        list( valid = validation$valid,
              errors = validation$errors
        )
      )
       
    }
  ),
  
  # Private
  private = list(
    jsonschema.contents_ = NULL,
    jsonschema_ = NULL,
    profile_ = NULL,
    jsonschema_.title = NULL,
    build_ = function(profile) {
      
      # Registry
      
      if (is.character(profile)) {
        
        tryCatch({
          
          profile =  system.file(stringr::str_interp("profiles/${profile}.json"), package = "datapackage.r")
          jsonschema.contents = jsonlite::toJSON(jsonlite::fromJSON(profile))
        },
        
        error= function(e) {
          DataPackageError$new(stringr::str_interp("Profiles registry hasn't profile '${profile}'"))
        })
      }
      
      private$jsonschema_ = profile
      private$jsonschema.contents_ = jsonschema.contents
    }
  )
)

#' Profile.load
#' @rdname Profile.load
#' @export
Profile.load = function (profile) {
  
  # Remote
  
  if (is.character(profile) && isRemotePath(profile) ) {
    
    jsonschema = profile
    
    if (is.null(jsonschema)) {
      
      tryCatch( {
        response = httr::GET(profile)
        
        jsonschema = httr::content(response, as = 'text')
      },
      
      error= function(e) {
        DataPackageError$new(stringr::str_interp("Can not retrieve remote profile '${profile}'"))$message
      })
      
      #cache_[profile] = jsonschema
      profile = jsonschema
    } else profile = urltools::host_extract(urltools::domain(basename(profile)))$host
  }
  
  return (Profile$new(profile))
  
}
# Internal

cache_ = list()
