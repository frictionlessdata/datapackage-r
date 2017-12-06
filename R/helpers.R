#' Locate descriptor
#' 
#' @param descriptor descriptor
#' @rdname locateDescriptor
#' @export
#' 
locateDescriptor = function (descriptor) {

    # Infer from path/url
    if (is.character(descriptor)){
      
    # if ( file.exists(normalizePath(stringr::str_c('inst/data',basename(descriptor),sep = '/'),winslash = "\\",mustWork=FALSE)) ) {
      # dir.exists(tools::file_path_as_absolute(normalizePath(descriptor,winslash = "\\",mustWork=FALSE))) | 
      #   file.exists(tools::file_path_as_absolute(normalizePath(descriptor,winslash = "\\",mustWork=FALSE))) |
      if (isRemotePath(descriptor)) {
        # basePath = dirname(tools::file_path_as_absolute(normalizePath(stringr::str_c('inst/data',basename(descriptor),sep = '/'),winslash = "\\",mustWork=TRUE)))#dirname(descriptor)
        basePath = dirname(descriptor)
      } else if (isTRUE(grepl('inst',descriptor))) {
        basePath = stringr::str_c(dirname(descriptor),sep = '/') 
        
      } else if (!isTRUE(grepl('inst',descriptor))) {
        basePath = stringr::str_c('inst', dirname(descriptor),sep = '/') 
      }
      #basePath = dirname(tools::file_path_as_absolute(normalizePath(stringr::str_c('inst/data',basename(descriptor),sep = '/'),winslash = "\\",mustWork=TRUE))
      #else basePath = stringr::str_c('inst', dirname(descriptor),sep = '/')
      
    } else basePath = ""
    
  return (basePath)
}

#' Retrieve descriptor
#' 
#' @param descriptor descriptor
#' @rdname retrieveDescriptor
#' @export
#' 
retrieveDescriptor = function (descriptor) {
  
  if (is.json(descriptor)) {
    descriptor = jsonlite::fromJSON(descriptor)
    return (descriptor)
    }
  if (is.list(descriptor)) {return (descriptor)}
  
  if (is.character(descriptor)) {
    
    # Remote
    if(isRemotePath(descriptor)){
      tryCatch({
        response = httr::GET(descriptor)
        descriptor = httr::content(response, as = 'text')
        descriptor = jsonlite::fromJSON(descriptor)
        return(descriptor)
      }, 
      
      error = function(e) {
        
        message = stringr::str_interp('Can not retrieve remote descriptor "${descriptor}"')
        
        DataPackageError$new(message)$message
        
      })
    } else if( is.local.descriptor.path(descriptor) ) {
      tryCatch({
        
        if ('inst/data'== dirname(descriptor) | dirname(descriptor) == "." | dirname(descriptor)==""){
        descriptor = jsonlite::fromJSON(readLines(normalizePath(stringr::str_c('inst/data',basename(descriptor),sep = '/'),winslash = "\\",mustWork=FALSE),warn = FALSE))
        return(descriptor)
        
        } else if ( grepl('inst', dirname(descriptor)) ){
          descriptor = jsonlite::fromJSON(readLines(normalizePath(stringr::str_c(dirname(descriptor), basename(descriptor),sep = '/'),winslash = "\\",mustWork=FALSE),warn = FALSE))
          return(descriptor)
        } else {
          descriptor = jsonlite::fromJSON(readLines(normalizePath(stringr::str_c('inst/data',basename(descriptor),sep = '/'),winslash = "\\",mustWork=FALSE),warn = FALSE))
          return(descriptor)
        }
        
      }, 
      
      error = function(e) {
        
        message = stringr::str_interp('Can not load local descriptor "${descriptor}"')
        
        DataPackageError$new(message)$message
        
      })
    } else  stop(DataPackageError$new('Can not load local descriptor "${descriptor}"')$message)
    
    
  } else  stop(DataPackageError$new('Descriptor must be String, JSON or List')$message)
  
}

#' Dereference descriptor
#' @param descriptor descriptor
#' @param basePath basePath
#' @rdname dereferencePackageDescriptor
#' @export
#'

