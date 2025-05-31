tpr <- function(pred, label, posClass){
    tp <- sum(pred == 1 & label == posClass)
    fn <- sum(pred != 1 & label == posClass)
    return(tp / (tp + fn))
}

fair_metric <- function(pred, df, type = "unfairness"){
    tpr_rates <- c()
    for(g in unique(df$groups)){
        tpr_rates <- c(tpr_rates, tpr(pred[df$groups == g], df$label[df$groups == g], "good"))
    }
    if(type == "difference"){
        return(max(tpr_rates) - min(tpr_rates))
    }
    if(type == "unfairness"){
        return(1 - (min(tpr_rates) / max(tpr_rates)))
    }
}
