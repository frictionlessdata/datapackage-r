#' Locate descriptor
#' 
#' @param descriptor descriptor
#' @rdname locateDescriptor
#' @export
#' 
locateDescriptor = function (descriptor) {
  #if (inherits(descriptor, "connection")) {
    # Infer from path/url
    
    if (is.character(unlist(jsonlite::fromJSON(descriptor,flatten = T)))) {
      
      basePath = unlist(strsplit(unlist(jsonlite::fromJSON(descriptor,flatten = T)), '/')) # OR stringr::str_split , simplify = TRUE
      basePath = basename(basePath)
      basePath = if (length(basePath)!=0) utils::tail(basePath, n=1) else getwd() #basePath[-length(basePath)] 
      basePath = paste("inst/data",basePath, sep = "/")
      
      # Current dir by default
    } else {
      
      basePath = stringr::str_c(getwd(),"inst/data", sep = "/")
      
    } 
  #} else basePath = stringr::str_c(getwd(),"inst/data", sep = "/")
  return (basePath)
}

#' Retrieve descriptor
#' 
#' @param descriptor descriptor
#' @rdname retrieveDescriptor
#' @export
#' 
retrieveDescriptor = function (descriptor) {
  
  if (isTRUE(jsonlite::validate(descriptor))) {
    
    descriptor = descriptor
    
  }
  if (is.character(descriptor)) {
    
    # Remote
    if (isTRUE(tableschema.r::is.uri(descriptor))) {
      
      tryCatch({
        
        response = httr::GET(descriptor)
        
        descriptor = httr::content(response, as = 'text')
        
      }, 
      
      error = function(e) {
        
        message = stringr::str_interp('Can not retrieve remote descriptor "${descriptor}"')
        
        DataPackageError$new(message)
        
    })
      
      # Local
      
    } else {
      
      descriptor = tryCatch({
        data = descriptor
        #data = readLines(descriptor,encoding="UTF-8", warn = FALSE)
        valid = jsonlite::validate(data)
        
        if (valid == FALSE) {
          DataPackageError$new(
            stringr::str_interp("Can\'t load descriptor at '${descriptor}'"))
        }
        else{
          return(data)
        }
        
      },
      error = function(cond) {
        # Choose a return value in case of error
        DataPackageError$new(
          stringr::str_interp("Can\'t load descriptor at '${descriptor}': ${cond$message}"))
        
      },
      warning = function(cond) {
        # Choose a return value in case of error
        DataPackageError$new(
          stringr::str_interp("Can\'t load descriptor at '${descriptor}': ${cond$message}"))
        
      })
      
      
    }
    # contents =  jsonlite::toJSON(contents)
    # contents
    
  }
  
  DataPackageError$new('Descriptor must be String or Object')
}

#' Dereference descriptor
#' @param descriptor descriptor
#' @param basePath basePath
#' @rdname dereferencePackageDescriptor
#' @export
#' 

dereferencePackageDescriptor = function (descriptor, basePath) {
  # if (!is.character(descriptor)) descriptor = jsonlite::toJSON(descriptor)
  # descriptor2 = jsonlite::fromJSON(descriptor)
  # #descriptor[["resources"]] = purrr::map(descriptor[["resources"]], dereferenceResourceDescriptor, baseDescriptor = descriptor[["resources"]][[2]], basePath = basePath, descriptor = descriptor)
  # 
  # 
  # for (resource in descriptor2[["resources"]]){
  #   dereferenceResourceDescriptor(descriptor =resource, basePath = basePath, descriptor)}
  # # for (const [index, resource] of (descriptor.resources || []).entries()) {
  # #   # TODO: May be we should use Promise.all here
  # #   descriptor.resources[index] = await dereferenceResourceDescriptor(
  # #     resource, basePath, descriptor)
  # # }
  
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
  #  #if (is.character(descriptor)) descriptor = jsonlite::fromJSON(descriptor)
  # if (isUndefined(baseDescriptor)) baseDescriptor = descriptor
  # PROPERTIES = list('dialect','schema')
  # 
  # for (property in PROPERTIES) {
  #   
  #   value = purrr::compact(purrr::map(jsonlite::fromJSON(descriptor),property))
  #   value = jsonlite::toJSON(value)
  #   # URI -> No
  #   if (!is.character(value)) {
  #     # continue
  #     
  #     # URI -> Pointer
  #   } else if (is.character(value)) if(startsWith(value,'#') ) {
  #     tryCatch({
  #       descriptor[[property]] = purrr::compact(baseDescriptor, value[[2]] )
  #     },
  #     error = function(e) {
  #       message = stringr::str_interp('Not resolved Pointer URI "${value}" for resource[[${property}]]')
  #       DataPackageError$new(message)
  #     })
  #     
  #     # URI -> Remote
  #     # TODO: remote base path also will lead to remote case!
  #   } else if (isRemotePath(value)) {
  #     tryCatch({
  #       response = httr::GET(value)
  #       descriptor[[property]] = httr::content(response, as = 'text')
  #     },
  #     error = function(e) {
  #       message = stringr::str_interp('Not resolved Remote URI "${value}" for resource[[${property}]]')
  #       DataPackageError$new(message)
  #     })
  #     
  #     # URI -> Local
  #   } else {
  #     # if (config::get("IS_BROWSER")) {
  #     #   message = 'Local URI dereferencing in browser is not supported'
  #     #   DataPackageError$new(message)
  #     # }
  #     if (!isSafePath(value)) {
  #       message = stringr::str_interp('Not safe path in Local URI "${value}" for resource[[${property}]]')
  #       DataPackageError$new(message)
  #     }
  #     if (isUndefined(basePath)) {
  #       message = stringr::str_interp('Local URI "${value}" requires base path for resource[[${property}]]')
  #       DataPackageError$new(message)
  #     }
  #     tryCatch({
  #       # TODO: support other that Unix OS
  #       fullPath = paste(basePath, value, sep = '/')
  #       # TODO: rebase on promisified fs.readFile (async)
  #       contents = readLines(fullPath, 'utf-8')
  #       descriptor[[property]] = jsonlite::fromJSON(contents)
  #     }, 
  #     error = function(e) {
  #       message = stringr::str_interp('Not resolved Local URI "${value}" for resource[[${property}]]')
  #       DataPackageError$new(message)
  #     })
  #     
  #   }
  # }
  
  return (descriptor)
}



