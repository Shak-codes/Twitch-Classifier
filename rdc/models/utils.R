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