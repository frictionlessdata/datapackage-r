#' @title Validation 
#'
#' @description ...
#' 
#' @usage validator(descriptor,schema)
#' 
#' 
#' @param descriptor json dictionary
#' @param schema json schema
#' 
#' @details ...
#' 
#' @return ...
#' @author ...
#' @seealso ...
#' @examples ...
#' @rdname validator
#' @import jsonvalidate
#' @export

is.valid = function(descriptor,schema)  {
  
  if(is.null(scheme)){
    
    v = jsonvalidate::json_validator(paste(readLines("https://schemas.frictionlessdata.io/data-package.json"), collapse=""))
    
    
  } else {
    #local
    v = jsonvalidate::json_validator("schema.json")
  }

  valid=v(json,verbose = T, greedy=TRUE,error=F)
  class(valid)="logical"
  
  #.print.validator(valid)
  valid
}


.print.validator = function (x, ...){
  cat("This is a valid input descriptor:\n")
  x
}

