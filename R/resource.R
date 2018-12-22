#' Resource class
#' 
#' @description A class for working with data resources. You can read or iterate tabular resources 
#' using the \code{iter}/ \code{read} methods and all resource as bytes using 
#' \code{rowIter}/ \code{rowRead} methods.
#' 
#' @usage # Resource.load(descriptor = list(), basePath = NA, strict = FALSE, dataPackage = list())
#' 
#' 
#' @section Methods:
#' 
#' \describe{
#' 
#' \item{\code{Resource$new(descriptor = descriptor, strict = strict)}}{
#' Use \code{\link{Resource.load}} to instantiate \code{Resource} class.}
#' 
#' 
#' 
#' \item{\code{iter(keyed, extended, cast = TRUE, relations = FALSE, stream = FALSE)}}{
#'   Only for tabular resources - Iter through the table data and emits rows cast based on table schema. Data casting could be disabled.}
#' \itemize{
#'  \item{\code{keyed }}{Iter keyed rows - \code{TRUE}/ \code{FALSE}.}  
#'  \item{\code{extended }}{Iter extended rows - \code{TRUE}/\code{FALSE}.}
#'  \item{\code{cast }}{Disable data casting if \code{FALSE}.}
#'  \item{\code{relations }}{If \code{TRUE} foreign key fields will be checked and resolved to its references.}
#'  \item{\code{stream }}{Return Readable Stream of table rows if \code{TRUE}.}
#'  }
#' 
#' 
#' \item{\code{read(keyed, extended, cast = TRUE, relations = FALSE, limit)}}{
#'   Only for tabular resources. Read the whole table and returns as list of rows. Count of rows could be limited.}
#' \itemize{
#'  \item{\code{keyed }}{Flag to emit keyed rows - \code{TRUE}/\code{FALSE}.}  
#'  \item{\code{extended }}{Flag to emit extended rows - \code{TRUE}/\code{FALSE}.}
#'  \item{\code{cast }}{Disable data casting if \code{FALSE}.}
#'  \item{\code{relations }}{If \code{TRUE} foreign key fields will be checked and resolved to its references.}
#'  \item{\code{limit }}{Integer limit of rows to return if specified.}
#'  }
#'  
#' \item{\code{checkRelations()}}{Only for tabular resources. It checks foreign keys and raises an exception if there are integrity issues.
#' Returns \code{TRUE} if no issues.}
#'
#' \item{\code{rawIter(stream = FALSE)}}{
#' Iterate over data chunks as bytes. If stream is \code{TRUE} Iterator will be returned.}
#' \itemize{
#'  \item{\code{stream }}{Iterator will be returned.}
#'  }
#'
#' \item{\code{rawRead()}}{Returns resource data as bytes.}
#' 
#' \item{\code{infer()}}{
#' Infer resource metadata like name, format, mediatype, encoding, schema and profile. It commits this changes into resource instance.
#' Returns resource descriptor.}
#'  
#' \item{\code{commit(strict)}}{
#' Update resource instance if there are in-place changes in the descriptor. Returns \code{TRUE} on success and \code{FALSE} if not modified.}
#' \itemize{
#'  \item{\code{strict }}{Boolean - Alter strict mode for further work.}
#'  }
#'  
#' \item{\code{save(target)}}{
#' For now only descriptor will be saved. Save resource to target destination.}
#' \itemize{
#'  \item{\code{target }}{String path where to save a resource.}
#'  }
#' }
#' 
#' 
#' @section Properties:
#' \describe{
#'   \item{\code{valid}}{Returns validation status. It always \code{TRUE} in strict mode.}
#'   \item{\code{errors}}{Returns validation errors. It always empty in strict mode.}
#'   \item{\code{profile}}{Returns an instance of \code{\link{Profile}} class.}
#'   \item{\code{descriptor}}{Returns list of resource descriptor.}
#'   \item{\code{name}}{Returns a string of resource name.}
#'   \item{\code{inline}}{Returns \code{TRUE} if resource is inline.}
#'   \item{\code{local}}{Returns \code{TRUE} if resource is local.}
#'   \item{\code{remote}}{Returns \code{TRUE} if resource is remote.}
#'   \item{\code{multipart}}{Returns \code{TRUE} if resource is multipart.}
#'   \item{\code{tabular}}{Returns \code{TRUE} if resource is tabular.}
#'   \item{\code{source}}{Returns a list/string of data/path property respectively.}
#'   \item{\code{headers}}{Returns a string of data source headers.}
#'   \item{\code{schema}}{Returns a \code{Schema} instance to interact with data schema. Read API documentation - \href{https://github.com/frictionlessdata/tableschema-r#schema}{tableschema.Schema} or \link[tableschema.r]{Schema}}
#'  }
#'
#'  
#' @section Details:
#' The Data Resource format describes a data resource such as an individual file or table.
#' The essence of a Data Resource is a locator for the data it describes.
#' A range of other properties can be declared to provide a richer set of metadata.
#' 
#' Packaged data resources are described in the resources property of the package descriptor. 
#' This property \code{MUST} be an array of objects. Each object \code{MUST} follow the \href{https://frictionlessdata.io/specs/data-resource/}{Data Resource specification}.
#'  
#' @section Language:
#' The key words \code{MUST}, \code{MUST NOT}, \code{REQUIRED}, \code{SHALL}, \code{SHALL NOT}, 
#' \code{SHOULD}, \code{SHOULD NOT}, \code{RECOMMENDED}, \code{MAY}, and \code{OPTIONAL} 
#' in this package documents are to be interpreted as described in \href{https://www.ietf.org/rfc/rfc2119.txt}{RFC 2119}.
#' 
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}}.
#' @format \code{\link{R6Class}} object.
#' @seealso \code{\link{Resource.load}}, 
#' \href{https://frictionlessdata.io/specs/data-resource/}{Data Resource Specifications}
#' 

