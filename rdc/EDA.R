library(caret)
library(glmnet)
library(dplyr)
library(car)
library(corrplot)
library(caret)

setwd("~/GitHub/Twitch-Classifier/rdc/models")
folders <- c("regular", "filtered")
infiles <- c("pairwise500", "pairwise1000", "pairwise1500")
shuffled <- c("_shuffled", "")
pairwise_root <- "data/pairwise"
train_root <- "data/train"
test_root <- "data/test"

normalize <- function(x) {
  if (!is.numeric(x)) return(x)
  if (sd(x, na.rm = TRUE) == 0) return(rep(0, length(x)))
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}


for (folder in folders) {
  for (suffix in shuffled) {
    for (file in infiles) {
      filename <- paste0(file, suffix, ".csv")
      train_rds <- paste0(sub("pairwise", "train", file), suffix, ".rds")
      test_rds <- paste0(sub("pairwise", "test", file), suffix, ".rds")
      inpath <- file.path(pairwise_root, folder, filename)
      train_outpath <- file.path(train_root, folder, train_rds)
      test_outpath <- file.path(test_root, folder, test_rds)
      df <- read.csv(inpath)
      
      print(paste("=== Processing:", folder, filename, "==="))
      
      # --- Separate response and features ---
      response <- as.factor(df$result)
      features <- df[-c(677, 678)]
      print(paste("Feature & Observation count:", ncol(features), "&", length(response)))
      
      # --- Remove near-zero variance features ---
      nzv <- nearZeroVar(features, saveMetrics = TRUE)
      features <- features[, !nzv$nzv]
      print(paste("Feature & Observation count after NZV removal:", ncol(features), "&", length(response)))
      
      # --- Normalization ---
      features <- as.data.frame(lapply(features, normalize))
      features <- features[, sapply(features, function(x) sd(x, na.rm = TRUE) != 0)]
      
      # --- Remove highly correlated features ---
      cor_matrix <- cor(as.matrix(features))
      high_cor <- findCorrelation(cor_matrix, cutoff = 0.9)
      features <- features[, -high_cor]
      print(paste("Feature & Observation count after high correlation removal:", ncol(features), "&", length(response)))
      
      # --- Final data frame with response ---
      df <- cbind(features, response)
      cat("\n")
      
      # --- Check for NAs and class balance ---
      sum(is.na(df))
      table(df$response)
      
      # ------- Get train and test sets -------
      train_idx <- createDataPartition(df$response, p = 0.8, list = FALSE)
      train <- df[train_idx, ]
      test <- df[-train_idx, ]
      
      saveRDS(train, file = train_outpath)
      saveRDS(test, file = test_outpath)
    }
  }
}