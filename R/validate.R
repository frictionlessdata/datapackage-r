#' validate descriptor
#' @description A standalone function to validate a data package descriptor.
#' @param descriptor data package descriptor, one of:
#' \itemize{
#' \item string with the local CSV file (path)
#' \item string with the remote CSV file (url)
#' \item list object
#' }
#' @return A list with:
#' \itemize{
#'  \item{\code{valid }}{ \code{TRUE} if valid}  
#'  \item{\code{errors }}{a list with errors if valid \code{FALSE}}
#'  }
#'  
#' @rdname validate
#' @export
#' @seealso \href{https://github.com/frictionlessdata/datapackage-r#validate}{https://github.com/frictionlessdata/datapackage-r#validate}
#' @examples 
#' validate(descriptor = '{"name": "Invalid Datapackage"}')
#' 

validate = function(descriptor) {

  valid_errors = Package.load(descriptor = descriptor )

  valid_errors = list(valid = valid_errors$valid, errors = valid_errors$errors)
  # valid_errors = jsonlite::validate(descriptor)
  return(valid_errors)
}