Resource <- R6Class(
  "Resource",
  
  public = list(
    initialize = function(descriptor, basePath, strict = FALSE, dataPackage = list()) {
      # Set attributes
      private$strict_ <- strict
      private$errors_ <- NULL
      private$profile_ <- NULL
      private$nextDescriptor_ <- descriptor
      private$currentDescriptor_ <- descriptor
      private$dataPackage_ <- dataPackage
      private$basePath_ <- basePath
      
      # Build instance
      private$build_()
      
      
    },
    
    iter = function(relations = FALSE, options = list()) {
      
      # Error for non tabular
      if(!isTRUE(self$tabular)){
        stop(DataPackageError$new('Methods iter/read are not supported for non tabular data')$message)
      }
      
      # Get relations
      if (isTRUE(relations)) {
        relations <- private$getRelations_()
      }
      
      return(private$getTable_()$iter(relations, options))
    },
    
    read = function(relations = FALSE, ...) {
      
      # Error for non tabular
      if (!isTRUE(self$tabular)) {
        stop(DataPackageError$new('Methods iter/read are not supported for non tabular data')$message)
      }
      
      # Get relations
      if (isTRUE(relations)) {
        relations <- private$getRelations_()
      }
      
      return(private$getTable_()$read(relations = relations, ...))
    },
    
    checkRelations = function() {
      if (isTRUE(!is.null(self$read(relations = TRUE))))
        return(TRUE)
    },
    
    rawIter = function(stream = FALSE){
      # Error for inline
      if (isTRUE(self$inline)) {
        stop(DataPackageError$new('Methods iter/read are not supported for inline data')$message)
      }
      
      byteStream <- createByteStream(self$source, self$remote)
      return(byteStream) #if (stream) byteStream else new S2A(byteStream)
    },
    
    rawRead = function() {
      readable <- self$rawIter(stream = TRUE)
      stream.on <- list()
      repeat {
        
        value = tryCatch({
          readable$read()
          
        }, error = function(e){
          if (e$message == "StopIteration") {
            return(NA)
          }
          else {
            stop(e$message)
          }
        })
        
        if (!isTRUE(is.na(value))) {
          stream.on <- append(stream.on, value) 
          
        }
        else{
          break
        }
        
        
        
      }
      return(stream.on)
    },
    
    infer = function() {
      
      descriptor <- private$currentDescriptor_
      
      # Blank -> Stop
      if (isTRUE(private$sourceInspection_$blank)) return(descriptor)
      
      # Name 
      if (is.null(descriptor$name) || stringr::str_length(descriptor$name) < 1) descriptor$name <- private$sourceInspection_$name
      
      # Only for inline
      if (!isTRUE(private$inline_)) {
        # Format 
        if (isTRUE(is.null(descriptor$format)) || stringr::str_length(descriptor$format) < 1) descriptor$format <- private$sourceInspection_$format
        
        # Mediatype
        
        if (isTRUE(is.null(descriptor$mediatype)) || stringr::str_length(descriptor$mediatype) < 1) descriptor$mediatype <- stringr::str_interp('text/${descriptor$format}')
        
        # Encoding
        if (isTRUE(tolower(descriptor$encoding) == config::get("DEFAULT_RESOURCE_ENCODING", file = system.file("config/config.yaml", package = "datapackage.r")))) {
          
          encoding <- stringr::str_to_lower(readr::guess_encoding(self$source)[[1]])
          
          descriptor$encoding <- if (tolower(encoding) == 'ascii') 'utf-8' else tolower(encoding)
        }
        
        # Schema
        
        if (is.null(descriptor$schema)) {
          if (isTRUE(self$tabular)) {
            descriptor$schema <- private$getTable_()$infer() # or $infer
          }
        }
        
        # Profile
        if (isTRUE(descriptor$profile == config::get("DEFAULT_RESOURCE_PROFILE", file = system.file("config/config.yaml", package = "datapackage.r")))) {
          if (isTRUE(self$tabular)) 
            descriptor$profile <- 'tabular-data-resource'
        }
        
        # Save descriptor
        private$currentDescriptor_ <- descriptor
        private$build_() 
        
        return(descriptor)
      }
      
      # Save descriptor
      private$currentDescriptor_ <- helpers.from.list.to.json(descriptor)
      private$build_()
      
      return(helpers.from.list.to.json(descriptor))
    },
    
    commit = function(strict = NULL) {
      if (is.logical(strict)) private$strict_ <- strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_)) return(FALSE)
      private$currentDescriptor_ <- private$nextDescriptor_
      private$table_ <- NULL
      private$build_()
      return(TRUE)
    },
    
    save = function(target) {
      write.json(private$currentDescriptor_,
                 file = stringr::str_c(target, "resource.json", sep = "/"))
      save <- stringr::str_interp('Package saved at: "${target}"')
      return(save)
    }
    
  ),
  
  active = list(
    
    valid = function() {
      return(isTRUE(length(private$errors_) == 0))
    },
    
    errors = function() {
      return(private$errors_)
    },
    
    profile = function(value) {
      if (missing(value)) {
        return(private$profile_)
      }
      else {
        private$profile <- value
      }
    },
    
    descriptor = function(value) {
      if (missing(value)) {
        return(private$nextDescriptor_)
      }
      else {
        # private$currentDescriptor_ <- value
        private$nextDescriptor_ <- value
      }
      
    }, # Never use self.descriptor inside self class (!!!)
    
    name = function() {
      return(private$currentDescriptor_$name)
    },
    
    inline = function() {
      return(private$sourceInspection_$inline)
    },
    
    local = function() {
      return(private$sourceInspection_$local)
    },
    
    remote = function() {
      return(private$sourceInspection_$remote)
    },
    
    multipart = function() {
      return(private$sourceInspection_$multipart)
    },
    
    tabular = function() {
      if (isTRUE(private$currentDescriptor_$profile == 'tabular-data-resource')) return(TRUE)
      if (!isTRUE(private$strict_)) {
        if (isTRUE(private$currentDescriptor_$format %in% config::get("TABULAR_FORMATS", file = system.file("config/config.yaml", package = "datapackage.r")))) return(TRUE)
        if (isTRUE(private$sourceInspection_$tabular)) return(TRUE)
      }
      return(FALSE)
    },
    
    source = function() {
      return(private$sourceInspection_$source)
    },
    
    headers = function() {
      if (!isTRUE(self$tabular)) return(NULL) else return(private$getTable_()$headers)
    },
    
    schema = function(x) {
      if (!isTRUE(self$tabular)) return(NULL) else{
        if (!missing(x)) assign("private$getTable_()$schema",x)
      }
      return(private$getTable_()$schema)
    },
    # Deprecated
    
    table = function() {
      return(private$getTable_())
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
    relations_ = NULL,
    table_ = NULL,
    
    build_ = function() {
      
      private$currentDescriptor_ <- expandResourceDescriptor(private$currentDescriptor_)
      private$nextDescriptor_ <- private$currentDescriptor_
      # Inspect source
      
      private$sourceInspection_ <- inspectSource( private$currentDescriptor_$data,
                                                 as.character(private$currentDescriptor_$path),
                                                 private$basePath_
      )
      
      # Instantiate profile
      private$profile_ <- Profile.load(private$currentDescriptor_$profile)
      
      
      
      # Validate descriptor
      private$errors_ <- list()
      
      valid_errors <- private$profile_$validate(helpers.from.list.to.json(private$currentDescriptor_))
      
      if (!isTRUE(valid_errors$valid)) {
        
        private$errors_ <- valid_errors$errors
        
        if (isTRUE(private$strict_)) {
          
          error <- DataPackageError$new(message, valid_errors$errors)
          
          message <- stringr::str_interp("There are ${length(valid_errors$errors)} validation errors (see 'error$errors')")
          
          stop(error$message)
        }
      }
      
    },
    
    getTable_ = function() {
      if (!isTRUE(!is.null(private$table_))) {        
        # Resource -> Regular
        if (!isTRUE(self$tabular)) {
          return(NULL)
        }
        
        # Resource -> Multipart
        if (isTRUE(self$multipart_)) {
          stop(DataPackageError$new('Resource$table does not support multipart resources')$message)
        }
        # Resource -> Tabular
        
        schemaDescriptor <- private$currentDescriptor_$schema
        
        schema <- if (isTRUE(!is.null(schemaDescriptor))) tableschema.r::Schema.load(helpers.from.list.to.json(schemaDescriptor)) else NULL
        
        if (!is.null(schema)) {
          schema <- future::value(schema)
        }
        
        table_ <- tableschema.r::Table.load( self$source, schema = schema)
        private$table_ <- future::value(table_)
      }
      
      return(private$table_)
      
    },
    
    getRelations_ = function() {
      
      if (isTRUE(private$relations_ == FALSE) || is.null(private$relations_)) {
        # Prepare resources
        resources <- list()
        if (isTRUE(!is.null(private$getTable_())) && isTRUE(!is.null((private$getTable_()$schema)))) {
          
          for (fk in private$getTable_()$schema$foreignKeys) {
            #hack to implement JavaScript's array[""] <- sth - instead of "" use "$"
            actualKey <- if (stringr::str_length(fk$reference$resource) < 1) "$" else fk$reference$resource     
            resources[[actualKey]] <- if (!is.null(resources[[actualKey]])) resources[[actualKey]] else list()
            
            for (field in fk$reference$fields) {
              resources[[actualKey]] <- push(resources[[actualKey]], field)
            }
            
          }
        }
        # Fill Relations
        private$relations_ <- list()
        
        for (resource in names(resources)) {
          
          if (!is.null(resource) && is.null(private$dataPackage_)) next
          
          private$relations_[[resource]] <- if (!is.null(private$relations_[[resource]])) private$relations_[[resource]] else list()
          data <- if (!is.null(resource) && stringr::str_length(resource) > 0 && resource != "$") private$dataPackage_$getResource(resource) else self
          
          if (data$tabular) {
            private$relations_[[resource]] <- data$read(keyed = TRUE)
          }
        }
        
      }
      return(private$relations_)
    }
    
  ) )




