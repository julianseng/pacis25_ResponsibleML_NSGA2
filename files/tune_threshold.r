tune_threshold <- function(y_score, y_true) {
  # Define objective function to minimize (negative F1 score)
  obj_fun <- function(threshold) {
    y_pred <- ifelse(y_score > threshold, 1, 0)
    performance_metric(y_true, y_pred) # negative because optimize minimizes
  }
  
  # Find optimal threshold using optimize
  result <- optimize(obj_fun, interval = c(0, 1), maximum = TRUE)
  
  return(result$minimum)
}
