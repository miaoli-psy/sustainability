library(dplyr)
library(ggplot2)
library(gghalves)
library(tidyverse)
library(likert)
library(tidyr)
library(patchwork)


setwd("D:/OneDrive/projects/sustainability/src/analysis/")
# =====================normative========================================
data_normative <- readr::read_csv(file.choose()) # datanormatives.csv

data_acorss_participant <- data_normative %>% 
  group_by(action, norm_type) %>% 
  summarise(
    mean_response = mean(response),
    sd_response = sd(response),
    n = n(),
    .groups = 'drop'
  ) %>% 
  mutate(
    se_response = sd_response/sqrt(n),
    ci_response = se_response * qt(0.975, df = n - 1)
  )

plot_normative <- ggplot() +
  
  geom_half_violin(data = data_normative,
                   aes(x = action, 
                       y = response,
                       fill = norm_type),
                   position = position_dodge(0.4), 
                   alpha = 0.1, 
                   width =1, 
                   color = "white",
                   show.legend = TRUE) +
  

  geom_point(data = data_acorss_participant,
             aes(x = action,
                 y = mean_response,
                 group = norm_type,
                 fill = norm_type),
             position = position_dodge(0.4),
             alpha = 0.5,
             shape = 21, 
             size = 3, 
             stroke = 1,
             show.legend = TRUE) +
  
  
  geom_errorbar(data = data_acorss_participant, 
                aes(x = action,
                    y = mean_response,
                    ymin = mean_response - ci_response,
                    ymax = mean_response + ci_response,
                    group = norm_type),
                color = "black", 
                width = 0.1,
                position = position_dodge(0.4)) +
  
  labs(y = "Mean Rating", x = "Action") +
  
  scale_fill_manual(labels = c("family", "friends", "people"),
                    values = c("#0072B2", "#D55E00", "#009E73"))+
  
  scale_y_continuous(breaks = 1:7, limits = c(1, 7)) +
  
  theme(axis.title.x = element_text(color="black", size=14, face="bold"),
         axis.title.y = element_text(color="black", size=14, face="bold"),
         panel.border = element_blank(),  
         # remove panel grid lines
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         # remove panel background
         panel.background = element_blank(),
         # add axis line
         axis.line = element_line(colour = "grey"),
         # x,y axis tick labels
         axis.text.x = element_text(angle = 55, hjust = 1, size = 12, face = "bold"),
         axis.text.y = element_text(size = 12, face = "bold"),
         # legend size
         legend.title = element_text(size = 12, face = "bold"),
         legend.text = element_text(size = 10),
         # facet wrap title
         strip.text.x = element_text(size = 12, face = "bold"))

plot_normative

#ggsave(file = "normative.svg", plot = plot_normative, width = 12, height = 5, units = "in")


# ----------plot likert plot using likert package-------------


data_wide <- data_normative %>%
  mutate(response = as.numeric(response)) %>%
  filter(!is.na(response)) %>%
  select(participant, action, norm_type, response) %>%
  pivot_wider(
    names_from = action,
    values_from = response
  )


response_levels <- 1:7
response_labels <- c("Completely Disagree", "Disagree", "Somewhat Disagree",
                     "Neutral", "Somewhat Agree", "Agree", "Completely Agree")


# Family
items_family <- data_wide %>%
  filter(norm_type == "family") %>%
  select(-participant, -norm_type)


# covert from a tibble to classic data.frame --> what likert package need
items_family <- as.data.frame(items_family)

items_family[] <- lapply(items_family, factor, levels = response_levels, labels = response_labels)

likert_family <- likert::likert(items_family)

plot_family <- plot(likert_family, wrap = 50) + 
  labs(title = "Many of my family do the following actions to protect the environment.")+
  theme(axis.text.y = element_text(face = "bold", size = 14),
        plot.title = element_text(size = 14, face = "bold"))
plot_family


# Friends
items_friends <- data_wide %>%
  filter(norm_type == "friends") %>%
  select(-participant, -norm_type)

items_friends <- as.data.frame(items_friends)
items_friends[] <- lapply(items_friends, factor, levels = response_levels, labels = response_labels)

likert_friends <- likert::likert(items_friends)
plot_friends <- plot(likert_friends, wrap = 50) + 
  labs(title = "Many of my friends do the following actions to protect the environment.")+
  theme(axis.text.y = element_text(face = "bold", size = 14),
        plot.title = element_text(size = 14, face = "bold"))
plot_friends


# People
items_people <- data_wide %>%
  filter(norm_type == "people") %>%
  select(-participant, -norm_type)

items_people <- as.data.frame(items_people)
items_people[] <- lapply(items_people, factor, levels = response_levels, labels = response_labels)

likert_people <- likert::likert(items_people)
plot_people <- plot(likert_people, wrap = 50) + 
  labs(title = "To my knowledge, many people do the following actions to protect the environment.")+
  theme(axis.text.y = element_text(face = "bold", size = 14),
        plot.title = element_text(size = 14, face = "bold"))

plot_people


combined_plot <- plot_family / plot_friends / plot_people
combined_plot

# ggsave(file = "normative_likter.svg", plot = combined_plot, width = 10, height = 14, units = "in")

