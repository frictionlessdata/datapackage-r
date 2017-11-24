#' @title is.valid 
#'
#' @description is.valid
#' 
#' @usage is.valid(descriptor,schema)
#' 
#' 
#' @param descriptor json dictionary
#' @param schema json schema
#' 
#' @rdname is.valid
#' @import jsonvalidate
#' @export

is.valid = function(descriptor,schema)  {
  #inherits(x, "descriptor")
  if(is.null(schema)){
    
    v = jsonvalidate::json_validator(paste(readLines("https://schemas.frictionlessdata.io/data-package.json"), collapse=""))
    
    
  } else {
    #local
    v = jsonvalidate::json_validator("schema.json")
  }

  valid=v(descriptor, verbose = TRUE, greedy=TRUE,error=FALSE)
  class(valid)="logical"
  
  #.print.validator(valid)
  valid
}


# .print.validator = function (x, ...){
#   cat("This is a valid input descriptor:\n")
#   x
# }

