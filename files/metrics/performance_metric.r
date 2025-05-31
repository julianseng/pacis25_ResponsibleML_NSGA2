performance_metric <- function(y_true, y_pred, metric = "f1") {
  if (metric == "accuracy") {
    return(mean(y_true == y_pred))
  } else if (metric == "f1") {
    return(MLmetrics::F1_Score(y_true, y_pred))
  } else {
    stop("Invalid metric specified. Please choose from: 'accuracy', 'precision', 'recall', 'f1'.")
  }
}

