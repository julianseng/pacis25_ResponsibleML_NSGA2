fair_smote <- function(df, var, k = 5, over_ratio = 1, groups){
    index <- 1
    balanced_data <- list()

    if(length(k) == 1){
        k <- rep(k, length(unique(groups)))
    }
    if(length(over_ratio) == 1){
        over_ratio <- rep(over_ratio, length(unique(groups)))
    }
    for(group in unique(groups)){

        df_sub <- df[groups == group,]
        df_sub$groups <- NULL
        balanced_data[[index]] <- themis_smote(df = df_sub, var , k = k[index], over_ratio = over_ratio[index])
        index <- index + 1
    }
    balanced_data <- do.call(rbind, balanced_data)
    return(balanced_data)
}
