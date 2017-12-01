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
  
  # https://github.com/frictionlessdata/datapackage-r#profile
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

    validate = function(descriptor){
      if (!is.json(descriptor)|is.character(descriptor)) descriptor2=jsonlite::toJSON(descriptor)
      vld = is.valid(descriptor2,jsonlite::toJSON(private$jsonschema_))
      private$validation_$valid = vld$valid
      private$validation_$errors = vld$errors
      for (validationError in nrow(private$validation_$errors)) {
        private$validation_$errors = append(private$validation_$errors ,stringr::str_interp(
          'Descriptor validation error:
          "${private$validation_$errors$field[validationError]}" in descriptor
          ${private$validation_$errors$message[validationError]}.')
        )
      }
      
      return (private$validation_)
      
      }
  ),
  active = list(
    
    name=function(){
      
      profile_title = jsonlite::fromJSON(private$profile_)$title
      private$jsonschema_title = stringr::str_replace_all(profile_title," ","-")
      if (is.null(private$jsonschema_title)) return (NULL)
      return (tolower(private$jsonschema_title))
      
      # profile_title = jsonlite::fromJSON(private$profile_)$title
      # private$jsonschema_title = stringr::str_replace_all(profile_title," ","-")
      # if (is.null(private$jsonschema_title)) return (NULL)
      # return (tolower(private$jsonschema_title))
    },
    jsonschema=function(){
      private$jsonschema_ = jsonlite::fromJSON(private$profile_)
      # private$jsonschema_ = jsonlite::toJSON(jsonlite::fromJSON(private$profile_))
      return(private$jsonschema_)
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
