#' @title datapackage 
#'
#' @description ...
#' 
#' @usage datapackage(descriptor, base_path, strict=True)
#' 
#' 
#' @param descriptor name
#' @param base_path json schema
#' @param strict descriptor
#' 
#' @details ...
#' 
#' @return ...
#' @author ...
#' @seealso ...
#' @examples ...
#' @rdname datapackage
#' @export


datapackage <- function(descriptor, base_path, strict=TRUE) {
  
  if (!is.character(descriptor)) stop("descriptor must be character")
  if (!is.logical(base_path)) stop("base_path must be logical (TRUE or FALSE)")
  if (!is.logical(strict)) stop("strict must be logical (TRUE or FALSE)")

  
  
  structure(list(valid ,
                 errors,
                 profile,
                 descriptor,
                 resources,
                 resource_names#,
                # add_resource(descriptor),
                # remove_resource(name),
                # get_resource(name),
                # save(target),
                # update() 
                 ), class = "datapackage")
}