# Internal
DIALECT_KEYS <- c(
  'delimiter',
  'doubleQuote',
  'lineTerminator',
  'quoteChar',
  'escapeChar',
  'skipInitialSpace'
)


#' Instantiate \code{Resource} class
#' 
#' @description Constructor to instantiate \code{Resource} class.
#' 
#' @usage Resource.load(descriptor = list(), basePath = NA, strict = FALSE, dataPackage = list())
#' @param descriptor Data resource descriptor as local path, url or object
#' @param basePath Base path for all relative paths
#' @param strict  Strict flag to alter validation behavior. Setting it to \code{TRUE} leads to throwing errors on any operation with invalid descriptor.
#' @param dataPackage data package list
#' @rdname Resource.load
#' @return \code{\link{Resource}} class object
#' @seealso \code{\link{Resource}}, \href{https://frictionlessdata.io/specs/data-resource/}{Data Resource Specifications}
#' @export
#' 
#' @examples
#' 
#' # Resource Load - with base descriptor
#' descriptor <- '{"name":"name","data":["data"]}'
#' resource <- Resource.load(descriptor)
#' resource$name
#' resource$descriptor
#' 
#' 
#' # Resource Load - with tabular descriptor
#' descriptor2 <- '{"name":"name","data":["data"],"profile":"tabular-data-resource"}' 
#' resource2 <- Resource.load(descriptor2)
#' resource2$name
#' resource2$descriptor
#' 
#' 
#' # Retrieve Resource Descriptor
#' descriptor3 <- '{"name": "name","data": "data"}'
#' resource3 <- Resource.load(descriptor3)
#' resource3$descriptor
#' 
#' 
#' # Expand Resource Descriptor - General Resource
#' descriptor4 <- '{"name": "name","data": "data"}'
#' resource4 <- Resource.load(descriptor4)
#' resource4$descriptor
#' 
#' # Expand Resource Descriptor - Tabular Resource Dialect
#' descriptor5 <- helpers.from.json.to.list('{
#'                                         "name": "name",
#'                                         "data": "data",
#'                                         "profile": "tabular-data-resource",
#'                                         "dialect": {"delimiter": "custom"}
#'                                         }')
#' resource5 <- Resource.load(descriptor5)
#' resource5$descriptor
#' 
#' 
#' # Resource - Inline source/sourceType
#' descriptor6 <- '{"name": "name","data": "data","path": ["path"]}'
#' resource6 <- Resource.load(descriptor6)
#' resource6$source
#' 
#' # Resource - Remote source/sourceType
#' descriptor7 <- '{"name": "name","path": ["http://example.com//table.csv"]}'
#' resource7 <- Resource.load(descriptor7)
#' resource7$source 
#' 
#' # Resource - Multipart Remote source/sourceType
#' descriptor8 <- '{
#'               "name": "name",
#'               "path": ["http://example.com/chunk1.csv", "http://example.com/chunk2.csv"]
#'               }'
#' resource8 <- Resource.load(descriptor8)
#' resource8$source 
#' 
#' 
#' # Inline Table Resource
#' descriptor9 <- '{
#'                "name": "example",
#'                "profile": "tabular-data-resource",
#'                "data": [
#'                   ["height", "age", "name"],
#'                   ["180", "18", "Tony"],
#'                   ["192", "32", "Jacob"]
#'                  ],
#'                "schema": {
#'                  "fields": [{
#'                    "name": "height",
#'                    "type": "integer"
#'                    },
#'                  {
#'                    "name": "age",
#'                    "type": "integer"
#'                  },
#'                  {
#'                    "name": "name",
#'                    "type": "string"
#'                  }
#'                  ]
#'                 }
#'                }'
#' resource9 <- Resource.load(descriptor9)
#' table <- resource9$table$read()
#' table
#' 

