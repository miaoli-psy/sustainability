library(dplyr)
library(ggplot2)

setwd("D:/OneDrive/projects/sustainability/src/analysis/")

data <- readxl::read_excel(file.choose()) #ie_explicitdata_no_child.xlsx



# Compute group mean for each action
group_means <- data %>%
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
    size  = 0.8,
    width = .00,
    alpha = 0.8,
  ) +
  
  geom_point(
    data = data,
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
