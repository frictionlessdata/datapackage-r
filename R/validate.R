#' validate descriptor
#' @param descriptor descriptor
#' @rdname validate
#' @export
#' 

# Module API


# https://github.com/frictionlessdata/datapackage-js#validate

validate = function (descriptor) {
  
  #descriptor = jsonlite::fromJSON(descriptor)
  #future::future({
    
    valid_errors= Package$public_methods$load(descriptor)
    
    names(valid_errors)= c("valid", "errors")
    
    return (valid_errors)
    
  #})

  }