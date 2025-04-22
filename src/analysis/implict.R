library(readxl)
library(dplyr)
library(ggplot2)

setwd("D:/OneDrive/projects/sustainability/src/analysis/")

data <- readxl::read_excel(file.choose()) #ie_implicitdata.xlsx

#---------calculate percent correct (non-weighted)--------------
# extract action names from image paths
data <- data %>%
  mutate(
    actionA = gsub(".png", "", basename(imageA)),
    actionB = gsub(".png", "", basename(imageB))
  )

# list actions
actions <- unique(data$actionA)

# the one not in actionA
action_not_inA <- "recycling"

# iterate actionA, calcualte each percent correct for the action - then combine
# the df
actionA_im_non_weight_by_subject <- purrr::map_dfr(actions, function(action) {
  data %>%
    filter(actionA == action) %>%
    group_by(actionA, participant) %>%
    summarise(
      percent_correct = mean(if_resp_correct) * 100,
      .groups = 'drop'
    ) %>% 
    rename(action = actionA)
})

# percent correct for the other action - now, in col actionB
data_filter <- data %>% 
  filter(actionB == action_not_inA)

actionB_by_subject  <- data_filter %>% 
  group_by(participant, actionB) %>% 
  summarise(
    percent_correct = mean(if_resp_correct) * 100,
    .groups = 'drop'
  ) %>% 
  rename(action = actionB)

# get the non-weighted percent correct per action per participant
data_im_non_weight_by_subject <- bind_rows(actionA_im_non_weight_by_subject, actionB_by_subject)

# plot percent correct for each item
data_to_plot_across_subject <- data_im_non_weight_by_subject %>% 
  group_by(action) %>% 
  summarise(
    mean_percent_correct = mean(percent_correct),
    sd_percent_correct = sd(percent_correct),
    n = n()
  ) %>% 
  mutate(
    sem_percent_correct = sd_percent_correct/sqrt(n),
    ci_percent_correct = sem_percent_correct * qt((1 - 0.05) / 2 + .5, n - 1)
    
  )

data_to_plot_across_subject$action <- reorder(
  data_to_plot_across_subject$action,
  -data_to_plot_across_subject$mean_percent_correct
)

data_im_non_weight_by_subject$action <- reorder(
  data_im_non_weight_by_subject$action,
  -data_im_non_weight_by_subject$percent_correct
)


plot_percent_correct <- ggplot() +
  geom_bar(data = data_to_plot_across_subject, 
           aes(x = action, y = mean_percent_correct),
           stat = "identity", color = "black", fill = "white",
           alpha = 0.8) + 
  
  geom_errorbar(data = data_to_plot_across_subject, 
                aes(x = action,
                    y = mean_percent_correct,
                    ymin =  mean_percent_correct - ci_percent_correct,
                    ymax = mean_percent_correct + ci_percent_correct),
                
                color = "black",
                width = .00) +
  
  geom_point(data = data_im_non_weight_by_subject, 
             aes(x = action,
                 y = percent_correct,
                 color = as.factor(participant)),
             stat = "identity", alpha = 0.2, show.legend = FALSE) +
  
  geom_text(data = data_to_plot_across_subject,
            aes(x = action, y = mean_percent_correct, label = round(mean_percent_correct, 2)),
            vjust = -0.5, size = 4, fontface = "bold") +
  
  labs(y = "Percent Correct", x = "Action") +
  
  scale_x_discrete(labels = c(
    "green_energy" = "Green energy",
    "plant_based" = "Plant based",
    "e_car" = "E-car",
    "light_bulb" = "Light bulb",
    "laundry" = "Laundry",
    "hang_dry" = "Hang dry",
    "recycling" = "Recycling",
    "child" = "Child ",
    "car" = "Car ",
    "flight" = "Flight "
  )) +

  
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
        axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
        axis.text.y = element_text(size = 12, face = "bold"),
        # legend size
        legend.title = element_text(size = 12, face = "bold"),
        legend.text = element_text(size = 10),
        # facet wrap title
        strip.text.x = element_text(size = 12, face = "bold")) 
  
  
plot_percent_correct
