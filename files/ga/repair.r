#' Custom repair function for a genetic algorithm
#' This function ensures that the first two elements of the individual are rounded to the nearest integer,
#' and the last two elements are constrained to be between 0 and 1.
#'
#' @param ind A numeric vector representing an individual in the population.
#' @return A repaired individual with the first two elements rounded and the last two elements constrained.
#' #' @examples
#' ind <- c(3.7, 2.1, 1.5, -0.2)
#' repaired_ind <- repair(ind)
#' #' @export
#' 


repair <- function(ind) {
  ind[1] <- round(ind[1])
  ind[2] <- round(ind[2])
  ind[3] <- if(ind[3] > 1) 1 else if(ind[3] < 0) 0 else ind[3]
  ind[4] <- if(ind[4] > 1) 1 else if(ind[4] < 0) 0 else ind[4]
  return(ind)
}