dereferencePackageDescriptor = function (descriptor, basePath) {
  
  if (is.json(descriptor) ) descriptor = jsonlite::fromJSON(descriptor)
  
  for (index in ( if (is.empty(descriptor$resources)) length(list()) else names(descriptor$resources)) ) {
    descriptor$resources[index] = dereferenceResourceDescriptor(descriptor$resources[index], basePath, descriptor)
  }
  #names(descriptor$resources)
  #descriptor = jsonlite::toJSON(descriptor)

  return (descriptor)
}

#' Dereference resource descriptor
#' @param descriptor descriptor
#' @param basePath basePath
#' @param baseDescriptor baseDescriptor
#' @rdname dereferenceResourceDescriptor
#' @export
#'


dereferenceResourceDescriptor = function (descriptor, basePath, baseDescriptor=NULL) {
  #conditions
  if (is.json(descriptor)) descriptor = jsonlite::fromJSON(descriptor)
  if (is.json(baseDescriptor)) descriptor = jsonlite::fromJSON(descriptor)
  
  if (is.null(baseDescriptor)| is.empty(baseDescriptor) | !exists("baseDescriptor")) baseDescriptor = descriptor
  
  #set list properties
  PROPERTIES = list('dialect','schema')

  
  for (property in PROPERTIES) {

    value = descriptor[[property]]
    
    # URI -> No
    if (!is.character(value)) {
      # continue

      # URI -> Pointer
    } else if(startsWith(unlist(value),'#')) {
 
        descriptor[[property]] = descriptor.pointer(value, descriptor)
        
        if (is.null(descriptor[[property]])) {
          message = DataPackageError$new(stringr::str_interp('Not resolved Pointer URI "${value}" for resource[[${property}]]'))
          stop(message$message)
        }
        
      # URI -> Remote
      # TODO: remote base path also will lead to remote case!
    } else if (isRemotePath(unlist(value))) {
      tryCatch({
        # response = httr::GET(value)
        descriptor[[property]] = jsonlite::fromJSON(value)#httr::content(response, as = 'text')
      },
      error = function(e) {
        message = DataPackageError$new(stringr::str_interp('Not resolved Remote URI "${value}" for resource[[${property}]]'))
        stop(message$message)
      })

      # URI -> Local
    } else {

      if (!isTRUE(isSafePath(unlist(value)))) {
        message = DataPackageError$new(stringr::str_interp('Not safe path in Local URI "${value}" for resource[[${property}]]'))
        stop(message$message)
      }
      
      if (isTRUE( is.null(basePath) | basePath =="")) {
        message = DataPackageError$new(stringr::str_interp('Local URI "${value}" requires base path for resource[[${property}]]'))
        stop(message$message)
      }
      
      tryCatch({
        # TODO: support other that Unix OS
        fullPath = stringr::str_c(basePath, value, sep = '/')
        # TODO: rebase on promisified fs.readFile (async)
        descriptor[[property]] = jsonlite::fromJSON(fullPath)
        # contents = readLines(fullPath, 'utf-8')
        # descriptor[[property]] = jsonlite::fromJSON(contents)
      },
      error = function(e) {
        message = DataPackageError$new(stringr::str_interp('Not resolved Local URI "${value}" for resource[[${property}]]'))
        stop(message$message)
      })

    }
  }

  return (descriptor)
}



#' Expand descriptor
#' @param descriptor descriptor
#' @rdname expandPackageDescriptor
#' @export
#' 
expandPackageDescriptor = function (descriptor) {
  if (isTRUE(descriptor=="{}" | descriptor == "[]")) descriptor = list()
  if (is.json(descriptor) ) descriptor = jsonlite::fromJSON(descriptor)
  descriptor$profile = if (is.empty(descriptor$profile) ) config::get("DEFAULT_DATA_PACKAGE_PROFILE",file = "config.yaml") else descriptor$profile
  
  # descriptor[["resources"]] = purrr::map(descriptor[["resources"]], expandResourceDescriptor)
  #for (index in ( if (is.empty(descriptor$resources)) length(list()) else length(descriptor$resources)) ) {
  descriptor["resources"] = purrr::map(descriptor["resources"],expandResourceDescriptor)
  #descriptor$resources[[index]] = expandResourceDescriptor(descriptor$resources[index])
  #}
  #names(descriptor$resources)
  #descriptor = jsonlite::toJSON(descriptor)
  return (descriptor)
}

