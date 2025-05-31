one_hot_encode <- function(data) {
    for (col in seq_along(data)) {
        if (!is.factor(data[[col]])) {
            next
        }
        one_hot <- as.data.frame(model.matrix(~ data[[col]] - 1))
        colnames(one_hot) <- paste0(names(data)[col], "_", gsub("data\\[\\[col\\]\\]", "", colnames(one_hot)))
        data <- cbind(data, one_hot)
        data[[col]] <- NULL
    }
    return(data)
}
