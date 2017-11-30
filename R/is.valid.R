#' @title is.valid 
#'
#' @description is.valid
#' 
#' @usage is.valid(descriptor,schema=NULL)
#' 
#' 
#' @param descriptor json dictionary
#' @param schema json schema
#' 
#' @rdname is.valid
#' @import jsonvalidate
#' @export

is.valid = function(descriptor,schema=NULL)  {
  #inherits(x, "descriptor")
  if(is.null(schema)){
    
    v = jsonvalidate::json_validator(paste(readLines("https://schemas.frictionlessdata.io/data-package.json"), collapse=""))
    
    
  } else {
    #local
    v = jsonvalidate::json_validator(schema)
  }

  validate=v(descriptor, verbose = TRUE, greedy=TRUE,error=FALSE)
  class(validate)="logical"
  
  #.print.validator(valid)
  validation=list(valid=as.vector(validate), errors=attr(validate,"errors"))
  return(validation)
}


# .print.validator = function (x, ...){
#   cat("This is a valid input descriptor:\n")
#   x
# }

