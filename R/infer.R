#' infer 
#' @param pattern pattern
#' @param basePath basePath
#' @rdname infer
#' @export
#' 

# Module API

infer <- function(pattern = NULL, basePath = NULL) {
  
  dataPackage = Package.load(list(), basePath=NULL)
  descriptor = dataPackage$infer(pattern)
  
  return (descriptor)
}