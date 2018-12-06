#' Profile class
#' @description Class to represent JSON Schema profile from \href{https://frictionlessdata.io/schemas/registry.json}{Profiles Registry}.
#' 
#' @usage # Profile.load(profile)
#' @param profile string profile name in registry or URL to JSON Schema
#' 
#' 
#' @section Methods:
#' \describe{
#' 
#' \item{\code{Profile$new(descriptor = descriptor)}}{
#' Use \code{\link{Profile.load}} to instantiate \code{Profile} class.}
#' 
#'   \item{\code{validate(descriptor)}}{
#' Validate a tabular data package descriptor against the \code{Profile}.}
#' \itemize{
#'  \item{\code{descriptor }}{Retrieved and dereferenced tabular data package descriptor.}  
#'  \item{\code{(Object) }}{Returns \code{TRUE} if descriptor is valid or \code{FALSE} with error message.}
#'  }
#'
#' }
#' 
#' @section Properties:
#' \describe{
#'   \item{\code{name}}{Returns profile name if available.}
#'   \item{\code{jsonschema}}{Returns profile JSON Schema contents.}
#' }
#' 
#' @seealso \href{http://frictionlessdata.io/specs/profiles/}{Profile Specifications}
#' 
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.
#' 

Profile <- R6::R6Class(
  
  "Profile",
  
  # Public
  
  # https://github.com/frictionlessdata/datapackage-r#profile
  lock_objects = FALSE,
  class = TRUE,
  public = list(
    
    initialize = function(profile) {
      
      private$profile_ = profile
      
      if (is.character(unlist(private$profile_))) {
        
        private$profile_ =system.file(stringr::str_interp("profiles/${private$profile_}.json"), package = "datapackage.r")
        # private$profile_ =  stringr::str_interp("inst/profiles/${private$profile_}\.json")
        
        if(private$profile_ =="" | is.null(private$profile_)) {
          
          private$message.error_ = DataPackageError$new(stringr::str_interp("Profiles registry hasn't profile '${profile}'"))$message
          private$profile_ = private$message.error_
          
          stop(DataPackageError$new(private$profile_)$message)
        }
      }
      
      private$jsonschema_ = helpers.from.json.to.list(private$profile_)
      
    },
    
    validate = function(descriptor){
      
      if (is.character(descriptor) && isTRUE(jsonlite::validate(descriptor))){
        descriptor2 = descriptor
      } else {
        descriptor2 = helpers.from.list.to.json(descriptor)
      }
      
      vld = is.valid(descriptor2, helpers.from.list.to.json(private$jsonschema_))
      
      private$validation_$valid = vld$valid
      
      private$validation_$errors = vld$errors
      
      
      errors = list()
      
      for (i in rownames(private$validation_$errors)) {
        
        errors = c(errors, stringr::str_interp(
          'Descriptor validation error:
            ${private$validation_$errors [i, "field"]} - ${private$validation_$errors [i, "message"]}'
          
        )
        )
        
        
        
        
      }
      
      return(list(valid = length(errors) < 1, errors = errors))      
    }
  ),
  
  active = list(
    
    name=function(x){
      
      profile_title = helpers.from.json.to.list(private$profile_)$title
      
      private$jsonschema_title = stringr::str_replace_all(profile_title," ","-")
      
      if (is.null(private$jsonschema_title)) return (NULL)
      
      private$jsonschema_title = tolower(private$jsonschema_title)
      if (!missing(x)) private$jsonschema_title = x
      return (private$jsonschema_title)
      
      # profile_title = jsonlite::fromJSON(private$profile_)$title
      # private$jsonschema_title = stringr::str_replace_all(profile_title," ","-")
      # if (is.null(private$jsonschema_title)) return (NULL)
      # return (tolower(private$jsonschema_title))
    },
    
    jsonschema=function(x){
      #private$jsonschema_ = jsonlite::fromJSON(private$jsonschema_)
      # if(is.character(private$jsonschema_) && jsonlite::validate(private$jsonschema_))private$jsonschema_ = helpers.from.json.to.list(private$profile_)
      # private$jsonschema_ = jsonlite::toJSON(jsonlite::fromJSON(private$profile_))
      if (!missing(x)) private$jsonschema_ = x
      return(private$jsonschema_)
    }
    
  ),
  
  private = list(
    
    profile_=NULL,
    jsonschema_=NULL,
    jsonschema_title = NULL,
    validation_=list(valid=TRUE,errors=list()),
    message.error_ = NULL
    
  ))

#' Instantiate \code{Profile} class
#' 
#' @description Constuctor to instantiate \code{\link{Profile}} class.
#' @param profile string profile name in registry or URL to JSON Schema
#' 
#' @return \code{\link{Profile}} class object
#' 
#' @rdname Profile.load
#' 
#' @export
#' 

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
