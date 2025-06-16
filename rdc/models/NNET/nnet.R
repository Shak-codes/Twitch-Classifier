setwd("~/GitHub/Twitch-Classifier/rdc/models/NNET")
source("../utils.R")
library(ROSE)
library(caret)
library(nnet)

fit_nnet <- function(features, response, size = 5, decay = 1e-4, maxit = 200, k = 10, pca_thresh = 0.8) {
  set.seed(20886550)
  folds <- createFolds(response, k = k, list = TRUE, returnTrain = FALSE)
  
  accuracy_vector <- numeric(k)
  kappa_vector <- numeric(k)
  sensitivity_vector <- vector("list", k)
  specificity_vector <- vector("list", k)
  balanced_accuracy_vector <- vector("list", k)
  
  for (i in seq_along(folds)) {
    test_idx <- folds[[i]]
    train_idx <- setdiff(seq_len(nrow(features)), test_idx)
    
    X_train <- features[train_idx, ]
    y_train <- as.factor(response[train_idx])
    X_test <- features[test_idx, ]
    y_test <- as.factor(response[test_idx])
    
    # Upsample
    balanced <- balance_dataset(X_train, y_train)
    X_train <- balanced[, !(names(balanced) %in% "response")]
    y_train <- as.factor(balanced$response)
    
    # PCA preprocessing
    pca_model <- preProcess(X_train, method = c("center", "scale", "pca"), thresh = pca_thresh)
    X_train <- predict(pca_model, X_train)
    X_test <- predict(pca_model, X_test)
    
    # Internal grid search for best size/decay
    tune_grid <- expand.grid(size = c(3, 5, 7, 10),
                             decay = c(0.0001, 0.001, 0.01, 0.1))
    
    ctrl <- trainControl(method = "cv", number = 5)
    
    nnet_model <- train(
      x = X_train,
      y = y_train,
      method = "nnet",
      trControl = ctrl,
      tuneGrid = tune_grid,
      trace = FALSE,
      maxit = maxit,
      MaxNWts = 5000
    )
    
    y_train_matrix <- class.ind(y_train)
    final_model <- nnet(X_train, y_train_matrix,
                        size = nnet_model$bestTune$size,
                        decay = nnet_model$bestTune$decay,
                        maxit = maxit,
                        trace = FALSE,
                        softmax = TRUE,
                        MaxNWts = 5000)
    
    probs <- predict(final_model, X_test, type = "raw")
    predictions <- colnames(probs)[max.col(probs)]
    
    conf <- confusionMatrix(as.factor(predictions), y_test)
    
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
folders <- c("filtered")
lengths <- c("500", "1000", "1500")
shuffled <- c("")

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
      
      nnet_model <- fit_nnet(features, response)
      saveRDS(nnet_model, file = paste0("nnet", folder, length, shuffle, ".rds"))
      print(paste0("Finished ", paste0("nnet", folder, length, shuffle, ".rds")))
    }
  }
}
