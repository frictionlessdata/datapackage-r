#' @title Profile 
#'
#' @description ...
#' 
#' @usage Profile(name, jsonschema, descriptor )
#' 
#' 
#' @param name name
#' @param jsonschema json schema
#' @param descriptor descriptor
#' 
#' @details ...
#' 
#' @return ...
#' @author ...
#' @seealso ...
#' @examples ...
#' @rdname Profile
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
