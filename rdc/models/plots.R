setwd("~/GitHub/Twitch-Classifier/rdc/models")

library(ggplot2)
library(patchwork)
library(grid)
library(gridExtra)
source("utils.R")

multinomial <- load_models("multinomial", "Multinomial")
lda <- load_models("lda", "LDA")
nb <- load_models("nb", "NB")
knn <- load_models("knn", "KNN")
svm <- load_models("svm", "SVM")
xgb <- load_models("xgb", "XGB")
rf <- load_models("rf", "RF")
nnet <- load_models("nnet", "NNET")

all_models <- list(
  multinomial,
  lda,
  nb,
  knn,
  svm,
  xgb,
  rf,
  nnet
)

names(all_models) <- c("Multinomial", "LDA", "NB", "KNN", "SVM", "XGB", "RF", "NNET")

metrics_map <- list(
  accuracy = "Accuracy",
  kappa = "Kappa",
  sensitivity = "Sensitivity",
  specificity = "Specificity",
  balanced_accuracy = "Balanced Accuracy"
)

for (i in seq_along(all_models)) {
  group_name <- names(all_models)[i]
  group_models <- all_models[[i]]
  model_names <- names(group_models)
  
  lengths <- c()
  models <- c()
  groups <- c()
  metrics <- c()
  values <- c()
  
  for (model_name in model_names) {
    model <- group_models[[model_name]]
    
    # Extract numeric length
    len <- as.numeric(gsub(".*?(\\d+).*", "\\1", model_name))
    
    # Assign group based on name
    if (grepl("filtered", model_name)) {
      group <- if (grepl("shuffled", model_name)) "Filtered & Shuffled" else "Filtered"
    } else {
      group <- if (grepl("shuffled", model_name)) "Regular & Shuffled" else "Regular"
    }
    
    metrics_list <- list(
      accuracy = model$mean_accuracy,
      kappa = model$mean_kappa,
      sensitivity = mean(model$mean_sensitivity),
      specificity = mean(model$mean_specificity),
      balanced_accuracy = mean(model$mean_balanced_accuracy)
    )
    
    for (metric_name in names(metrics_list)) {
      lengths <- c(lengths, len)
      models <- c(models, model_name)
      groups <- c(groups, group)
      metrics <- c(metrics, metric_name)
      values <- c(values, metrics_list[[metric_name]])
    }
  }
  
  plot_data <- data.frame(
    model = models,
    group = groups,
    length = lengths,
    metric = metrics,
    value = values,
    stringsAsFactors = FALSE
  )
  
  plots <- list()
  
  for (m in unique(plot_data$metric)) {
    df_subset <- plot_data[plot_data$metric == m, ]
    
    y_min <- max(min(df_subset$value) - 0.025, 0)
    
    p <- ggplot(df_subset, aes(x = length, y = value, color = group)) +
      geom_point(size = 3) +
      ylim(y_min, 1) +
      labs(
        title = paste(group_name, "-", metrics_map[[m]]),
        x = "Concatenation Length", 
        y = "Percentage",
        color = "Data Type"
      ) +
      theme_minimal() +
      theme(
        legend.position = "right",
        plot.title = element_text(hjust = 0.5)
      )
    
    plots[[m]] <- p
  }
  
  plot = wrap_plots(plots, ncol = 3)
  print(plot)
  ggsave(paste0("Plots/", paste0(group_name, "_Plots.png")), plot, width = 3840, height = 2160, units = "px", dpi = 300)
}