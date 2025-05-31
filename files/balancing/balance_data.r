balance_data <- function(task_name, data, method, ...){
if(method == "smote"){
        data$data <- themis_smote(df = data$data, 
                             var = structural_information[[task_name]]$label, 
                             ...                             
                             )
    }
    if(method == "tomek"){
        data$data <- UBL_tomek(df = data$data, 
                             var = structural_information[[task_name]]$label
                             )
    }
    if(method == "fair_smote"){
        data$data <- fair_smote(df = data$data, 
                           var = structural_information[[task_name]]$label, 
                           groups = data$groups,
                            ...
                           )
    }
    if(method == "over"){
        data$data <- oversampling(df = data$data, 
                             var = structural_information[[task_name]]$label
                             )
    }
    if(method == "fair_over"){
        data$data <- fair_oversampling(df = data$data, 
                             var = structural_information[[task_name]]$label, 
                             groups = data$groups
                             )
    }
    if(method == "none"){
        return(data)
    }
    if (method == "no_opt_balance") {
        data$data <- themis_smote(df = data$data, 
                             var = structural_information[[task_name]]$label, 
                             k = 5,
                             over_ratio = 0.5)

    }
    return(data)
   

}
#balance_data("german_credit", df_train, "tomek")

