#' Computes Fitness for a set of individuals. Handles the logic computing fitness values for new individuals and caching results.
#' #' @param inds A list of individuals for which to compute fitness.
#' @param look_up_table A named list that caches previously computed fitness values.
#' @param bmethod A method for computing fitness, typically a function.
#' @param df_train A data frame used for training.
#' @param df_test A data frame used for testing.
#' @return A list containing the updated look-up table and the fitness values for the input individuals.
#' @importFrom rlang hash
#' @importFrom future.apply future_lapply
compute_fitness <- function(inds, look_up_table = list(), bmethod, df_train, df_test) {
  keys <- sapply(inds, rlang::hash)
  new_keys <- setdiff(keys, names(look_up_table))
  print(paste0("New keys: ", length(new_keys)))
  
  if(length(new_keys) > 0) {
    inds_new <- inds[keys %in% new_keys]
    fitness_vals_new <- future_lapply(inds_new, map_ind_to_fitness, bmethod, df_train, df_test, future.seed = TRUE)
    names(fitness_vals_new) <- new_keys
    look_up_table <- append(look_up_table, fitness_vals_new)
  }
  
  fitness_vals_out <- look_up_table[keys]
  return(list(look_up_table = look_up_table, fitness_val = fitness_vals_out))
}
