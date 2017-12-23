#' Readable class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include profile.R
#' @keywords data
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

BinaryReadable <- R6::R6Class(
  "BinaryReadable",
  
  public = list(
    initialize = function(options = list()) {
      
    },
    
    
    read = function(size = NULL) {
      
    }
    
    
    
  ),
  active = list(
    destroyed = function(value) {
      
    }
    
  ),
  private = list(
    encoding_ = NULL,
    objectMode_ = FALSE,
    read_ = function() {
      browser()
    },
    destroy_ = function() {
      
    },
    buffer_ = list(),
    readable_ = TRUE,
    paused_ = TRUE,
    pipeDestination_ = list(),
    flowing_ = FALSE
    
    
    
    
    
  )
)
