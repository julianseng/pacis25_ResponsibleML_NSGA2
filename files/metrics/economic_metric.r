economic_metric <- function(data, pred, label, threshold = 0.5){
    p_loss <- 0.2
    Amount <- data$data$credit_amount
    Type <- data$data$purpose
    rate <- dplyr::case_when(
        Type == "A49" ~ 0.045, # commercial
        Type == "A46" ~ 0.04,  # education
        TRUE ~ 0.075           # others
    )

    avg_rate <- mean(rate)
    FP <- ifelse(pred > threshold & label == 0,1,0) # 

    FP <- matrix(FP, nrow = 1)
    loss_value <- matrix((p_loss * Amount), ncol = 1)
    cost_fp <- FP %*% loss_value

    FN <- ifelse(pred < threshold & label == 1, 1, 0)
    FN <- matrix(FN, nrow = 1)
    loss_earning <- matrix(rate * Amount, ncol = 1)
    alternative_use <- matrix(Amount * (-avg_rate * 0.7 + 0.3 * p_loss), ncol = 1)
    cost_fn <- FN %*% loss_earning + FN %*% alternative_use

    data.frame(cost_fp = cost_fp, cost_fn = cost_fn)
}
