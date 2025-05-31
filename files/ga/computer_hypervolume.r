#' Compute Hypervolume a multi-objective metric customized for project
#'
#' @param all_obj A matrix of objective values where each column represents an objective.
#' @return A numeric value representing the hypervolume.
#' @export
#' @examples
#' # Example usage
#' all_obj <- matrix(c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6), nrow = 3)
#' hypervolume <- compute_hypervolume(all_obj)
#' #' @importFrom ecr computeHV
compute_hypervolume <- function(all_obj) {
  ref_point <- matrix(c(1, 100, 50), nrow = 3, ncol = 1)
  all_obj <- as.matrix(all_obj, nrow = 3, ncol = 1)
  ecr::computeHV(all_obj, ref.point = ref_point)
}

