#' Resource class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

Resource <- R6Class(
  "Resource",
  
  public = list(
    
    load = function(descriptor = list(), basePath, strict = FALSE) {
      
      # Get base path
      if (isUndefined(basePath)) {
        basePath = locateDescriptor(descriptor)
      }
      
      # Process descriptor
      descriptor = retrieveDescriptor(descriptor)
      descriptor = dereferenceResourceDescriptor(descriptor, basePath)
      
      return (Resource$new(descriptor, basePath, strict)) #self
    },
    
    valid = function() {
      return (length(private$errors_== 0))
    },
    
    errors = function() {
      return (private$errors_)
    },
    
    profile = function() {
      return (private$profile_)
    },
    
    descriptor = function() {
      # Never use this.descriptor inside this class (!!!)
      return (private$nextDescriptor_)
    },
    
    name = function() {
      return (private$currentDescriptor_$name)
    }
    
    
    
    
  ),
  
  active =list(), private = list() )





# Internal

inspectSource = function (data, path, basePath) {
  inspection = list()
  
  # Normalize path
  if (!is.null(path) && !is.list(path)) {
    path = normalizePath(path)
  }
  
  # Blank
  if (is.null(data) && is.null(data)) {
    inspection$source = NULL
    inspection$blank = TRUE
    
    # Inline
  } else if (!is.null(data)) {
    inspection$source = data
    inspection$inline = TRUE
    inspection$tabular =  is.list(data) && purrr::every(is.list(data))
    
    # Local/Remote
  } else if (length(path) == 1) {
    
    # Remote
    if (isRemotePath(path[1])) {
      inspection$source = path[1]
      inspection$remote = TRUE
    } else if (!is.null(basePath) && isRemotePath(basePath)) {
      inspection$source = stringr::str_c(basePath, path[1])
      inspection$remote = TRUE
      
      # Local
    } else {
      
      # Path is not safe
      if (!isSafePath(path[1])) {
        stop(DataPackageError$new('Local path "${path[1]}" is not safe'))
      }
      
      # Not base path
      if (is.null(basePath)) {
        stop(DataPackageError$new('Local path "${path[1]}" requires base path'))
      }
      
      inspection$source = stringr::str_c(basePath, path[1], sep = '/')
      inspection$local = TRUE
    }
    
    # Inspect
    inspection$format = tools::file_ext(path[1])[1]
    inspection$name = basename(tools::list_files_with_exts(path[1], stringr::str_interp('.${inspection$format}') ))
    inspection$mediatype = stringr::str_interp('text/${inspection.format}')
    inspection$tabular = inspection$format == 'csv'
    
    # Multipart Local/Remote
  } else if (length(path) > 1) {
    inspections = purrr::map(path, function(item) inspectSource(NULL, item, basePath))
    assign(inspection, inspections[0])
    inspection$source = purrr::map(inspections, function(item) item$source)
    inspection$multipart = TRUE
  }
  
  return (inspection)
}

