oversampling <- function(df, var) {
    n <- nrow(df)
    n_pos <- max(table(df[[var]]))
    n_neg <- n - n_pos
    pos_label <- structural_information[["german_credit"]]$posClass
    if (n_pos > n_neg) {
        df_pos <- df[df[[var]] == pos_label, ]
        df_neg <- df[df[[var]] != pos_label, ]
        df_neg <- df_neg[sample(1:nrow(df_neg), n_pos, replace = TRUE), ]
        df <- rbind(df_pos, df_neg)
    } 

    row.names(df) <- NULL
    return(df)
}

#df <- data.frame(
#    x = c(1, 1, 1, 2, 2, 2, 3, 3, 3),
#    y = c(1, 1, 0, 1, 0, 0, 0, 0, 0)
#)

#oversampling(df, "y")


fair_oversampling <- function(df, var, groups){
    index <- 1
    balanced_data <- list()
    for(group in unique(groups)){
        df_sub <- df[groups == group,]
        df_sub$groups <- NULL
        balanced_data[[index]] <- oversampling(df = df_sub, var)
        index <- index + 1
    }
    balanced_data <- do.call(rbind, balanced_data)
    return(balanced_data)
}

#df <- data.frame(
#    x = c(1, 1, 1, 2, 2, 2, 3, 3, 3),
#    y = c(1, 1, 0, 1, 0, 0, 0, 0, 0),
#    groups = c(1, 1, 1, 2, 2, 2, 3, 3, 3)
#)

#fair_oversampling(df, "y", df$groups)