#' Expand descriptor
#' @param descriptor descriptor
#' @rdname expandPackageDescriptor
#' @export
#' 
expandPackageDescriptor = function (descriptor) {
  descriptor = jsonlite::fromJSON(descriptor)
  descriptor[["profile"]] = if (is.null(descriptor[["profile"]]) ) config::get("DEFAULT_DATA_PACKAGE_PROFILE") else descriptor[["profile"]]
  
  # descriptor[["resources"]] = purrr::map(descriptor[["resources"]], expandResourceDescriptor)
  for (index in ( if (isUndefined(descriptor[["resources"]])) descriptor[["resources"]]=list() else descriptor[["resources"]]) ) {
    descriptor[["resources"]][index] = expandResourceDescriptor(descriptor[["resources"]][index])
  }
  descriptor = jsonlite::toJSON(descriptor)
  return (descriptor)
}

#' Expand descriptor
#' @param descriptor descriptor
#' @rdname expandResourceDescriptor
#' @export
#' 
expandResourceDescriptor = function (descriptor) {
  
  descriptor = jsonlite::fromJSON(descriptor)
  
  descriptor[["profile"]] = if (isUndefined(descriptor[["profile"]])) config::get("DEFAULT_RESOURCE_PROFILE") else descriptor[["profile"]]
  descriptor[["encoding"]] = if (isUndefined(descriptor[["encoding"]])) config::get("DEFAULT_RESOURCE_ENCODING") else descriptor[["encoding"]]
  if (descriptor[["profile"]] == 'tabular-data-resource') {
    
    # Schema
    schema = descriptor[["schema"]]
    if (schema != "undefined" | !isTRUE(isUndefined(schema)) ) {
      for (field in ( if (isUndefined(schema[["fields"]])) list() else schema[["fields"]]  ) ) {
        field$type = if (isUndefined(field$type)) config::get("DEFAULT_FIELD_TYPE") else field$type
        field$format = if (isUndefined(field$format)) config::get("DEFAULT_FIELD_FORMAT") else field$format
      }
      schema[["missingValues"]] = if (isUndefined(schema[["missingValues"]])) config::get("DEFAULT_MISSING_VALUES") else schema[["missingValues"]]
    }
    
    # Dialect
    dialect = descriptor[["dialect"]]
    
    if (isUndefined(dialect) | dialect != "undefined") {
      dialect = config::get("DEFAULT_DIALECT")
      # for (c(key, value) in config::get("DEFAULT_DIALECT")) {
      #   
      #   if (!dialect.hasOwnProperty(key)) {
      #     
      #     dialect[[key]] = value
      #   }
      # }
    }
  }
  descriptor = jsonlite::toJSON(descriptor)
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
  
  #if (!is.character(path)) FALSE else 
  startsWith("http", unlist(strsplit(path,":")))[1] #startsWith("http", path) #message("Path should be character")
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
  x = purrr::prepend(x,value) #append
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


#' Get descriptor path
#' 
#' @description Find descriptor path in directory
#' 
#' @usage get.descriptor.path(directory= ".")
#' 
#' @param directory A character vector of full path name. The default corresponds to the working directory specified by \code{\link[base]{getwd}}
#' 
#' @rdname get.descriptor.path
#' 
#' @export
#' 

get.descriptor.path = function(directory= "."){
  
  # datapackage.json(descriptor) exists?
  
  files=list.files(path = directory, recursive = FALSE)
  
  exist=grepl("datapackage.json", files, fixed = FALSE, ignore.case = FALSE)
  
  if (any(exist)==TRUE){
    
    descriptor.path=path.expand(paste0(getwd(),"/datapackage.json"))
    
    descriptor.path
    
  } else message("Descriptor file (datapackage.json) does not exists.")
  
}