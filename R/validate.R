#' validate descriptor
#' @param descriptor descriptor
#' @rdname validate
#' @export
#' 

# Module API


# https://github.com/frictionlessdata/datapackage-js#validate

validate = function(descriptor) {

  valid_errors = Package.load(descriptor = descriptor )

  valid_errors = list(valid = valid_errors$valid, errors = valid_errors$errors)
  # valid_errors = jsonlite::validate(descriptor)
  return(valid_errors)

}