themis_smote <- function(df, var, k = 5, over_ratio = 1) {
    themis::smotenc(df, var, k, over_ratio )
}
