#' @title profile 
#'
#' @description ...
#' 
#' @usage profile(name, jsonschema, descriptor )
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
#' @rdname profile
#' @export


profile <- function(name, jsonschema, descriptor ) {
  
  if (!is.character(name)) stop("name must be character")
  if (!is.character(jsonschema)) stop("jsonschema must be character")
  if (!is.character(validate)) stop("validate must be character")
  inherits(x, "profile")
  
  validate=is.valid(descriptor)
  
  structure(list(name ,
                 jsonschema,
                 validate ), class = "profile")
}
