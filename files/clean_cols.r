clean_cols <- function(data, test_data = NULL, threshold = 0.97) {

   missing_cols <- apply(data, 2, function(x) sum(is.na(x))/length(x) > 0.1)
  constant_cols <- apply(data, 2, function(x) length(unique(x)) == 1)
  rare_cols <- apply(data, 2, function(x) max(table(x)/length(x)) >= threshold)

    data <- data[, !missing_cols & !constant_cols & !rare_cols] 
    if(!is.null(test_data)){
        test_data <- test_data[, !missing_cols & !constant_cols & !rare_cols]
        return(list(train = data, test = test_data))
    }
}
