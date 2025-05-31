create_indices <- function(p, df, label, num_resample) {
    # Number of rows in the dataframe
    N <- nrow(df)

    min_class <- names(which.min(table(df[[label]])))
    max_class <- names(which.min(table(df[[label]])))

    # Initialize list to store indices
    indices <- vector("list", num_resample)
    
    # Calculate probabilities
    prob_min_class <- p * sum(df[[label]] == min_class)
    prob_max_class <- prob_min_class / p
    probs <- c(prob_min_class, prob_max_class)
    probs <- probs / sum(probs)
    
    # Calculate number of samples for each class
    num_samples <- round(N * probs)
    
    # Generate resampled indices
    for (i in 1:num_resample) {
        min_class_indices <- sample(which(df[[label]] == min_class), num_samples[1], replace = TRUE)
        max_class_indices <- sample(which(df[[label]] == max_class), num_samples[2], replace = TRUE)
        indices[[i]] <- c(min_class_indices, max_class_indices)
    }
    
    return(indices)
}

create_indices <- function(p, df, label, num_resample, sub_ratio = 0.7) {
    N <- nrow(df)
    var_label <- df[[label]]
    min_class <- names(which.min(table(var_label)))
    max_class <- names(which.max(table(var_label)))
    num_min_class <- table(var_label)[min_class]
    num_max_class <- table(var_label)[max_class]

    indices <- list()
    one <- p * num_min_class
    two <- one / p
    probs <- c(one, two)
    probs <- probs / sum(probs)
    nums <- floor(N * probs * sub_ratio)

    for (i in 1:num_resample) {
        train_indices <- c(sample(which(var_label == min_class), nums[1], replace = TRUE),
                           sample(which(var_label == max_class), nums[2], replace = TRUE))
        test_indices <- setdiff(1:N, train_indices)

        indices[[i]] <- list(train_indices = train_indices, test_indices = test_indices)
    }
return(indices)
}

imbalance_ratio <- function(df, label) {
    freq <- table(df[[label]])
    imbalance_ratio <- min(freq)/max(freq) 
    return(imbalance_ratio)
}


#a <- create_indices(0.4, german_credit, "credit_risk")
#imbalance_ratio(german_credit[a[[2]],], label = "credit_risk")
#table(german_credit[a[[1]], "credit_risk"])

