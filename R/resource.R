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
    
    initialize = function (descriptor = list(), basePath, strict = FALSE, dataPackage = NULL){
      
      # # Handle deprecated resource.path.url
      # for (resource in purrr::list_along(descriptor$resources)) {
      #   if (!is.null(resource$url)) {
      #     warning(
      #       'Resource property "url: <url>" is deprecated.
      #       Please use "path: <url>" instead.')
      #     resource$path = resource$url
      #     rm(resource.url)
      #   }
      # }
      
      private$currentDescriptor_ = descriptor
      private$nextDescriptor_ = descriptor
      private$dataPackage_ = dataPackage
      private$basePath_ = basePath
      private$relations_ = NULL
      private$strict_ = strict
      private$errors_ = list()
    },
    
    load = function (descriptor = list(), basePath, strict = FALSE) {
      
      # Get base path
      if (isUndefined(basePath)) {
        basePath = locateDescriptor(descriptor)
      }
      
      # Process descriptor
      descriptor = retrieveDescriptor(descriptor)
      descriptor = dereferenceResourceDescriptor(descriptor, basePath)
      
      return (Resource$new(descriptor, basePath, strict)) #self
    },
    
    valid = function () {
      return (length(private$errors_== 0))
    },
    
    errors = function () {
      return (private$errors_)
    },
    
    profile = function () {
      return (private$profile_)
    },
    
    descriptor = function () {
      # Never use this.descriptor inside this class (!!!)
      return (private$nextDescriptor_)
    },
    
    name = function () {
      return (private$currentDescriptor_$name)
    },
    
    inline = function () {
      return (private$sourceInspection_$inline)
    },
    
    local = function () {
      return (private$sourceInspection_$local)
    },
    
    remote = function () {
      return (private$sourceInspection_$remote)
    },
    
    multipart = function () {
      return (private$sourceInspection_$multipart)
    },
    
    tabular = function () {
      tabular = private$currentDescriptor_$profile == 'tabular-data-resource'
      if (!isTRUE(private$strict_)) tabular = tabular || private$sourceInspection_$tabular
      return (tabular)
    },
    
    source = function () {
      return (private$sourceInspection_$source)
    },
    
    headers = function () {
      if (!self$tabular) return (NULL)
      return (private$getTable_()$headers)
    },
    
    schema = function () {
      if (!isTRUE(self$tabular)) return (NULL)
      return (private$getTable_()$schema)
    },
    
    iter = function ( relations=FALSE, options=list() ) {

      # Error for non tabular
      if (!isTRUE(self$tabular)) {
        stop(DataPackageError$new('Methods iter/read are not supported for non tabular data'))
      }

      # Get relations
      if (isTRUE(relations)) {
        relations = private$getRelations_()
      }

      return (iterators::iter(private$getTable_(), relations, options))
    },
    
    read = function ( relations=FALSE, options ) {
      
      # Error for non tabular
      if (!private$tabular_) {
        stop( DataPackageError$new('Methods iter/read are not supported for non tabular data') )
      }
      
      # Get relations
      if (relations) {
        relations = private$getRelations_()
      }
      
      return ( read(private$getTable_(), relations, options) )
    },
    
    checkRelations = function () {
      self$read(relations = TRUE)
      return (TRUE)
    },
    
    rawIter= function (stream = FALSE ) {
        
        # Error for inline
        if (self$inline) {
          stop( DataPackageError$new('Methods iter/read are not supported for inline data') )
        }
        
        byteStream = createByteStream(self$source, self$remote)
        return (byteStream) #if (stream) byteStream else new S2A(byteStream)
      },
    
    rawRead = function () {
      iterator = self$rawIter(stream = TRUE)
      count = 0
      repeat {
        count = count + 1
        stream.on =  iterators::nextElem(iterator)
        if (count == length(iterator) ){
          break
        }
      }
      return (stream.on)
    },
    
    infer = function() {
        descriptor = private$currentDescriptor_
        
        # Blank -> Stop
        if (private$sourceInspection_$blank) {
          return (descriptor)
        }
        
        # Name
        if (!descriptor.name) {
          descriptor.name = private$sourceInspection_$name
        }
        
        # Only for non inline
        if (!this.inline) {
          
          # Format
          if (!descriptor$format) {
            descriptor$format = private$sourceInspection$format
          }
          
          # Mediatype
          if (!descriptor$mediatype) {
            descriptor$mediatype = stringr::str_interp('text/${descriptor$format}')
          }
          
          # Encoding
          if (descriptor$encoding == config::get("DEFAULT_RESOURCE_ENCODING")) {
            
            iterator = self$rawIter()
            count = 0
            repeat {
              count = count + 1
              bytes =  iterators::nextElem(iterator)
              if (count == length(iterator) ){
                break
              }
            }
            encoding = stringi::stri_enc_detect("bytes")[[1]]$Encoding[1] #Ruchardet::detectEncoding
            descriptor$encoding = if (encoding == 'ascii') 'utf-8' else encoding
          }
          
        }
        
        # Schema
        if (purrr::is_empty(descriptor$schema)) {
          if (isTRUE(self$tabular)) {
            descriptor$schema = private$getTable_()$infer()
          }
        }
        
        # Profile
        if (descriptor$profile == config::get("DEFAULT_RESOURCE_PROFILE")) {
          if (self$tabular) {
            descriptor$profile = 'tabular-data-resource'
          }
        }
        
        # Save descriptor
        private$currentDescriptor_ = descriptor
        private$build_()
        
        return (descriptor)
      },
    
    commit = function (strict=NULL) {
      if (is.logical(strict)) private$strict_ = strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_)) return (FALSE)
      private$currentDescriptor_ = private$nextDescriptor_
      private$currentDescriptor_json = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = TRUE)
      private$build_()
      return (TRUE)
    },
    
    save = function(target) {
      contents <-
        jsonlite::toJSON(private$currentDescriptor_, pretty = TRUE)
      
      deferred_ = future::future(function() {
        base::save(contents, file = target)
      })
      return(deferred_)
    }
    
    
    
    
  ),
  
  active =list(), 
  
  private = list(
    
    # Set attributes
    currentDescriptor_ = NULL,
    nextDescriptor_ = NULL,
    dataPackage_ = NULL,
    basePath_ = NULL,
    relations_ = NULL,
    strict_ = NULL,
    errors_ = NULL,
    
    build_ = function() {
      # Process descriptor
      
      #private$currentDescriptor_json = jsonlite::toJSON(private$currentDescriptor_, auto_unbox = TRUE)
      private$currentDescriptor_ = expandPackageDescriptor(descriptor)
      private$nextDescriptor_ = private$currentDescriptor_
      
      # Inspect source
      private$sourceInspection_ = inspectSource(
        this._private$currentDescriptor_$data, private$currentDescriptor_$path, private$basePath_)
      
      # Instantiate profile
      private$profile_ = Profile$new(private$currentDescriptor_$profile)
      
      
      # Validate descriptor
      private$errors_ = list()
      
      private$currentDescriptor_json =  retrieveDescriptor(private$currentDescriptor_json)
      if(inherits(private$currentDescriptor_json, "simpleError")) {
        stop(private$currentDescriptor_json$message)
      }
      
      descriptor = jsonlite::fromJSON(private$currentDescriptor_json, simplifyVector = FALSE)
      current = private$profile_$validate(private$currentDescriptor_json)
      
      if (!current[['valid']]) {
        private$errors_ = current[['errors']]
        # message = stringr::str_interp(
        #   "There are ${length(current[['errors']])} validation errors (see 'error$errors')"
        # )
        # stop((message))
        stop(DataPackageError$new(stringr::str_interp("There are ${length(current[['errors']])} validation errors (see 'error$errors')")))
      }
      
      # Clear table
      private$table_ = NULL
    },
    
    
    getTable_ = function () {
      
      if (is.null(private$table_)) {
        
        # Resource -> Regular
        if (is.null(self$tabular)) {
          return (NULL)
        }
        
        # Resource -> Multipart
        if (self$multipart) {
          stop(DataPackageError$new('Resource$table does not support multipart resources'))
        }
        
        # Resource -> Tabular
        
        options = list()
        descriptor = private$currentDescriptor_
        options[["format"]] = purrr::compact(purrr::map(descriptor, 'format', 'csv'))
        
        if (!is.null(purrr::compact(purrr::map(descriptor, 'data')))) {
        
        options[["format"]] = 'inline'
        }
        options[["encoding"]] = descriptor[["encoding"]]
        options[["skip_rows"]] = purrr::compact(purrr::map(descriptor,"skipRows"))
        dialect = purrr::compact(purrr::map(descriptor,"dialect"))
        
        if (!is.null(dialect)) {
          
          if (is.null(
            purrr::modify_if(dialect,purrr::is_empty, function (x) x['header']<-config::get("DEFAULT_DIALECT")['header'])
            )) {
            
            fields = purrr::compact(purrr::map(descriptor, function(x) purrr::compact(purrr::map(x,"fields"))))
            options[["headers"]] = purrr::map(descriptor$resources$schema$fields,'name')
            
          }
          for (key in DIALECT_KEYS) {
            if (key %in% dialect) { 
              options[tolower(key)] = dialect[key]
            }
          }
        }
        
        private$table_ = Table$new(self$source, schema=schema, self$options)
        
      }
      return (private$table_)
    }, 
    
    getRelations_ = function () {
      #async
      
      if (!private$relations_) {
        
        # Prepare resources
        resources = list()
        if (private$getTable_() && private$getTable_()$schema) {
          
          for ( fk in private$getTable_()$schema$foreignKeys) {
            
            resources[ fk[["reference"]][["resource"]] ] = if (is.null(resources[ fk[["reference"]][["resource"]] ] )) resources[ fk[["reference"]][["resource"]] ] else list()
            
            for (field in fk[["reference"]][["fields"]]) {
              
              push(resources[fk[["reference"]][["resource"]]], field)
            }
          }
        }
        
        # Fill relations
        private$relations_ = list()
        
        for ( resource in purrr::list_along(resources) ) {
          
          #if (resource && !this._dataPackage) continue
          
          private$relations_[resource] = if (is.null(private$relations_[resource])) private$relations_[resource] else list()
          data = if (!is.null(resource)) private$dataPackage_$get_resource(resource) else resource
          
          if (data.tabular) {
            private$relations_[resource] = read(data, keyed = TRUE)
          }
        }
        
      }
      return (private$relations_)
    },
    
    # Deprecated
    
    table = function () {
      return (private$getTable_())
    }
    

  ) )





# Internal
DIALECT_KEYS = c(
  'delimiter',
  'doubleQuote',
  'lineTerminator',
  'quoteChar',
  'escapeChar',
  'skipInitialSpace'
)

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

createByteStream = function (source, remote) {
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