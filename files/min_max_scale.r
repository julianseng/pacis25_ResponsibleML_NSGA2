min_max_scale_inner <- function(x, min, max){
  scaled <- (x - min) / (max - min)
  return(scaled)
}
min_max_scale <- function(train_data, test_data, task_name) {
  # Extract numerical features from structural information
  numerical_features <- structural_information[[task_name]]$numericalFeatures
  numerical_features <- base::intersect(colnames(train_data), numerical_features) 
  numerical_features <- base::intersect(colnames(test_data), numerical_features)
  train_data_scaled <- train_data
  test_data_scaled <- test_data

  for(feature in numerical_features) {
    min_val <- min(train_data[[feature]], na.rm = TRUE)
    max_val <- max(train_data[[feature]], na.rm = TRUE)

    train_data_scaled[[feature]] <- min_max_scale_inner(train_data[[feature]], min_val, max_val)
    test_data_scaled[[feature]] <- min_max_scale_inner(test_data[[feature]], min_val, max_val)
  }

  return(list(train = train_data_scaled, test = test_data_scaled))

}
