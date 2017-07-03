#' @title resource 
#'
#' @description ...
#' 
#' @usage resource(descriptor, base_path=None)
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


resource <- function(descriptor, base_path ) {
  
  if (!is.character(name)) stop("name must be character")
  if (!is.logical(tabular)) stop("tabular must be logical (TRUE or FALSE)")
  if (!is.character(descriptor)) stop("descriptor must be character")
  if (!is.character(source_type)) stop("source_type must be character")
  if (!is.character(source)) stop("source must be character")
  if (!is.character(table)) stop("table must be character")
  
  
  structure(list(name ,
                 tabular,
                 descriptor,
                 source_type,
                 source,
                 table), class = "Profile")
}
