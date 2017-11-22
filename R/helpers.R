# Locate descriptor

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

# Retrieve descriptor

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

