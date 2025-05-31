german_credit <- function(){
    data <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.data", header = FALSE, sep = " ")
    data <- data.frame(data)
    colnames(data) <- c("status_account", "duration", "credit_history", "purpose", "credit_amount", "savings_account", "employment_since", "installment_rate", "personal_status",
                        "other_debtors", "residence_since", "property", "age", "other_installment_plans", "housing", "existing_credits", "job", "people_liable", "telephone", "foreign_worker", "credit_risk")

    numeric_columns <- c("duration", "credit_amount", "installment_rate", "residence_since", "age", "people_liable")
    factor_columns <- setdiff(colnames(data), numeric_columns)
    for (col in factor_columns) {
        if (col == "credit_risk") {
            data[[col]] <- as.factor(ifelse(data[[col]] == 1, "good", "bad"))
        } else {
            data[[col]] <- as.factor(data[[col]])
        }
    }

    data$female <- factor(ifelse(data$personal_status %in% c("A92", "A95"), "female", "male"))
    data$married_divorced <- factor(ifelse(data$personal_status %in% c("A91", "A92","A94"), "divorced_married", "single"))
    data$personal_status <- NULL
    return(data)
}
