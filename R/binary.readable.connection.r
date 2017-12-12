#' Readable class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include constraints.R
#' @include tableschemaerror.R
#' @include profile.R
#' @keywords data
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.
BinaryReadableConnection <- R6Class(
  "BinaryReadableConnection",
  
  public = list(
    initialize = function(options = list()) {
      
    },
    
    
    read = function(size = NULL) {
      open(private$connection_)
      return(iterators::iter(function(){
        if (length(value <- readBin(private$connection_, integer(), size = 1)) > 0) {
         
          private$index_ = private$index_ + 1
          
          return(value)
          
        }
        
        else {
          close(private$connection_)
          stop('StopIteration')
        }
        
      }))
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
