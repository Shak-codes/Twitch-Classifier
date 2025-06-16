setwd("~/GitHub/Twitch-Classifier/rdc/models/RF")
source("../utils.R")
library(ROSE)
library(caret)
library(randomForest)

fit_rf <- function(features, response, k = 10, pca_thresh = 0.95, ntree = 500, mtry = NULL) {
  library(caret)
  library(randomForest)
  
  set.seed(123)
  folds <- createFolds(response, k = k, list = TRUE, returnTrain = FALSE)
  
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
    
    # --- Upsample to fix class imbalance ---
    balanced <- balance_dataset(X_train, y_train)
    X_train <- balanced[, !(names(balanced) %in% "response")]
    y_train <- as.factor(balanced$response)
    
    # --- PCA preprocessing ---
    pca_model <- preProcess(X_train, method = "pca", thresh = pca_thresh)
    X_train_pca <- predict(pca_model, X_train)
    X_test_pca <- predict(pca_model, X_test)
    
    ctrl <- trainControl(method = "cv", number = 5)
    
    # Set tuning grid
    if (is.null(mtry)) {
      mtry_grid <- data.frame(mtry = floor(sqrt(ncol(X_train_pca))))
    } else {
      mtry_grid <- data.frame(mtry = mtry)
    }
    
    rf_model <- train(
      x = X_train_pca,
      y = y_train,
      method = "rf",
      trControl = ctrl,
      tuneGrid = mtry_grid,
      ntree = ntree,
      importance = TRUE,
      metric = "Accuracy"
    )
    
    predictions <- predict(rf_model, newdata = X_test_pca)
    
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
      
      rf_model <- fit_rf(features, response)
      saveRDS(rf_model, file = paste0("rf", folder, length, shuffle, ".rds"))
      print(paste0("Finished ", paste0("rf", folder, length, shuffle, ".rds")))
    }
  }
}
