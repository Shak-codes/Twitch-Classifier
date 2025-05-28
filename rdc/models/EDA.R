library(caret)
library(glmnet)
library(dplyr)
library(car)
library(corrplot)
library(caret)

setwd("~/GitHub/Twitch-Classifier/rdc/models")
df <- read.csv("../data/pairwise.csv")

# --- Normalization and Outlier Capping ---
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

# --- Separate response and features ---
response <- as.factor(df$result)
features <- df[-c(677, 678)]  # remove response and other unwanted columns

# --- Remove near-zero variance features ---
nzv <- nearZeroVar(features, saveMetrics = TRUE)
features <- features[, !nzv$nzv]

# --- Outlier handling and normalization ---
features <- as.data.frame(lapply(features, cap_outliers_quantile))
features <- as.data.frame(lapply(features, normalize))

# --- Remove constant features after scaling ---
features <- features[, sapply(features, function(x) sd(x, na.rm = TRUE) != 0)]

# --- Remove highly correlated features ---
cor_matrix <- cor(as.matrix(features))
high_cor <- findCorrelation(cor_matrix, cutoff = 0.9)
features <- features[, -high_cor]

# --- Final data frame with response ---
df <- cbind(features, response)

# --- Check for NAs and class balance ---
sum(is.na(df))
table(df$response)

# ------- Get train and test sets -------
trainIndex <- createDataPartition(df$response, p = 0.8, list = FALSE)
train <- df[trainIndex, ]
test <- df[-trainIndex, ]

saveRDS(train, file = "../data/train.rds")
saveRDS(test, file = "../data/test.rds")