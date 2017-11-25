#' infer 
#' @param pattern pattern
#' @param basePath basePath
#' @rdname infer
#' @export
#' 

# Module API

infer <- function(pattern, basePath={}) {
  
  dataPackage = Package$load({}, basePath)
  descriptor = dataPackage$infer(pattern)
  
  return (descriptor)
}