#' Expand descriptor
#' @param descriptor descriptor
#' @rdname expandResourceDescriptor
#' @export
#' 
expandResourceDescriptor = function (descriptor) {
  
  if (is.json(descriptor)) descriptor = jsonlite::fromJSON(descriptor)
  
  # set default for profile and encoding
  descriptor$profile = if (isTRUE(is.null(descriptor$profile))) config::get("DEFAULT_RESOURCE_PROFILE",file = "config.yaml") else descriptor$profile
  descriptor$encoding = if (isTRUE(is.null(descriptor$encoding))) config::get("DEFAULT_RESOURCE_ENCODING",file = "config.yaml") else descriptor$encoding
  
  # tabular-data-resource
  if (isTRUE(descriptor$profile == 'tabular-data-resource')) {
    
    # Schema
    #schema = descriptor$schema
    if ( isTRUE(!is.empty(descriptor$schema)) | isTRUE(!is.null(descriptor$schema)) | isTRUE(!descriptor$schema == "undefined") ) {
      fields = list()
      #for (field in ( if (is.empty(descriptor$schema$fields)) list() else descriptor$schema$fields) ) {
      fields$type = if (is.empty(descriptor$schema$fields$type)) config::get("DEFAULT_FIELD_TYPE",file = "config.yaml") else descriptor$schema$fields$type
      fields$format = if (is.empty(descriptor$schema$fields$format)) config::get("DEFAULT_FIELD_FORMAT",file = "config.yaml") else descriptor$schema$fields$format
      #}
      
      descriptor$schema$fields = as.data.frame(append(descriptor$schema$fields,fields),stringsAsFactors = FALSE)
      descriptor$schema$missingValues = if (is.empty(descriptor$schema$missingValues)) config::get("DEFAULT_MISSING_VALUES",file = "config.yaml") else descriptor$schema$missingValues
      
    }
    
    # Dialect
    #dialect = descriptor$dialect
    
    if (isTRUE(!is.null(descriptor$dialect)) | isTRUE(!descriptor$dialect == "undefined") ) {
      #descriptor$dialect = config::get("DEFAULT_DIALECT",file = "config.yaml")
      # descriptor$dialect$lineTerminator="\r\n"
      # descriptor$dialect$quoteChar="\""
      # descriptor$dialect$escapeChar="\\"
      
      for (key in which(!names(config::get("DEFAULT_DIALECT",file = "config.yaml")) %in% names(descriptor$dialect))) {

       # if (!names(config::get("DEFAULT_DIALECT",file = "config.yaml"))[key] %in% names(descriptor$dialect)) {

          descriptor$dialect[[paste(names(config::get("DEFAULT_DIALECT",file = "config.yaml"))[key]) ]] = config::get("DEFAULT_DIALECT",file = "config.yaml")[key]
      }
      descriptor$dialect=lapply(descriptor$dialect, unlist, use.names=FALSE)
      #}
    }
  }
  
  return (descriptor)
}


# Miscellaneous


#' Is remote path
#' 
#' @param path path
#' 
#' @return TRUE if path is remote
#' @rdname isRemotePath
#' @export
#' 

isRemotePath = function (path) {
  if (!is.character(path)) path = as.character(path)
  #if (!is.character(path)) FALSE else 
  isTRUE( startsWith("http", unlist(strsplit(path,":")))[1] |
            startsWith("https", unlist(strsplit(path,":")))[1] )
}

#' Is safe path
#' 
#' @param path path
#' 
#' @return TRUE if path is safe
#' @rdname isSafePath
#' @export
#' 

isSafePath = function (path) {
  
  if (!isTRUE(is.character(path))) FALSE else {
  containsWindowsVar = function(path) if (isTRUE(grepl("%.+%", path))) TRUE else FALSE
  containsPosixVar = function(path) if (isTRUE(grepl("\\$.+", path))) TRUE else FALSE
  
  # un Safety checks
  unsafenessConditions = list(
    
    R.utils::isAbsolutePath(path),
    grepl("\\|/", path),
    grepl('\\.\\.',path),
    #path.includes(`..${pathModule.sep}`),
    startsWith(path, '~'),
    containsWindowsVar(path),
    containsPosixVar(path)
  )
  response = any(unlist(unsafenessConditions))
  return (!response)
  }
}


