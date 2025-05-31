#' Map individual to fitness values based on the balancing method
#' @param ind Individual parameters
#' @param bmethod Balancing method to use
#' @param df_train Training dataset
#' @param df_test Testing dataset
#' @return Fitness values for the individual
map_ind_to_fitness <- function(ind, bmethod, df_train, df_test) {
  if(bmethod == "smote") {
    return(outer_optimization_avg(df_train, df_test, "smote", ind[1], ind[3]))
  } 
  if(bmethod == "fair_smote") {
    return(outer_optimization_avg(df_train, df_test, "fair_smote", ind[1:2], ind[3:4]))
  }
  if(bmethod == "no_opt_balance") {
    return(outer_optimization_avg(df_train, df_test, "no_opt_balance", 0, 0))
  }
}
