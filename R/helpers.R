#' Locate descriptor
#' 
#' @param descriptor descriptor
#' @rdname locateDescriptor
#' @export
#' 
locateDescriptor = function (descriptor) {
  
  # Infer from path/url
  
  if (is.character(descriptor)) {
    
    basePath = unlist(strsplit(descriptor, '/', simplify = TRUE))
    basePath = basePath[-lenght(basePath)]
    basePath = paste(basePath, collapse = "/")
  
    # Current dir by default
  } else {
    
    basePath = '.'
    
  }
  
  return (basePath)
}

#' Retrieve descriptor
#' 
#' @param descriptor descriptor
#' @rdname retrieveDescriptor
#' @export
#' 
retrieveDescriptor = function (descriptor) {
  
  if (jsonlite::validate(descriptor)) {
    
    descriptor = descriptor
    
  }
  if (is.character(descriptor)) {
    
    # Remote
    if (isRemotePath(descriptor)) {
      
      tryCatch({
        
        response = httr::GET(descriptor)
        
        descriptor = httr::content(response, as = 'text')
        
      }, 
      
      error = function(e) {
        
        message = stringr::str_interp("Can not retrieve remote descriptor '${descriptor}'")
        
        DataPackageError$new(message)
        
        stop(DataPackageError$new(
          
          stringr::str_interp("Can\'t load descriptor at '${descriptor}'"),
          
          errors
          
        ))
        
      })
      
      # Local
      
    } else {
      
      # if (config.IS_BROWSER) {
      #   message = stringr::str_interp("Local descriptor '${descriptor}' in browser is not supported")
      #   DataPackageError$new(message)
      #   
      # }
      
      tryCatch({
        
        # TODO: rebase on promisified fs.readFile (async)
        
        contents =  readr::read_file(system.file(descriptor, package = "datapackage.r"))
        
        return (jsonlite::toJSON(contents))
      }, 
      
      error = function(e) {
        
        message = stringr::str_interp("Can not retrieve local descriptor '${descriptor}'")
        
        DataPackageError$new(message)
        
      })
      
      
    }
    
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

  for (const [index, resource] of (descriptor.resources || []).entries()) {
    # TODO: May be we should use Promise.all here
    descriptor[[resources]][index] = dereferenceResourceDescriptor(
      resource, basePath, descriptor)
  }
  return (descriptor)
}

#' Dereference resource descriptor
#' @param descriptor descriptor
#' @param basePath basePath
#' @param baseDescriptor baseDescriptor
#' @rdname dereferenceResourceDescriptor
#' @export
#' 


dereferenceResourceDescriptor = function (descriptor, basePath, baseDescriptor) {

  baseDescriptor = baseDescriptor || descriptor
  PROPERTIES = list('schema', 'dialect')
  for (property in PROPERTIES) {
    value = descriptor[[property]]
    
    # URI -> No
    if (!is.character(value)) {
      continue
      
      # URI -> Pointer
    } else if (value.startsWith('#')) {
      try {
        descriptor[property] = jsonpointer.get(baseDescriptor, value.slice(1))
      } catch (error) {
        const message = stringr::str_interp('Not resolved Pointer URI "${value}" for resource[[${property}]]')
        DataPackageError$new(message)
      }
      
      # URI -> Remote
      # TODO: remote base path also will lead to remote case!
    } else if (isRemotePath(value)) {
      try {
        const response = await axios.get(value)
        descriptor[property] = response.data
      } catch (error) {
        message = stringr::str_interp('Not resolved Remote URI "${value}" for resource[[${property}]]')
        DataPackageError$new(message)
      }
      
      # URI -> Local
    } else {
      if (config::get("IS_BROWSER")) {
        message = 'Local URI dereferencing in browser is not supported'
        DataPackageError$new(message)
      }
      if (!isSafePath(value)) {
        const message = stringr::str_interp('Not safe path in Local URI "${value}" for resource[[${property}]]')
        DataPackageError$new(message)
      }
      if (!basePath) {
        message = stringr::str_interp('Local URI "${value}" requires base path for resource[[${property}]]')
        DataPackageError$new(message)
      }
      try {
        # TODO: support other that Unix OS
        const fullPath = [basePath, value].join('/')
        # TODO: rebase on promisified fs.readFile (async)
        const contents = fs.readFileSync(fullPath, 'utf-8')
        descriptor[[property]] = JSON.parse(contents)
      } catch (error) {
        message = stringr::str_interp('Not resolved Local URI "${value}" for resource[[${property}]]')
        DataPackageError$new(message)
      }
      
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
  descriptor = cloneDeep(descriptor)
  descriptor.profile = descriptor.profile || config.DEFAULT_DATA_PACKAGE_PROFILE
  for (const [index, resource] of (descriptor.resources || []).entries()) {
    descriptor.resources[index] = expandResourceDescriptor(resource)
  }
  return (descriptor)
}

#' Expand descriptor
#' @param descriptor descriptor
#' @rdname expandResourceDescriptor
#' @export
#' 
expandResourceDescriptor = function (descriptor) {
  descriptor[["profile"]] = descriptor[["profile"]] || config::get("DEFAULT_RESOURCE_PROFILE")
  descriptor[["encoding"]] = descriptor[["encoding"]] || config::get("DEFAULT_RESOURCE_ENCODING")
  if (descriptor[["profile"]] == 'tabular-data-resource') {
    
    # Schema
    schema = descriptor[["schema"]]
    if (schema != "undefined" | !isTRUE(isUndefined(schema)) ) {
      for (field in (schema[["fields"]] || list() ) ) {
        field$type = field$type || config::get("DEFAULT_FIELD_TYPE")
        field$format = field$format || config::get("DEFAULT_FIELD_FORMAT")
      }
      schema[["missingValues"]] = schema[["missingValues"]] || config::get("DEFAULT_MISSING_VALUES")
    }
    
    # Dialect
    dialect = descriptor[["dialect"]]
    if (dialect != "undefined" | isUndefined(dialect)) {
      
      for (const [key, value] of Object.entries(config::get("DEFAULT_DIALECT"))) {
        
        if (!dialect.hasOwnProperty(key)) {
          
          dialect[[key]] = value
        }
      }
    }
  }
  return (descriptor)
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


#' filepath
#' @param x filepath
#' @rdname filepath
#' @export
#' 

filepath=function(x){
  
  files=list.files(recursive = TRUE)
  
  matched_files=files[grep(x,files,fixed = FALSE,ignore.case = F)]
  
  if (length(matched_files)>1){
    
    message("There are multiple matches with the input file." ) 
    choice = menu(matched_files, title = cat("Please specify the input file:"))
    matched_files= matched_files[choice]
  } else 
  
  return(matched_files)
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

# Miscellaneous


#' is Remote Path
#' 
#' @param path path
#' 
#' @return TRUE if path is remote
#' @rdname isRemotePath
#' @export
#' 

isRemotePath = function (path) {
  
  if (!is.character(path)) message("Path should be character")
  
  startsWith("http", path)
  
}


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
  x = append(x,value)
  return (x)
}

