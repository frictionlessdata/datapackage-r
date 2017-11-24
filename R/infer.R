#' infer 
#' @param source source
#' @param options options
#' @rdname infer
#' @export
#' 

# Module API

infer <- function(source, options=list() ){
  
  # https://github.com/frictionlessdata/tableschema-js#infer
  
  table = Table$load(source, options)
  
  descriptor = table$infer(limit = options[["limit"]])
  
  return (descriptor)
}