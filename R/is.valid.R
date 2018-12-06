#' @title Is valid
#' @description Validate a descriptor over a schema
#' @param descriptor descriptor, one of:
#' \itemize{
#' \item string with the local CSV file (path)
#' \item string with the remote CSV file (url)
#' \item list object
#' }
#' @param schema Contents of the json schema, or a filename containing a schema
#' @return \code{TRUE} if valid
#' @rdname is.valid
#' @export
#' 

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
  validation=list(valid=validate, errors=attr(validate,"errors"))
  return(validation)
}
