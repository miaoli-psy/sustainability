library(dplyr)
library(ggplot2)

setwd("D:/OneDrive/projects/sustainability/src/analysis/")

data_ex <- readr::read_csv(file.choose()) #explicitdata_nochild.csv or explicitdata.csv



# Compute group mean for each action
group_means <- data_ex %>%
  group_by(action) %>%
  summarise(
    mean_deviation = mean(deviation),
    sd_deviaiton = sd(deviation),
    n = n(),
    .groups = 'drop'
  ) %>% 
  mutate(
    sem_deviation = sd_deviaiton/sqrt(n),
    ci_deviaiton = sem_deviation * qt(0.975, df = n - 1)
  )


# Plot deviation = normalized measured  score - normalized real impact score

plot_deviation <- ggplot() +
  geom_point(
    data = group_means,
    aes(
      x = action,
      y = mean_deviation
    ),
    size = 4,
    stroke = 1.5,
    alpha = 0.5
  ) +
  
  geom_errorbar(
    data = group_means,
    aes(
      x = action,
      y = mean_deviation,
      ymin = mean_deviation - ci_deviaiton,
      ymax = mean_deviation + ci_deviaiton,
    ),
    linewidth  = 0.8,
    width = .00,
    alpha = 0.8,
  ) +
  
  geom_point(
    data = data_ex,
    aes(
      x = action,
      y = deviation,
      group = as.factor(participant),
      color = as.factor(participant)
    ),
    size = 2,
    alpha = 0.5
  ) +
  
  scale_y_continuous(limits = c(-1.1, 1.1)) +
  
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  
  labs(y = "Deviation (normalized measure - normalized real )", x = "Actions") +
  
  theme(
    axis.title.x = element_text(
      color = "black",
      size = 14,
      face = "bold"
    ),
    axis.title.y = element_text(
      color = "black",
      size = 14,
      face = "bold"
    ),
    panel.border = element_blank(),
    # remove panel grid lines
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    # remove panel background
    panel.background = element_blank(),
    # add axis line
    axis.line = element_line(colour = "grey"),
    # x,y axis tick labels
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold"),
    # legend size
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    # facet wrap title
    strip.text.x = element_text(size = 12, face = "bold"),
    panel.spacing = unit(1.0, "lines")
  ) 


plot_deviation


# group level correlation per action mean


data_across_subject <- data_ex %>%
  group_by(action) %>%
  summarise(
    n = n(),
    mean_measured = mean(normalized_measured),
    se = sd(normalized_measured) / sqrt(n),
    lower = mean_measured - qt(0.975, df = n() - 1) * se,
    upper = mean_measured + qt(0.975, df = n() - 1) * se,
    real_impact = mean(normalized_real_impact),
    .groups = "drop"
  )

data_across_subject$action <- gsub("images/|\\.png", "", data_across_subject$action)


# corr explicited measure score and real impact
cor_test <-cor.test(data_across_subject$mean_measured, data_across_subject$real_impact, method = 'spearman')
cor_test


plot_grouplevel_corr <- ggplot() +
  
  geom_point(data = data_across_subject,
             aes(
               x = mean_measured,
               y = real_impact,
               color = action,
               size = 0.4
             ),
             alpha = 0.5,
             show.legend = FALSE) +
  
  # geom_smooth(data = data_across_subject,
  #             aes(
  #               x = mean_measured,
  #               y = real_impact
  #             ),
  #             method = 'lm',
  #             se = FALSE,
  #             color = "blue",
  #             linetype = 'dashed',
  #             alpha = 0.5
  # ) +
  
  annotate("text", x = 0.1, 
           y = 0.95, 
           label = paste0("Spearman ρ = ", round(cor_test$estimate, 2)), 
           size = 5, 
           fontface = "bold") +
  
  geom_errorbarh(data = data_across_subject,
                 aes(y = real_impact,
                     x = mean_measured,
                     xmin = lower, 
                     xmax = upper,
                     color = action), 
                 height = 0.00,
                 alpha = 0.5,
                 size = 0.8,
                 show.legend = FALSE
  ) +
  
  geom_text(data = data_across_subject,
            aes(
              x = mean_measured,
              y = real_impact,
              label = action),
            nudge_x = 0,
            size = 4) +
  
  geom_abline(intercept = 0, slope = 1, linetype = "dotted", color = "black") +
  
  scale_x_continuous(limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1)) +
  
  labs(x = "Normalized Perceived Impact",
       y = "Normalized Real Impact",
       title = "Explicit Task") +
  
  theme(
    axis.title.x = element_text(color = "black", size = 14, face = "bold"),
    axis.title.y = element_text(color = "black", size = 14, face = "bold"),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.line = element_line(colour = "grey"),
    axis.text.x = element_text(angle = 0, hjust = 1, size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold"),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    strip.text.x = element_text(size = 12, face = "bold"),
    panel.spacing = unit(1.0, "lines")
  )

plot_grouplevel_corr