Resource.load <- function(descriptor = list(), basePath = NA, strict = FALSE, dataPackage = list()) {
  
  
  # Get base path
  if (anyNA(basePath)) basePath <- locateDescriptor(descriptor)
  
  # if (is.character(descriptor) && 
  #     (isSafePath(descriptor) | isRemotePath(descriptor)) ){
  #   
  #   descriptor <- helpers.from.json.to.list(descriptor)
  #   
  # } else if (is.character(descriptor) && 
  #            jsonlite::validate(descriptor)){
  #   
  #   descriptor <- helpers.from.json.to.list(descriptor)
  #   
  # }
  # Process descriptor
  descriptor <- retrieveDescriptor(descriptor)
  descriptor <- dereferenceResourceDescriptor(descriptor, basePath)
  
  return(Resource$new(descriptor, basePath, strict, dataPackage))
}

inspectSource <- function(data, path, basePath) {
  inspection <- list()
  # Normalize path
  
  if (isTRUE(!is.null(path)) && !is.list(path) && isTRUE(stringr::str_length(path) > 0)) {
    path <- list(path)
  }
  
  # Blank
  if (isTRUE(is.null(data)) && isTRUE(is.null(path) || isTRUE(stringr::str_length(path) < 1))) {
    inspection$source <- NULL
    inspection$blank <- TRUE 
    
    # Inline  
  } else if (isTRUE(!is.null(data))) {
    
    inspection$source <- data
    inspection$inline <- TRUE
    inspection$tabular <- is.list(data) && purrr::every(data, is.list)
    
    # Local/Remote
  } else if (length(path) == 1) {
    
    # Remote
    if (isTRUE(isRemotePath(path[[1]]))) {
      inspection$source <- path[[1]]
      inspection$remote <- TRUE
    } else if (isTRUE(!is.null(basePath) && isTRUE(stringr::str_length(basePath) > 0) && isRemotePath(basePath))) {
      inspection$source <- stringr::str_c(basePath, path[[1]], sep = "/")
      inspection$remote <- TRUE
      
      # Local
    } else {
      # Path is not safe
      if ( !isTRUE(isSafePath(path[[1]]) ) ) {
        stop(DataPackageError$new(stringr::str_interp('Local path "${path[[1]]}" is not safe'))$message)
      }
      # Not base path
      if (isTRUE(is.null(basePath)) || isTRUE(stringr::str_length(basePath) < 1)) {
        stop(DataPackageError$new(stringr::str_interp('Local path "${path[[1]]}" requires base path'))$message)
      }
      
      inspection$source <- stringr::str_c(basePath, path[[1]], sep = '/')
      inspection$local <- TRUE
    }
    
    # Inspect
    inspection$format <- tools::file_ext(path[[1]])[[1]]
    inspection$name <- file_basename(path[[1]])
    inspection$mediatype <- stringr::str_interp('text/${inspection$format}')
    inspection$tabular <- inspection$format %in% config::get("TABULAR_FORMATS", file = system.file("config/config.yaml", package = "datapackage.r"))
    
    
    
    # Multipart Local/Remote
  } else if (length(path) > 1) {
    inspections <- purrr::map(path, function(item) inspectSource(NULL, item, basePath))
    if (length(names(inspection)) > 0) {
      inspection <- rlist::list.merge(inspection, inspections[[1]])
    }
    else {
      inspection <- inspections[[1]]
    }
    inspection$source <- unlist(purrr::map(inspections, function(item) item$source))
    inspection$multipart <- TRUE
  }
  
  return(inspection)
  
}

# internal use
createByteStream <- function(source, remote) {
  
  stream <- list()
  
  # Remote source
  if (isTRUE(remote)) {
    
    connection <- url(source) #await axios.get(source)
    
  } else {
    connection <- file(source)
  }
  stream <- BinaryReadableConnection$new(list(source = connection))
  
  return(stream)
}
