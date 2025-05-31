learn_data <- function(task_name, train_data, test_data, method) {
  # Validate inputs
  
  if(is.null(task_name)) task_name <- train_data$task_name
  valid_methods <- c("xgboost", "logistic_regression", "random_forest", "neural_network", "svm", "glmnet")
  if (!method %in% valid_methods) {
    stop(sprintf("Invalid method specified. Please choose from: '%s'.", paste(valid_methods, collapse = "', '")))
  }
  
  # Extract label column name and positive class from structural information
  label_col <- structural_information[[task_name]]$label
  pos_class <- structural_information[[task_name]]$posClass
  
  # Preprocess training and testing datasets
  train_features <- preprocess_data(train_data$data, label_col)
  test_features <- preprocess_data(test_data$data, label_col)

  cleaned_data <- clean_cols(train_features, test_features)
  train_features <- cleaned_data$train
  test_features <- cleaned_data$test
  
  # Prepare binary labels for training and testing datasets
  train_labels <- ifelse(train_data$data[[label_col]] == pos_class, 1, 0)
  test_labels <- ifelse(test_data$data[[label_col]] == pos_class, 1, 0)
  
  model <- NULL   # Placeholder for the trained model
  train_pred <- NULL   # Placeholder for training predictions
  test_pred <- NULL    # Placeholder for testing predictions
  
  # Train models based on the selected method
  if (method == "xgboost") {
    
    library(xgboost)
    
    params <- list(
      booster = "gbtree",
      eta = 0.1,
      max_depth = 6,
      objective = "binary:logistic",
      eval_metric = "logloss"
    )
    
    model <- xgboost::xgboost(
      data = as.matrix(train_features),
      label = train_labels,
      params = params,
      nrounds = 200, # check for proper values
      verbose = FALSE   # Suppress verbose output during training
    )
    
    train_pred <- predict(model, as.matrix(train_features))
    test_pred <- predict(model, as.matrix(test_features))
    
} else if (method == "logistic_regression") {
    train_data_log <- cbind(train_features, label=train_labels)
    colnames(train_data_log) <- c(colnames(train_features), "label")
    
    model <- glm(label ~ .,
      data = train_data_log, 
      family = binomial(link = "logit")
    )
    
    train_pred <- predict(model, newdata = as.data.frame(train_features), type = "response") %>% as.vector()
    test_pred <- predict(model, newdata = as.data.frame(test_features), type = "response") %>% as.vector()
    
} else if (method == "random_forest") {
    
    
    model <- ranger::ranger(
      x = train_features,
      y = as.factor(train_labels),
      num.trees = 200   # Number of trees in the forest
    )
    
    train_pred <- predict(model, newdata=train_features)[ ,2] %>% as.vector()
    test_pred <- predict(model, newdata=test_features)[ ,2] %>% as.vector()
  
} else if (method == "neural_network") {
     library(keras3)
      scaled_data <- min_max_scale(train_features, test_features, task_name)

     num_fts <- ncol(scaled_data$train)
     nn_model <- keras_model_sequential(input_shape = num_fts ) %>%
         layer_dense(units=num_fts, activation='relu') %>%
         layer_dropout(rate=0.3) %>%
         layer_dense(units=num_fts, activation='relu') %>%
         layer_dropout(rate=0.3) %>%
         layer_dense(units=1, activation='sigmoid')
     
     nn_model %>% compile(
         optimizer = optimizer_adam(weight_decay = 0.005, learning_rate = 0.01),
         loss='binary_crossentropy',
         metrics=c('accuracy')
     )
     

     history_nn <-
       nn_model %>% fit(
           x=as.matrix(scaled_data$train),
           y=train_labels,
           epochs=800,
           batch_size=128,
           validation_split=0.1,
           verbose= 0 
       )

     model<-nn_model 

     train_pred <- predict(nn_model,as.matrix(scaled_data$train)) %>% as.vector()
     test_pred <- predict(nn_model, as.matrix(scaled_data$test)) %>% as.vector()
 } else if (method == "svm") {
    
    library(e1071)

    tune.out <- e1071::tune(svm, train_features, as.factor(train_labels), 
                     kernel = "radial", 
                     ranges = list(cost = c(0.1, 1, 10), 
                     gamma = c(0.5, 1, 2)),
                     probability = TRUE)
    model <- tune.out$best.model
    train_pred <- predict(model, newdata=train_features, probability = TRUE)
    train_pred <- attr(train_pred, "probabilities")[,1] %>% as.vector()
    test_pred <- predict(model, newdata=test_features, probability = TRUE)
    test_pred <- attr(test_pred, "probabilities")[,1] %>% as.vector()
  } else if (method == "glmnet") {
                          
    library(glmnet)
    
    lambda_grid <- 10^seq(-2, 2, by = 0.1)
    model <- cv.glmnet(
      x = as.matrix(train_features),
      y = train_labels,
      alpha = 1, # Lasso regression
      lambda = lambda_grid,
      family = "binomial"
    )
    
    best_lambda <- model$lambda.min
    model <- glmnet(
      x = as.matrix(train_features),
      y = train_labels,
      alpha = 1, # Lasso regression
      lambda = best_lambda,
      family = "binomial"
    )
    
    train_pred <- predict(model, s = best_lambda, newx = as.matrix(train_features), type = "response") %>% as.vector()
    test_pred <- predict(model, s = best_lambda, newx = as.matrix(test_features), type = "response") %>% as.vector()                    
     
  }
 

 return(list(
   model            = model,
   train_predictions= train_pred,
   test_predictions= test_pred,
   data = list(x_train = train_features, x_test = test_features, y_train = train_labels, y_test = test_labels),
   train_labels     = train_labels,
   test_labels       = test_labels,
   method           = method
 ))
}


