#' @title Validation 
#'
#' @description ...
#' 
#' @usage Profile(name, jsonschema, descriptor )
#' 
#' 
#' @param name json dictionary
#' @param jsonschema json schema
#' @param descriptor json schema
#' 
#' @details ...
#' 
#' @return ...
#' @author ...
#' @seealso ...
#' @examples ...
#' @rdname Profile
#' @import jsonvalidate
#' @export


Profile <- function(name, jsonschema, descriptor ) {
  
  if (!is.character(name)) stop("name must be character")
  if (!is.character(jsonschema)) stop("jsonschema must be character")
  if (!is.character(validate)) stop("validate must be character")
  
  
  validate=is.valid(descriptor)
  
  structure(list(name ,
                 jsonschema,
                 validate ), class = "Profile")
}

