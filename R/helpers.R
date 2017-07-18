#' 
#' @rdname is.git
#' @export
#' 

is.git <- function(x){
  any(grepl("git", x) | grepl("hub", x) | grepl("github", x))
}

#' 
#' @rdname is.compressed
#' @export
#' 

is.compressed <- function(x){
  
 if(file.exists(x))
   grepl("^.*(.gz|.bz2|.tar|.zip)[[:space:]]*$", x)
else  message("The input file does not exist in:",getwd() )  
}


#' 
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


#' 
#' @usage get.descriptor.path(directory= ".")
#' 
#' @param directory A character vector of full path name. The default corresponds to the working directory specified by \code{\link[base]{getwd}}
#' @rdname get.descriptor.path
#' @export
#' 

get.descriptor.path=function(directory= "."){
  
  # datapackage.json(descriptor) exists?
  
  files=list.files(path = directory, recursive = FALSE)
  
  exist=grepl("datapackage.json", files, fixed = FALSE, ignore.case = FALSE)
  
  if (any(exist)==TRUE){
    
    descriptor.path=path.expand(paste0(getwd(),"/datapackage.json"))
    
  } else message("Descriptor file (datapackage.json) does not exists.")
  
}