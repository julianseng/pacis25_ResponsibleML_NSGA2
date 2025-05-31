#' Select the topmost n elements from a vector for survival in ga
#' @param x A numeric vector.
#' @param n An integer specifying how many top elements to select.
#' @return A vector of indices of the topmost n elements (retuns indices, not individuals!).
#' @export
sel_topmost_id <- function(x, n) {
  order(x, decreasing = TRUE)[1:n]
}
