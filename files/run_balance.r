run_balance <- function(obj){
    tsk <- obj$task
    hyp <- obj$task_hyperparameter
    hash <- digest::digest(list(tsk, hyp))

    load("resamples.Rdata")

    resamples <- ALL_RESAMPLE[[tsk[["task_data"]]]] 

    b <- tsk[["resample"]]
    rat <- tsk[["balance_ratio_set"]]
    if(!is.null(hyp) || !is.na(hyp)){    
        pth <- file.path("out", tsk[["task_data"]], paste0("rat=", rat), b, tsk[["task_method"]], paste0("rep=", tsk[["repetition"]]), paste0(names(hyp), "=", hyp) %>% paste0(collapse = "_"))
    }
    else{
        pth <- file.path("out", tsk[["task_data"]], paste0("rat=", rat), b, tsk[["task_method"]] , paste0("rep=", tsk[["repetition"]]))
    }
    
    if(file.exists(file.path(pth, "balanced.Rdata"))){
        log_run(task_id = tsk[["task_id"]], message = "Balancing already done")
        close_task(task_id = tsk[["task_id"]])
        warning("Task already done")
        return()
    }else {
    train_indices <- resamples[[rat]][[b]]$train_indices
    test_indices <- resamples[[rat]][[b]]$test_indices
    df_train <- get_data("german_credit", train_indices) 
    df_test <- get_data("german_credit", test_indices)
    if(any(tsk[["task_method"]] %in% c("smote", "fair_smote"))){
        log_run(task_id = tsk[["task_id"]], message = "Running balancing")
        df_processed <- balance_data(tsk[["task_data"]], df_train, tsk[["task_method"]], k = hyp[["k"]], over_ratio = hyp[["over_ratio"]])
    }

    if(tsk[["task_method"]] == "tomek"){
        log_run(task_id = tsk[["task_id"]], message = "Running balancing")
        df_processed <- balance_data(tsk[["task_data"]], df_train, tsk[["task_method"]])
    }

    if(!dir.exists(pth)){
        dir.create(pth, recursive = TRUE)
    }
    out <- list(train = df_processed, test = df_test)
    save(
    out,
     file = file.path(pth, "balanced.Rdata")
    ) 

    con <- get_db_connection()
    pth_char <- as.character(pth)
    DBI::dbExecute(con, glue::glue("UPDATE tasks SET task_path = '{pth_char}' WHERE task_id = {tsk[['task_id']]}"))
    close_con(con)

    if(file.exists(file.path(pth, "balanced.Rdata"))){
        log_run(task_id = tsk[["task_id"]], message = "Balancing done")
        close_task(task_id = tsk[["task_id"]])
        schedule_next_task(obj)
    }else {
       log_run(task_id = tsk[["task_id"]], message = "Balancing failed")
    }
    }


   
}

schedule_next_task <- function(obj){
    if(obj$task$task_type == "balancing"){

        new_frame <- expand.grid(task_method = c("xgboost", "glmnet", "svm", "neural_network", "random_forest"), repetition = 1:3, task_type = "learning", previouse_task = obj$task$task_id, stringsAsFactors = FALSE)
        tasks <- obj$task %>% select(c(-task_method, -hyperparameter, -task_id, -task_type, -previouse_task, -repetition)) %>% bind_cols(new_frame) 
        con <- get_db_connection()
        DBI::dbWriteTable(con, "tasks", tasks, append = TRUE, row.names = FALSE)
        close_con(con)

    }
}


run_learner <- function(obj){
    # has task in prd
    tsk <- obj$task
    tsk_bf <- get_task(tsk$previouse_task, report_only = TRUE)
    pth <- file.path(tsk_bf$task_path, paste0(obj$task$task_method,"_learned.Rdata"))

    if(file.exists(file.path(tsk_bf$task_path, "balanced.Rdata"))){
        # load balanced data
        myenv <- new.env()
        load(file.path(tsk_bf$task_path, "balanced.Rdata"), envir = myenv)
        df_train <- myenv$out$train
        df_test <- myenv$out$test

        log_run(task_id = tsk$task_id, message = "Starting learning")
        pred <- learn_data(obj$task$task_data, df_train, df_test, tsk$task_method)


        save(
            pred,
            file = file.path(tsk_bf$task_path, paste0(tsk$task_method,"_learned.Rdata"))
        )

        if(file.exists(pth)){
            log_run(task_id = tsk$task_id, message = "Learning done")
            close_task(task_id = obj$task$task_id)
            
            con <- get_db_connection()
            pth_char <- as.character(pth)
            DBI::dbExecute(con, glue::glue("UPDATE tasks SET task_path = '{pth_char}' WHERE task_id = {tsk[['task_id']]}"))
            close_con(con)
            message("Task done")
        }
    }else{
        log_run(task_id = tsk$task_id, message = "File not found")
        set_task_status(tsk_bf$task_id, "failed")
    }

}


#obj <- get_task(1564, report_only = TRUE)
#obj <- get_task(1540, report_only = TRUE)

#obj <- get_task(1540, report_only = TRUE)
#run_learner(obj)


#obj <- get_task()

