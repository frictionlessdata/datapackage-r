#' DataPackageError class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @keywords data
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

DataPackageError <- R6::R6Class(
  
  "DataPackageError",

  
  public = list(
    message=NULL,
    error=NULL,
    initialize = function (message, error=NULL){
      self$message <- message
      self$error <- error
    }),
  
    active = list(
      
      multiple = function () {
      if (length(self$error) %in% c(0,1) ) return (FALSE) else return (TRUE)
    },
    
    errors = function () {
      return (as.list(self$error))
    }
    )
)
