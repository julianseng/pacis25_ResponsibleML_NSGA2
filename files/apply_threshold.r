apply_threshold <- function(y_score, y_true, threshold, metric = "f1") {
  y_hat <- ifelse(y_score > threshold, 1, 0)
  if(is.null(metric)){
    return(y_hat)
  }else {
       return(performance_metric(y_true, y_hat, metric))
  }
}
