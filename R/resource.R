#' Resource class
#' 
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

Resource <- R6::R6Class(
  "Resource",
  
  public = list(
    initialize = function (descriptor = list(), basePath, strict = FALSE, dataPackage = list()) {
      # Set attributes
      private$strict_ = strict
      private$errors_ = NULL
      private$profile_ = NULL
      private$nextDescriptor_ = descriptor
      private$currentDescriptor_ = descriptor
      private$dataPackage_ = dataPackage
      private$basePath_ = basePath

      # Deprecate
      private$table = private$getTable_()
      
    },
    iter = function(relations = FALSE, options = list()) {},
    read = function(relations = FALSE, options = list()) {},
    checkRelations = function() {},
    rawIter = function(stream = FALSE){},
    rawRead = function() {},
    infer = function() {},
    commit = function (strict) {},
    save = function(target) {}
    
  ),
  
  active = list(
    
    valid= function () {
      return(isTRUE(length(private$errors_)== 0))
      },
    
    errors = function () {
      return(private$errors_)
      },
    
    profile = function () {
      return(private$profile_)
      },
    
    descriptor = function () {
      return(private$nextDescriptor_)
      }, # Never use self.descriptor inside self class (!!!)
    
    name = function () {
      return(currentDescriptor_$name)
      },
    
    inline = function () {
      return(private$sourceInspection_$inline)
      },
    
    local = function () {
      return(private$sourceInspection_$local)
      },
    
    remote = function () {
      return(private$sourceInspection_$remote)
      },
    
    multipart = function () {
      return(private$sourceInspection_$multipart)
      },
    
    tabular = function () {
      if (isTRUE(private$currentDescriptor_$profile == 'tabular-data-resource')) return(TRUE)
      if (!isTRUE(private$strict_)) {
        if(config::get("TABULAR_FORMATS") %in% private$currentDescriptor_$format) return(TRUE)
        if(isTRUE(private$sourceInspection_$tabular)) return(TRUE)
      }
      return(FALSE)
    },
    
    source = function () {
      return(private$sourceInspection_$source)
      },
    
    headers = function () {
      if (!isTRUE(self$tabular)) return(NULL) else return(private$getTable_()$headers)
      },
    
    schema = function () {
      if (!isTRUE(self$tabular)) return(NULL) else return(private$getTable_()$schema)
    }
    
  ),
  private = list(
    # Set attributes
    strict_ = NULL,
    errors_ = NULL,
    profile_ = NULL,
    nextDescriptor_ = NULL,
    currentDescriptor_ = NULL,
    sourceInspection_ = NULL,
    dataPackage_ = NULL,
    basePath_ = NULL,
    
    build_ = function () {},
    getTable_ = function () {},
    getRelations_ = function () {},
    # Deprecated
    table = NULL
  )
)

#' Resource.load
#' @param descriptor descriptor
#' @param basePath basePath
#' @param strict strict
#' @rdname Resource.load
#' @export

Resource.load = function (descriptor = list(), basePath=NULL, strict = FALSE) {
  
  # Get base path
  if (isUndefined(basePath)) basePath = locateDescriptor(descriptor)
  
  # Process descriptor
  descriptor = retrieveDescriptor(descriptor)
  #descriptor = dereferenceResourceDescriptor(descriptor, basePath)
  
  return (Resource$new(descriptor, basePath, strict))
}


inspectSource = function (data, path, basePath) {
  
  inspection = list()
  
  # Normalize path
  if (isTRUE(path) && !is.list(path) ) path = {path} #normalizePath(basePath)
  
  # Blank
  if (!isTRUE(data) && !isTRUE(path)) {
    inspection$source = NULL
    inspection$blank = TRUE 
    
  # Inline  
  } else if (isTRUE(data)) {
    inspection$source = data
    inspection$inline = TRUE
    inspection$tabular = is.list(data) && purrr::every(data, "is.list")
    
  # Local/Remote
  } else if (length(path) == 1) {
    
    # Remote
    if (isRemotePath(path[1])) {
      inspection$source = path[1]
      inspection$remote = TRUE
  } else if (isTRUE(basePath) && isRemotePath(basePath)) {
    inspection$source = stringr::str_c(basePath, path[1], sep = "/")
    inspection$remote = TRUE
    
    # Local
  } else {
    # Path is not safe
    if (!isTRUE(isSafePath(path[1]))) {
      DataPackageError$new('Local path "${path[1]}" is not safe')
    }
    # Not base path
    if (!isTRUE(basePath)) {
      DataPackageError$new('Local path "${path[1]}" requires base path')
    }
    
    inspection$source = stringr::str_c(basePath, path[1], sep = '/')
    inspection$local = TRUE
  }
    
    # Inspect
    inspection$format = tools::file_ext(path[1])[1]
    inspection$name = basename(tools::list_files_with_exts(dir=path, exts=stringr::str_interp('.${inspection$format}') ))
    inspection$mediatype = stringr::str_interp('text/${inspection$format}')
    inspection$tabular = inspection$format %in% config::get("TABULAR_FORMATS")
    
    
    
    # Multipart Local/Remote
  } else if (length(path) > 1) {
    inspections = purrr::map(path, function(item) inspectSource(NULL, item, basePath))
    assign(inspection, inspections[1])
    inspection$source = purrr::map(inspections, function(item) item$source)
    inspection$multipart = TRUE
  }
  
  return (inspection)

}


createByteStream = function (source, remote=NULL) {
  
  stream=list()
  
  # Remote source
  if (isTRUE(remote)) {
    
    response = httr::GET(source) #await axios.get(source)
    response.data = httr::content(response, as = 'text')
    stream = tableschema.r::Readable$new()
    push(stream, response.data)
    push(stream, NULL)
    # response = await axios.get(source, {responseType: 'stream'})
    # stream = response.data
    
    # Local source
  } else {
    # if (config.IS_BROWSER) {
    #   stop(DataPackageError$new('Local paths are not supported in the browser'))
    # } else {
    connection = file(source)
    stream = tableschema.r::ReadableConnection$new(options = list(source = connection))
  }
  
  return (stream)
}
