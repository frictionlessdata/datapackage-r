#' Profile class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

# Module API

Profile <- R6Class(
  
  "profile",
  
  # Public
  
  # https://github.com/frictionlessdata/datapackage-js#profile
  
  public = list(
    
    # static async 
    
    load = function(profile) {
      
      # Remote
      
      if (is.character(profile) && isRemotePath(profile) ) {
        
        jsonschema = cache_[profile]
        
        if (is.null(jsonschema)) {
          
            tryCatch( {
              response = httr::GET(profile)
              
              jsonschema = httr::content(response, as = 'text')
            },
            
            error= function(e) {
              DataPackageError$new(stringr::str_interp("Can not retrieve remote profile '${profile}'"))
            })
          
          cache_[profile] = jsonschema
          profile = jsonschema
        }
      }
      
      return (Profile$new(profile))
      
    },
    
    # https://github.com/frictionlessdata/datapackage-js#profile
    
    name = function() {
      
      if (is.null(private$jsonschema_$title)) return (NULL)
      
      return (tolower(gsub(private$jsonschema_$title(' ', '-'))))
      
    },
    
    # https://github.com/frictionlessdata/datapackage-js#profile
    
    jsonschema = function() {
      return (private$jsonschema_)
    },
    
    # https://github.com/frictionlessdata/datapackage-js#profile
    
    validate(descriptor) {
      
      errors = list()
      
      # Basic validation
      
      validation = is.valid(descriptor, private$jsonschema_)
      
      map(validation[["errors"]], function() {
        
        push(errors ,stringr::str_interp(
          'Descriptor validation error:
            ${validationError.message}
            at "${validationError.dataPath}" in descriptor and
            at "${validationError.schemaPath}" in profile')
        )
      })
      
      return ( 
        list( valid= !errors.length,
              εrrors
        )
      )
       
    }
  ),
  
  # Private
  private = list(
    
    constructor = function(profile) {
      
      # Registry
      
      if (is.character(profile)) {
        
        tryCatch({
          
          profile =  system.file(stringr::str_interp("./profiles/${profile}.json"), package = "datapackage.r")
        },
        
        error= function(e) {
          DataPackageError$new(stringr::str_interp("Profiles registry hasn't profile '${profile}'"))
        })
      }
      
      private$jsonschema_ = profile
    }
  )
)

# Internal

cache_ = list()
