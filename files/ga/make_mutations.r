#' Make mutations in a genetic algorithm individual
#'
#' @param ind A vector representing an individual in the genetic algorithm.
#' @param prop The probability of a mutation is occuring on the indiviual (default is 0.1).
#' @return A vector representing the mutated individual.
#' @export
#' @examples
#' ind <- c(1, 2, 0.5, 0.3)
#' mutated_ind <- make_mutations(ind, prop = 0.2)

make_mutations <- function(ind, prop = 0.1) {
  prop <- prop/length(ind)
  ind[1] <- if(runif(1) < prop) sample(1:10, 1) else ind[1]
  ind[2] <- if(runif(1) < prop) sample(1:10, 1) else ind[2]
  ind[3] <- if(runif(1) < prop) runif(1) else ind[3]
  ind[4] <- if(runif(1) < prop) runif(1) else ind[4]
  return(ind)
}
