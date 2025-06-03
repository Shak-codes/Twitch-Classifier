setwd("~/GitHub/Twitch-Classifier/rdc/models/Multinomial")
source("../utils.R")
library(ROSE)
library(caret)

fit_multinomial <- function(features, response, alpha_values = seq(0, 1, 0.5), k = 10, pca_thresh = 0.95) {
  library(glmnet)
  library(caret)
  
  set.seed(123)
  folds <- createFolds(response, k = k, list = TRUE, returnTrain = FALSE)
  
  # Initialize metric containers
  accuracy_vector <- numeric(k)
  kappa_vector <- numeric(k)
  sensitivity_vector <- vector("list", k)
  specificity_vector <- vector("list", k)
  balanced_accuracy_vector <- vector("list", k)
  alpha_vector <- c()
  
  for (i in seq_along(folds)) {
    test_idx <- folds[[i]]
    train_idx <- setdiff(seq_len(nrow(features)), test_idx)
    
    X_train <- as.matrix(features[train_idx, ])
    y_train <- as.factor(response[train_idx])
    
    X_test <- as.matrix(features[test_idx, ])
    y_test <- as.factor(response[test_idx])
    
    # --- Upsample to fix class imbalance ---
    balanced <- balance_dataset(X_train, y_train)
    X_train <- as.matrix(balanced[, !(names(balanced) %in% "response")])
    y_train <- as.factor(balanced$response)
    
    # --- PCA preprocessing ---
    pca_model <- preProcess(X_train, method = "pca", thresh = pca_thresh)
    X_train <- predict(pca_model, X_train)
    X_test <- predict(pca_model, X_test)
    
    # --- Alpha tuning using cv.glmnet ---
    cv_results <- list()
    for (alpha_val in alpha_values) {
      cv_model <- cv.glmnet(X_train, y_train, family = "multinomial", alpha = alpha_val)
      cv_results[[as.character(alpha_val)]] <- cv_model
    }
    
    # Find alpha with minimum cross-validation error
    cv_errors <- sapply(cv_results, function(model) min(model$cvm))
    best_alpha <- alpha_values[which.min(cv_errors)]
    alpha_vector <- c(alpha_vector, best_alpha)
    
    # Train final model with best alpha
    final_model <- cv.glmnet(X_train, y_train, family = "multinomial", alpha = best_alpha)
    
    # Predict
    predictions <- predict(final_model, newx = X_test, s = "lambda.min", type = "class")
    
    # Confusion matrix and metrics
    conf <- confusionMatrix(as.factor(predictions), as.factor(y_test))
    
    accuracy_vector[i] <- conf$overall["Accuracy"]
    kappa_vector[i] <- conf$overall["Kappa"]
    sensitivity_vector[[i]] <- conf$byClass[,"Sensitivity"]
    specificity_vector[[i]] <- conf$byClass[,"Specificity"]
    balanced_accuracy_vector[[i]] <- conf$byClass[,"Balanced Accuracy"]
  }
  
  # Return final metric summaries
  return(list(
    mean_accuracy = mean(accuracy_vector, na.rm = TRUE),
    mean_kappa = mean(kappa_vector, na.rm = TRUE),
    mean_sensitivity = colMeans(do.call(rbind, sensitivity_vector), na.rm = TRUE),
    mean_specificity = colMeans(do.call(rbind, specificity_vector), na.rm = TRUE),
    mean_balanced_accuracy = colMeans(do.call(rbind, balanced_accuracy_vector), na.rm = TRUE),
    best_alphas = alpha_vector
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
      
      multinomial_model <- fit_multinomial(features, response)
      saveRDS(multinomial_model, file = paste0("multinomial", folder, length, shuffle, ".rds"))
      print(paste0("Finished ", paste0("multinomial", folder, length, shuffle, ".rds")))
    }
  }
}