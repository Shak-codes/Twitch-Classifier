setwd("~/GitHub/Twitch-Classifier/rdc/models/XGB")
source("../utils.R")
library(ROSE)
library(caret)

fit_xgb <- function(features, response, k = 10, pca_thresh = 0.95) {
  library(caret)
  library(xgboost)
  
  set.seed(123)
  folds <- createFolds(response, k = k, list = TRUE, returnTrain = FALSE)
  
  # Metric containers
  accuracy_vector <- numeric(k)
  kappa_vector <- numeric(k)
  sensitivity_vector <- vector("list", k)
  specificity_vector <- vector("list", k)
  balanced_accuracy_vector <- vector("list", k)
  
  for (i in seq_along(folds)) {
    test_idx <- folds[[i]]
    train_idx <- setdiff(seq_len(nrow(features)), test_idx)
    
    X_train <- as.data.frame(features[train_idx, ])
    y_train <- as.factor(response[train_idx])
    
    X_test <- as.data.frame(features[test_idx, ])
    y_test <- as.factor(response[test_idx])
    
    # --- Upsample for class balance ---
    balanced <- balance_dataset(X_train, y_train)
    X_train <- balanced[, !(names(balanced) %in% "response")]
    y_train <- as.factor(balanced$response)
    
    # --- PCA ---
    pca_model <- preProcess(X_train, method = "pca", thresh = pca_thresh)
    X_train_pca <- predict(pca_model, X_train)
    X_test_pca <- predict(pca_model, X_test)
    
    # --- Prepare data for caret training ---
    ctrl <- trainControl(method = "cv", number = 5)
    
    xgb_grid <- expand.grid(
      nrounds = c(100, 200),
      max_depth = c(3, 6),
      eta = c(0.05, 0.1),
      gamma = 0,
      colsample_bytree = 0.8,
      min_child_weight = 1,
      subsample = 0.8
    )
    
    xgb_model <- train(
      x = X_train_pca,
      y = y_train,
      method = "xgbTree",
      trControl = ctrl,
      tuneGrid = xgb_grid,
      verbosity = 0,
      metric = "Accuracy"
    )
    
    predictions <- predict(xgb_model, newdata = X_test_pca)
    conf <- confusionMatrix(predictions, y_test)
    
    accuracy_vector[i] <- conf$overall["Accuracy"]
    kappa_vector[i] <- conf$overall["Kappa"]
    sensitivity_vector[[i]] <- conf$byClass[,"Sensitivity"]
    specificity_vector[[i]] <- conf$byClass[,"Specificity"]
    balanced_accuracy_vector[[i]] <- conf$byClass[,"Balanced Accuracy"]
  }
  
  return(list(
    mean_accuracy = mean(accuracy_vector, na.rm = TRUE),
    mean_kappa = mean(kappa_vector, na.rm = TRUE),
    mean_sensitivity = colMeans(do.call(rbind, sensitivity_vector), na.rm = TRUE),
    mean_specificity = colMeans(do.call(rbind, specificity_vector), na.rm = TRUE),
    mean_balanced_accuracy = colMeans(do.call(rbind, balanced_accuracy_vector), na.rm = TRUE)
  ))
}

train_root <- "../../data/train"
test_root <- "../../data/test"
folders <- c("regular", "filtered")
lengths <- c("500", "1000", "1500")
shuffled <- c("_shuffled", "")

for (folder in folders) {
  for (shuffle in shuffled) {
    for (length in lengths) {
      train_file <- paste0("train", length, shuffle, ".rds")
      test_file <- paste0("test", length, shuffle, ".rds")
      train_path <- file.path(train_root, folder, train_file)
      test_path <- file.path(test_root, folder, test_file)
      
      train <- readRDS(train_path)
      test <- readRDS(test_path)
      features <- train[, -ncol(train)]
      response <- train$response
      
      xgb_model <- fit_xgb(features, response)
      saveRDS(xgb_model, file = paste0("xgb", folder, length, shuffle, ".rds"))
      print(paste0("Finished ", paste0("xgb", folder, length, shuffle, ".rds")))
    }
  }
}