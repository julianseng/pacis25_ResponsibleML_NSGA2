#' Outer optimization function for the German Credit dataset as part of the experiment.
#' 
outer_optimization <- function(df_train, df_test, balance_method, k, over_ratio) {
  df_processed <- balance_data("german_credit", df_train, balance_method, k = k, over_ratio = over_ratio)
  pred <- learn_data("german_credit", df_processed, df_test, "xgboost")
  best_threshold <- threshold_optimization(pred, df_test)
  hi <- compute_hypervolume(compute_phenotype(best_threshold, df_test, pred))
  values <- compute_phenotype(best_threshold, df_test, pred)
  
  return(list(hypervolume = hi, thresholds = best_threshold, values = values))
}


outer_optimization_avg <- function(df_train, df_test, balance_method, k, over_ratio, runs = 10, criteria = "hypervolume") {
  phenotyp_values <- lapply(1:runs, function(x) outer_optimization(df_train, df_test, balance_method, k, over_ratio))
  erg <- list()
  key <- rlang::hash(c(k, over_ratio))
  erg[[key]] <- list(phenotyp_values = phenotyp_values, 
                     genotype_values = c(k, over_ratio))
  return(erg) 
}
