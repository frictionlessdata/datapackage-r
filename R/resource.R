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
    initialize = function(descriptor, basePath, strict = FALSE, dataPackage = list()) {
      # Set attributes
      private$strict_ = strict
      private$errors_ = NULL
      private$profile_ = NULL
      private$nextDescriptor_ = descriptor
      private$currentDescriptor_ = descriptor
      private$dataPackage_ = dataPackage
      private$basePath_ = basePath
      
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
        relations = private$getRelations_()
      }
      
      return(private$getTable_()$iter(relations, options))
    },
    
    read = function(relations = FALSE, options = list()) {
      
      # Error for non tabular
      if (!isTRUE(self$tabular)) {
        stop(DataPackageError$new('Methods iter/read are not supported for non tabular data')$message)
      }
      
      # Get relations
      if (isTRUE(relations)) {
        relations = private$getRelations_()
      }
      return(private$getTable_()$read(relations, options))
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
      
      byteStream = createByteStream(self$source, self$remote)
      return(byteStream) #if (stream) byteStream else new S2A(byteStream)
    },
    
    rawRead = function() {
      readable = self$rawIter(stream = TRUE)
      stream.on = list()
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
          stream.on = append(stream.on, value) 
          
        }
        else{
          break
        }
        
        
        
      }
      return(stream.on)
    },
    
    infer = function() {
      
      descriptor = private$currentDescriptor_
      
      # Blank -> Stop
      if (isTRUE(is.null(private$sourceInspection_$blank))) return(descriptor)
      
      # Name 
      if (!is.null(descriptor$name)) descriptor$name = private$sourceInspection_$name
      
      # Only for inline
      if (!is.null(private$inline_)) {
        # Format 
        if (isTRUE(!is.null(descriptor$format))) descriptor$format = private$sourceInspection_$format
        
        # Mediatype
        
        if (isTRUE(!is.null(descriptor$mediatype))) descriptor$mediatype = stringr::str_interp('text/${descriptor$format}')
        
        # Encoding
        if (isTRUE(descriptor$encoding == config::get("DEFAULT_RESOURCE_ENCODING",file = "config.yaml"))) {
          iterator = self$rawIter()
          count = 0
          repeat {
            count = count + 1
            bytes =  iterators::nextElem(iterator)
            if (count == length(iterator) ) {
              break
            }
          }
          
          encoding = stringi::stri_enc_detect(bytes)[[1]]$Encoding[1] #Ruchardet::detectEncoding
          descriptor$encoding = if (encoding == 'ascii') 'utf-8' else encoding
        }
        
        # Schema
        
        if (purrr::is_empty(descriptor$schema)) {
          if (isTRUE(self$tabular)) {
            descriptor$schema = private$getTable_()$infer() # or $infer
          }
        }
        
        # Profile
        if (isTRUE(descriptor$profile == config::get("DEFAULT_RESOURCE_PROFILE",file = "config.yaml"))) {
          if (isTRUE(self$tabular)) descriptor$profile = 'tabular-data-resource'
        }
        
        # Save descriptor
        private$currentDescriptor_ = descriptor
        private$build_() 
        
        return(descriptor)
      }
      
      # Save descriptor
      private$currentDescriptor_ = helpers.from.list.to.json(descriptor)
      private$build_()
      
      return(helpers.from.list.to.json(descriptor))
    },
    
    commit = function(strict=NULL) {
      if (is.logical(strict)) private$strict_ = strict
      else if (identical(private$currentDescriptor_, private$nextDescriptor_)) return(FALSE)
      private$currentDescriptor_ = private$nextDescriptor_
      private$table_ = NULL
      private$build_()
      return(TRUE)
    },
    
    save = function(target) {
      
      write(private$currentDescriptor_, file = stringr::str_c(target,"package.txt", sep = "/"))
      save = stringr::str_interp('Package saved at: "${target}"')
      
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
       # private$currentDescriptor_ = value
        private$nextDescriptor_ = value
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
        if (isTRUE(private$currentDescriptor_$format %in% config::get("TABULAR_FORMATS", file = "config.yaml"))) return(TRUE)
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
        if (!missing(x)) private$getTable_()$schema = x
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

      private$currentDescriptor_ = expandResourceDescriptor(private$currentDescriptor_)
      private$nextDescriptor_ = private$currentDescriptor_
      # Inspect source

      private$sourceInspection_ = inspectSource( private$currentDescriptor_$data,
                                                 as.character(private$currentDescriptor_$path),
                                                 private$basePath_
      )
      
      # Instantiate profile
      private$profile_ = Profile.load(private$currentDescriptor_$profile)
      
      
      
      # Validate descriptor
      private$errors_ = list()
      
      valid_errors = private$profile_$validate(helpers.from.list.to.json(private$currentDescriptor_))

      if (!isTRUE(valid_errors$valid)) {
        
        private$errors_ = valid_errors$errors
        
        if (isTRUE(private$strict_)) {
          
          error = DataPackageError$new(message, valid_errors$errors)
          
          message = stringr::str_interp("There are ${length(valid_errors$errors)} validation errors (see 'error$errors')")
          
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
        options = list()
        schemaDescriptor = private$currentDescriptor_$schema
        
        schema = if (isTRUE(!is.null(schemaDescriptor))) tableschema.r::Schema.load(helpers.from.list.to.json(schemaDescriptor)) else NULL
        schema = schema$value()
        table_ = tableschema.r::Table.load( self$source, schema = schema, options)
        private$table_ = table_$value()
      }
      
      return(private$table_)
      
    },
    
    getRelations_ = function() {
      if (isTRUE(private$relations_ == FALSE)) {
        # Prepare resources
        resources = list()
        if (isTRUE(!is.null(private$getTable_())) && isTRUE(!is.null((private$getTable_()$schema)))) {
          
          for (fk in private$getTable_()$schema$foreignKeys) {
            
            resources[fk$reference$resource] = resources[fk$reference$resource]
            
            for (field in fk$reference$fields) {
              push(resources[fk$reference$resource], field)
            }
          }
        }
        # Fill Relations
        private$relations_ = list()
        
        for (resource in purrr::list_along(resources)) {
          
          #if (resource && !this._dataPackage) continue
          
          private$relations_[resource] = if (is.null(private$relations_[resource])) private$relations_[resource] else list()
          data = if (!is.null(resource)) private$dataPackage_$get_resource(resource) else resource
          
          if (data$tabular) {
            private$relations_[resource] = read(data, keyed = TRUE)
          }
        }
        
      }
      return(private$relations_)
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

#' Resource.load
#' @param descriptor descriptor
#' @param basePath basePath
#' @param strict strict
#' @param dataPackage dataPackage
#' @rdname Resource.load
#' @export

Resource.load = function(descriptor = list(), basePath = NA, strict = FALSE, dataPackage = list() ) {
  
  
    # Get base path
  if (anyNA(basePath)) basePath = locateDescriptor(descriptor)
  
  # if (is.character(descriptor) && 
  #     (isSafePath(descriptor) | isRemotePath(descriptor)) ){
  #   
  #   descriptor = helpers.from.json.to.list(descriptor)
  #   
  # } else if (is.character(descriptor) && 
  #            jsonlite::validate(descriptor)){
  #   
  #   descriptor = helpers.from.json.to.list(descriptor)
  #   
  # }
  # Process descriptor
  descriptor = retrieveDescriptor(descriptor)
  descriptor = dereferenceResourceDescriptor(descriptor, basePath)
  
  return(Resource$new(descriptor, basePath, strict, dataPackage))
}

inspectSource = function(data, path, basePath) {
  inspection = list()
  # Normalize path

  if (isTRUE(!is.null(path)) && !is.list(path) && isTRUE(stringr::str_length(path) > 0)) {
      path = list(path)
  }

  # Blank
  if (isTRUE(is.null(data)) && isTRUE(is.null(path) || isTRUE(stringr::str_length(path) < 1))) {
    inspection$source = NULL
    inspection$blank = TRUE 
    
    # Inline  
  } else if (isTRUE(!is.null(data))) {
    
    inspection$source = data
    inspection$inline = TRUE
    inspection$tabular = is.list(data) && purrr::every(data, is.list)
    
    # Local/Remote
  } else if (length(path) == 1) {
    
    # Remote
    if (isTRUE(isRemotePath(path[[1]]))) {
      inspection$source = path[[1]]
      inspection$remote = TRUE
    } else if (isTRUE(!is.null(basePath) && isTRUE(stringr::str_length(basePath) > 0) && isRemotePath(basePath))) {
      inspection$source = stringr::str_c(basePath, path[[1]], sep = "/")
      inspection$remote = TRUE
      
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
      
      inspection$source = stringr::str_c(basePath, path[[1]], sep = '/')
      inspection$local = TRUE
    }
    
    # Inspect
    inspection$format = tools::file_ext(path[[1]])[[1]]
    inspection$name = basename(tools::list_files_with_exts(dir = path[[1]], exts = stringr::str_interp('.${inspection$format}') ))
    inspection$mediatype = stringr::str_interp('text/${inspection$format}')
    inspection$tabular = inspection$format %in% config::get("TABULAR_FORMATS",file = "config.yml")
    
    
    
    # Multipart Local/Remote
  } else if (length(path) > 1) {
    inspections = purrr::map(path, function(item) inspectSource(NULL, item, basePath))
    if (length(names(inspection)) > 0) {
      inspection = rlist::list.merge(inspection, inspections[[1]])
    }
    else {
      inspection = inspections[[1]]
    }
    inspection$source = unlist(purrr::map(inspections, function(item) item$source))
    inspection$multipart = TRUE
  }
  
  
  return(inspection)
  
}


createByteStream = function(source, remote) {
  
  stream = list()
  
  # Remote source
  if (isTRUE(remote)) {
    
    connection = url(source) #await axios.get(source)
    
  } else {
    connection = file(source)
  }
  stream = BinaryReadableConnection$new(list(source = connection))
  
  return(stream)
}

# #' MultipartSource class
# #' 
# #' @docType class
# #' @importFrom R6 R6Class
# #' @export
# #' @include helpers.R
# #' @return Object of \code{\link{R6Class}} .
# #' @format \code{\link{R6Class}} object.
# 
# MultipartSource <- R6Class(
#   "MultipartSource",
#   public = list(
#     
#     source_ = NULL,
#     remote = NULL,
# 
#     
#     initialize = function(source,remote) {
#       self$source_ = source
#       self$remote_ = remote
#       private$rows_ = private$iter_rows()
#     },
#     iter = function(){
#       return(private$rows_)
#     },
#     read1 = function(size){
#       return(self$read(size))
#     },
#     seek = function(offset){
#       if (offset == 0) 
#         private$rows_ = private$iter_rows() else stop("offset")
#       return(private$rows_)
#     },
#     
#     read = function(){
#       
#       res = b''
#       
#       while TRUE:
#         try:
#         res += iterators::nextElem (private$rows_)
#         except StopIteration:
#           break
#         if (len(res) > size)
#           break
#         
#       return(res)
#     }
#   ),
#   active = list(
#     
#     closed = function(){
#       return(FALSE)
#     },
#     readable = function(){
#       return(TRUE)
#     },
#     seekable = function(){
#       return(TRUE)
#     },
#     writable = function(){
#       return(FALSE)
#     },
#     close = function(){
#     },
#     flush = function(){
#     }
#     
#   ),
#   private = list(
#     rows_ = NULL,
#     iter_rows = function(){}
#   )
# )
#   