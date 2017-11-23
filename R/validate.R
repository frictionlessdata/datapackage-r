#' validate descriptor
#' @param descriptor descriptor
#' @rdname validate
#' @export
#' 

# Module API


# https://github.com/frictionlessdata/datapackage-js#validate

validate = function (descriptor) {
  
  future::future({
    
    valid_errors= Package$load(descriptor)
    
    names(valid_errors)= c("valid", "errors")
    
    return (valid_errors)
    
  })

  }