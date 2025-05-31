#' Threshold optimization optimizing hypervolume
#' #' @param pred A prediction object from a model
#' @param df_test A data frame containing the test set with true labels
#' @param criteria A string indicating the optimization criteria, currently only "hypervolume" 
#' @return The optimal threshold value
#' @export
threshold_optimization <- function(pred, df_test, criteria = "hypervolume") {
  thresholds <- seq(0.05, 0.95, 0.01)

  fitness_vals <- sapply(thresholds, compute_phenotype, 
                        df_test = df_test, 
                        pred = pred) 
  
  if(criteria == "hypervolume") {
    return(apply(fitness_vals, 2, compute_hypervolume) %>% 
           which.max() %>% 
           thresholds[.])
  } 
}
