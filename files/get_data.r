get_data <- function(task_name, indices){
    structural_information[[task_name]]$data <- structural_information[[task_name]]$data()
    data <- structural_information[[task_name]]$data
    data <- data[indices,]

    labelTxt <- structural_information[[task_name]]$label
    sensAttrsTxt <- structural_information[[task_name]]$sensAttrs
    label <- data[[labelTxt]]
    sensAttr1 <- data[, sensAttrsTxt[1]]
    sensAttr2 <- data[, sensAttrsTxt[2]]

    if(task_name == "german_credit"){
        #groups <- ifelse(data$age < 30, "young", "old")
        groups <- as.factor(data$female)
    }

    return(list(data = data, label = label, sensAttr1 = sensAttr1, sensAttr2 = sensAttr2, groups = groups, task_name = task_name))
}
