if(!require(dplyr)) install.packages("dplyr")
if(!require(xgboost)) install.packages("xgboost")
if(!require(glmnet)) install.packages("glmnet")
if(!require(ranger)) install.packages("ranger")
if(!require(themis)) install.packages("themis")
if(!require(UBL)) install.packages("UBL")
if(!require(DBI)) install.packages("DBI")
if(!require(glue)) install.packages("glue")
if(!require(RPostgreSQL)) install.packages("RPostgreSQL")
if(!require(recipes)) install.packages("recipes")
if(!require(future)) install.packages("future")
if(!require(future.apply)) install.packages("future.apply")
if(!require(future.callr)) install.packages("future.callr")
if(!require(reticulate)) install.packages("reticulate")
if(!require(ranger)) install.packages("ranger")

if(!require(keras3)){
	reticulate::install_python()

    install.packages("keras3")
    keras3::install_keras()
}


if(Sys.info()[["machine"]] == "arm64"){
setwd("/Volumes/simulation/PACIS 2/")
setwd("/Users/juliansengewald/Documents/data/Pacis/")

}else{
setwd("//129.217.232.229/simulation/PACIS Kopie/")
}

sourceDir <- function(path, trace = TRUE, ...) {
    op <- options(); on.exit(options(op)) # to reset after each
    for (nm in list.files(path, pattern = "[.][Rr]$", recursive = TRUE)) {
       if(trace) cat(nm,":")
       source(file.path(path, nm), ...)
       if(trace) cat("\n")
       options(op)
    }
}
sourceDir("files")
source("./data/german_credit.r")
source("db_files.r")

library("dplyr")

if(file.exists("structural_information.Rdata")){
    load("structural_information.Rdata")
}else{
    add_structural_information("german_credit", german_credit, "credit_risk", "good", c("age", "foreign_worker"), numericalFeatures = c("age", "credit_amount", "duration", "residence_since"))
    save(structural_information, file = "structural_information.Rdata")
}

if(file.exists("german_credit.Rdata")){
    load("german_credit.Rdata")
}else{
    german_credit <- german_credit()
    save(german_credit, file = "german_credit.Rdata")
}


if(file.exists("resamples.Rdata")){
    load("resamples.Rdata")
}else{
    imbalance_ratios <- c(0.2, 3/7, 0.6)
    ALL_RESAMPLE <- list()
    for(i in 1:length(imbalance_ratios)){ 
        applied_p <- imbalance_ratios[i]
        ALL_RESAMPLE[["german_credit"]][[paste(applied_p)]] <- create_indices(applied_p, german_credit, "credit_risk", 50)
    }
    save(ALL_RESAMPLE, file = "resamples.Rdata")
}

source("db_files.r")
