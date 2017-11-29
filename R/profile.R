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
  lock_object = FALSE,
  class = TRUE,
  public = list(
    initialize=function(profile){
      
      private$profile_ = system.file(stringr::str_interp("profiles/${profile}.json"), package = "datapackage.r")
      if(private$profile_=="") {
        private$message.error_ = DataPackageError$new(stringr::str_interp("Profiles registry hasn't profile '${profile}'"))
        private$profile_ = private$message.error_
        stop(DataPackageError$new(private$profile_))
      }
      return(private$profile_)
    },
    name=function(){
      profile_title = jsonlite::fromJSON(private$profile_)$title
      private$jsonschema_title = stringr::str_replace_all(profile_title," ","-")
      
      if (is.null(private$jsonschema_title)) return (NULL)
      
      return (tolower(private$jsonschema_title))
    },
    jsonschema=function(){
      private$jsonschema_ = jsonlite::toJSON(jsonlite::fromJSON(private$profile_))
      return(private$jsonschema_)
    },
    validate = function(descriptor){
      
      private$validation_$valid = is.valid(descriptor,private$schema)
      
      for (validationError in nrow(attr(private$validation_$valid,"errors"))) {
        
        private$validation_$errors = append(private$validation_$errors ,stringr::str_interp(
          'Descriptor validation error:
          "${attr(private$validation_$valid,"errors")$field[validationError]}" in descriptor
          ${attr(private$validation_$valid,"errors")$message[validationError]}.')
        )
      }
      
      return (private$validation_)
      
      }
  ),
  private = list(
    profile_=NULL,
    jsonschema_=NULL,
    jsonschema_title = NULL,
    validation_=list(valid=TRUE,errors=list()),
    message.error_ = "None"
  ))

#' Profile.load
#' @param profile profile
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
