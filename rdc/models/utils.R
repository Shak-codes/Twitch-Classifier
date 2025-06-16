balance_dataset <- function(features, response) {
  features <- as.data.frame(features)
  response <- as.factor(response)
  
  counts <- table(response)
  mcount <- median(counts)
  mclass <- names(counts)[counts == mcount][1]
  
  balanced <- data.frame(features[response == mclass, ], 
                         response = response[response == mclass])
  
  for (clabel in setdiff(names(counts), mclass)) {
    cidx <- which(response == clabel)
    current_count <- length(cidx)
    
    if (current_count > mcount) {
      sampled_idx <- sample(cidx, size = mcount)
    } else {
      sampled_idx <- sample(cidx, size = mcount, replace = TRUE)
    }
    
    balanced <- rbind(
      balanced,
      data.frame(features[sampled_idx, ], response = response[sampled_idx])
    )
  }
  
  return(balanced)
}

load_models <- function(model_type, model_dir) {
  setwd("~/GitHub/Twitch-Classifier/rdc/models")
  
  train_root <- "../data/train"
  test_root <- "../data/test"
  folders <- c("regular", "filtered")
  lengths <- c("500", "1000", "1500")
  shuffled <- c("_shuffled", "")
  
  model_list <- list()
  
  for (folder in folders) {
    for (shuffle in shuffled) {
      for (length in lengths) {
        key <- paste0(model_type, folder, length, shuffle)
        path <- file.path(model_dir, paste0(model_type, folder, length, shuffle, ".rds"))
        model_list[[key]] <- readRDS(path)
      }
    }
  }
  
  return(model_list)
}