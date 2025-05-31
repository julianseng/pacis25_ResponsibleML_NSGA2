#' Computes Phenotype based on the optimal threshold. Retunrs the fairness, performance, and cost metrics as expression of genotype.
#'
#' @param opt_threshold Optimal threshold for classification
#' @param df_test Data frame containing test data
#' @param pred List containing test predictions and labels
#' @return A matrix containing the computed phenotype metrics
#' @export
#' 
compute_phenotype <- function(opt_threshold, df_test, pred) {
  test_label <- apply_threshold(pred$test_predictions, pred$test_labels, opt_threshold, metric = NULL)
  obj1 <- fair_metric(test_label, df_test, type = "unfairness")
  obj1b <- fair_metric(test_label, df_test, type = "difference")
  obj2 <- 1/performance_metric(y_true = pred$test_labels, y_pred = test_label, metric = "f1")
  obj3 <- economic_metric(df_test, pred$test_predictions, pred$test_labels, threshold = opt_threshold) %>% rowSums()
  obj3 <- obj3 / 10000
  all_obj <- matrix(c(obj1, obj2, obj3), nrow = 3, ncol = 1)
  rownames(all_obj) <- c("unfairness", "performance", "cost")
  ref_point <- matrix(c(1, 100, 50), nrow = 3, ncol = 1)
  if(any(is.na(all_obj))) all_obj <- ref_point
  return(all_obj)
}

