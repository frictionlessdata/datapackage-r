#' Infer a data package descriptor
#' @description A standalone function to infer a data package descriptor.
#' @param pattern string with file pattern
#' @param basePath base path for all relative paths
#' @rdname infer
#' @export
#' @return Data Package Descriptor
#' 
#' @examples
#' \dontrun{
#' descriptor = infer("csv",basePath = '.')
#' descriptor
#' }
#' 

infer <- function(pattern = NULL, basePath = NULL) {
  
  dataPackage = Package.load("{}", basePath)
  descriptor = dataPackage$infer(pattern)
  
  return(descriptor)
}
