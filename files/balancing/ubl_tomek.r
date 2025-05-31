UBL_tomek <- function(df, var){
data <- na.omit(df)
data <- data %>% dplyr::mutate_if(is.character, as.factor)
out <- UBL::TomekClassif(form = formula(paste0(var, "~ .")), dat =  data, dist = "HVDM", Cl = "all", rem = "both")
return(out[[1]])
}


#UBL_tomek(df_train, structural_information[["german_credit"]]$label)