## Extra


#' Determine if a variable is undefined or NULL
#' 
#' @param x variable
#' 
#' @return TRUE if variable is undefined
#' @rdname isUndefined
#' @export
#' 
isUndefined = function(x){
  
  if (any(isTRUE( !exists(deparse(substitute(x))) || is.null(x)  ))) TRUE else FALSE
  
}

#' Push elements in a list or vector
#' 
#' @param x list or vector
#' @param value value to push in x
#' 
#' @rdname push
#' @export
#' 
push = function(x, value){
  x = append(x,value) #append rlist::list.
  return (x)
}


#' is git
#' @param x url
#' @rdname is.git
#' @return TRUE if url is git
#' @export
#' 

is.git <- function(x){
  any(grepl("git", x) | grepl("hub", x) | grepl("github", x))
}

#' is compressed
#' @param x file
#' @rdname is.compressed
#' @return TRUE if file is compressed
#' @export
#' 

is.compressed <- function(x){
  
  if(file.exists(x))
    grepl("^.*(.gz|.bz2|.tar|.zip)[[:space:]]*$", x)
  else  message("The input file does not exist in:",getwd() )  
}

#' is json
#' @description  Test if an object is json
#' @param object object to test if json
#' @rdname is.json
#' @return TRUE if object is json
#' @export
#' 
is.json = function (object){
  if (class(object) == "json") return (TRUE) else return(FALSE)
}

#' findFiles
#' @param pattern pattern
#' @param path path
#' @rdname findFiles
#' @export
#' 

findFiles = function(pattern,path=getwd()){
  files=list.files(recursive = TRUE)
  #files=filepath(path)#, recursive = TRUE)
  matched_files=files[grep(path,files,fixed = FALSE,ignore.case = FALSE)]
  matched_files=matched_files[grep(pattern, matched_files, fixed = FALSE, ignore.case = FALSE)]
  

    return(matched_files)
}


#' is empty list
#' @param list list
#' @rdname is.empty
#' @return TRUE if list is empty (currently at depth 2)
#' @export
#' 

is.empty = function(list){
  empty = purrr::every( list, function(x){purrr::is_empty(x)} )
  return(empty)
}


#' Is Local Descriptor Path
#' 
#' @param descriptor descriptor
#' @param directory A character vector of full path name. The default corresponds to the working directory specified by \code{\link[base]{getwd}}
#' 
#' @rdname is.local.descriptor.path
#' 
#' @export
#' 

is.local.descriptor.path = function(descriptor, directory= "."){

  #descriptor.path=path.expand(paste0(basePath,"/datapackage.json"))
  
  isTRUE(any( descriptor %in% list.files(path = directory, recursive = TRUE) | 
                grep(descriptor , list.files(path = directory, recursive = TRUE)) | 
                file.exists(normalizePath(stringr::str_c('inst/data',basename(descriptor),sep = '/'),winslash = "\\",mustWork=FALSE)) ))
  
  ## Future to test in other folders and include
  # if grep(basename(descriptor) , list.files(path = directory, recursive = TRUE))
}

#' descriptor pointer
#' @param value value
#' @param descriptor descriptor
#' @rdname descriptor.pointer
#' @export
#'
descriptor.pointer <- function(value,descriptor) {
  
  if (startsWith(as.character(value),"#")){  
    pointer = paste(deparse(substitute(descriptor)),paste(unlist(stringr::str_split(as.character(value),"/"))[-1],collapse="$"),sep="$")
    value =  eval(parse(text=pointer))
}
return(value)
}
# #' Catch Error
# #' @param expr expr 
# #' @rdname catchError
# #' @export
# #' 

# catchError <- function(expr) {
#   
#   warn <- err <- NULL
#   
#   value <- withCallingHandlers(
#     
#     tryCatch( expr,
#               
#               error=function(e) {
#                 err <<- e
#                 NULL
#              }), 
#     warning=function(w) {
#       warn <<- w
#       invokeRestart("muffleWarning")
#     })
#   
#   list(value = value, warnings = warn, errors = err)
# }