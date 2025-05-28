library(glmnet)
library(dplyr)
library(car)
library(corrplot)
library(caret)

setwd("~/GitHub/Twitch-Classifier/rdc/models")

df <- read.csv("../data/pairwise.csv")

normalize <- function(x) {
  if (min(x, na.rm = TRUE) == max(x, na.rm = TRUE)) {
    return(rep(0, length(x)))  # vector of zeros
  }
  return ((x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
}

cap_outliers_quantile <- function(x, lower_quantile = 0.01, upper_quantile = 0.99) {
  lower <- quantile(x, probs = lower_quantile, na.rm = TRUE)
  upper <- quantile(x, probs = upper_quantile, na.rm = TRUE)
  x[x < lower] <- lower
  x[x > upper] <- upper
  return(x)
}

response <- as.factor(df$result)
features <- df[-c(677, 678)]

nzv <- nearZeroVar(features, saveMetrics = TRUE)
features <- features[, !nzv$nzv]

features <- as.data.frame(lapply(features, cap_outliers_quantile))
features <- as.data.frame(lapply(features, normalize))
features <- features[, sapply(features, function(x) sd(x, na.rm = TRUE) != 0)]

df <- cbind(features, response)

cor_matrix <- cor(as.matrix(features))
high_cor <- findCorrelation(cor_matrix, cutoff = 0.9)
features <- features[, -high_cor]
df <- cbind(features, response)

sum(is.na(df))

table(df$response)

pca <- prcomp(features, center = TRUE, scale. = TRUE)
summary(pca)



set.seed(061322)

library(glmnet)

folds <- createFolds(response, k = 5, list = TRUE, returnTrain = FALSE)

# Example: Print the number of observations in each fold and check class distribution
sapply(folds, length)  # Number of observations in each fold

# Check class distribution in the first fold
table(response[folds[[1]]])  # Class distribution in fold 1

# Initialize vectors/lists to store the results
accuracy_vector <- numeric(length(folds))
kappa_vector <- numeric(length(folds))
sensitivity_vector <- vector("list", length(folds))  # List to store sensitivity for each fold
specificity_vector <- vector("list", length(folds))  # List to store specificity for each fold
balanced_accuracy_vector <- vector("list", length(folds))  # List to store balanced accuracy for each fold
alpha_vector <- c()

alpha_test_values <- seq(0, 1, by = 0.5)

for (i in seq_along(folds)) {
  # Split the data
  test_indices <- folds[[i]]
  train_indices <- setdiff(seq_len(nrow(features)), test_indices)
  
  X_train <- as.matrix(features[train_indices, ])
  y_train <- as.numeric(response[train_indices])
  X_test <- as.matrix(features[test_indices, ])
  y_test <- as.numeric(response[test_indices])
  
  cv_results <- list()
  
  # Loop over each alpha value
  for (alpha_val in alpha_test_values) {
    cv_model <- cv.glmnet(X_train, y_train, family = "multinomial", alpha = alpha_val)
    cv_results[[as.character(alpha_val)]] <- cv_model
  }
  
  # Find the alpha that gives the lowest cross-validated error
  cv_errors <- sapply(cv_results, function(model) min(model$cvm))
  best_alpha <- alpha_test_values[which.min(cv_errors)]
  alpha_vector <- c(alpha_vector, best_alpha)
  # Fit the model (example: Ridge regression with multinomial logistic)
  model <- cv.glmnet(X_train, y_train, family = "multinomial", alpha = best_alpha)
  
  # Make predictions on the test set
  predictions <- predict(model, newx = as.matrix(X_test), s = "lambda.min", type = "class")
  
  # Compute confusion matrix
  confusion <- confusionMatrix(as.factor(predictions), as.factor(y_test))
  
  # Store results
  accuracy_vector[i] <- confusion$overall['Accuracy']
  kappa_vector[i] <- confusion$overall['Kappa']
  
  # Store per-class metrics as vectors within the lists
  sensitivity_vector[[i]] <- confusion$byClass[,'Sensitivity']
  specificity_vector[[i]] <- confusion$byClass[,'Specificity']
  balanced_accuracy_vector[[i]] <- confusion$byClass[,'Balanced Accuracy']
}

# After the loop, you can compute the mean across all folds as needed
mean_accuracy <- mean(accuracy_vector)
mean_kappa <- mean(kappa_vector)
mean_sensitivity <- colMeans(do.call(rbind, sensitivity_vector))
mean_specificity <- colMeans(do.call(rbind, specificity_vector))
mean_balanced_accuracy <- colMeans(do.call(rbind, balanced_accuracy_vector))

# Print the results
print(paste("Mean Accuracy:", mean_accuracy))
print(paste("Mean Kappa:", mean_kappa))
print("Mean Sensitivity by Class:")
print(mean_sensitivity)
print("Mean Specificity by Class:")
print(mean_specificity)
print("Mean Balanced Accuracy by Class:")
print(mean_balanced_accuracy)

print(confusion)


response <- as.numeric(df$response)
features <- as.matrix(df[-c(677, 678)])
# Define a range of alpha values to test
alpha_values <- seq(0, 1, by = 0.01)

# Initialize an empty list to store cv.glmnet results
cv_results <- list()

# Loop over each alpha value
for (alpha_val in alpha_values) {
  cv_model <- cv.glmnet(features, response, family = "multinomial", alpha = alpha_val)
  cv_results[[as.character(alpha_val)]] <- cv_model
}

# Find the alpha that gives the lowest cross-validated error
cv_errors <- sapply(cv_results, function(model) min(model$cvm))
best_alpha <- alpha_values[which.min(cv_errors)]

final_model <- cv.glmnet(features, response, family = "multinomial", alpha = best_alpha)
lambda_min <- final_model$lambda.min

lambda_sequence <- final_model$lambda

closest_lambda_index <- which.min(abs(lambda_sequence - final_model$lambda.min))

# Print the closest lambda value and its index
closest_lambda <- lambda_sequence[closest_lambda_index]
cat("Closest lambda value:", closest_lambda, "\n")
cat("Corresponding s value (s", closest_lambda_index - 1, ")\n")

# Extract coefficients for s99 (100th lambda in the sequence)
coefficients_s99 <- coef(final_model, s = lambda_sequence[closest_lambda_index])

map_range <- function(value, from_min, from_max, to_min, to_max) {
  # Perform the linear mapping
  mapped_value <- (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min
  return(mapped_value)
}

for (i in 1:length(coefficients_s99)) {
  cat("Non-zero coefficients for class", i, "at s99:\n")
  
  # Convert sparse matrix to a regular matrix or vector
  coef_vector <- as.matrix(coefficients_s99[[i]])
  
  # Identify and extract non-zero coefficients
  non_zero_coef <- coef_vector[which(coef_vector != 0 & rownames(coef_vector) != "(Intercept)"), , drop = FALSE]
  
  # Calculate percentage contribution
  coef_values <- as.vector(non_zero_coef[, 1])
  positive_coeffs <- coef_values[coef_values > 0]
  negative_coeffs <- coef_values[coef_values < 0]
  
  sum_positive <- sum(positive_coeffs)
  max_pos <- max(positive_coeffs)
  sum_negative <- sum(negative_coeffs)
  max_neg <- min(negative_coeffs)
  
  percentages <- c()
  opacity <- c()
  # Combine coefficients and percentages into a data frame
  for (val in non_zero_coef) {
    if (val > 0) {
      percentages <- c(percentages, val / sum_positive * 100)
      opacity <- c(opacity, map_range(val / sum_positive * 100, 0, max_pos, 0.5, 1))
    } else {
      percentages <- c(percentages, -val / sum_negative * 100)
      opacity <- c(opacity, map_range(val / sum_positive * 100, 0, max_neg, 0.5, 1))
    }
  }
  
  non_zero_coef <- cbind(non_zero_coef, percentages, opacity)
  print(non_zero_coef)
  cat("\n")
}