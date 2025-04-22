library(readxl)
library(dplyr)

library(ggplot2)

library(BradleyTerry2)

setwd("D:/OneDrive/projects/sustainability/src/analysis/")

data <- readxl::read_excel(file.choose()) #ie_implicitdata.xlsx

# extract action names from image paths
data <- data %>%
  mutate(
    actionA = gsub(".png", "", basename(imageA)),
    actionB = gsub(".png", "", basename(imageB))
  )
#---------calculate percent correct (non-weighted)--------------

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
  
  labs(y = "Percent Correct (%)", x = "Action") +
  
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

#---------Bradley-Terry model, for all data set, effect of the trial/task difficulty------

# add col chosen
data <- data %>% 
  mutate(
    chosen = ifelse(resp == "A", actionA, actionB)
  )

# compute difficulty: log of absolute difference in impact
# negative, very difficult (real impact scores between A and B are close)
# positive, low difficulty (real impact scores between A and B differ)

data <- data %>% 
  mutate(
    difficulty = log(abs(impactA - impactB) + 1e-6) # avoid -inf
  )


# get col names for BTm
data <- data %>% 
  rename(item1 = actionA,
         item2 = actionB)


bt_data <- data %>% 
  group_by(participant, item1, item2) %>% 
  summarise(
    wins1 = sum(chosen == item1),
    wins2 = sum(chosen == item2),
    n = n(),
    difficulty = mean(difficulty),
    .groups = "drop"
  )

# Ensure item1 and item2 are factors with the same levels
all_levels <- union(levels(factor(bt_data$item1)), levels(factor(bt_data$item2)))
bt_data$item1 <- factor(bt_data$item1, levels = all_levels)
bt_data$item2 <- factor(bt_data$item2, levels = all_levels)

# Create player1 and player2 as data frames with the 'difficulty' attached to item1 only
player1_df <- data.frame(items = bt_data$item1, difficulty = bt_data$difficulty)
player2_df <- data.frame(items = bt_data$item2, difficulty = 0)  # zero out to create a contrast

# Fit the model
bt_model <- BTm(
  outcome = cbind(bt_data$wins1, bt_data$wins2),
  player1 = player1_df,
  player2 = player2_df,
  formula = ~ difficulty,
  id = "items"
)

# As the difficulty increases (i.e., when the difference between the real impact scores of the two items gets larger), 
# participants are more likely to correctly choose the item with the higher real impact.
# larger difference → easier judgment → more accurate choice.
summary(bt_model) 


#---------Bradley-Terry model, each participant - effect of the trial/task difficulty----

participant_ids <- unique(bt_data$participant)

# Create a results container

# positive beta → participants tend to use real impact
results <- data.frame(
  participant = character(),
  beta_difficulty = numeric(),
  se = numeric(),
  p = numeric()
)

for (pid in participant_ids) {
  
  data_sub <- bt_data %>% filter(participant == pid)
  
  # Create item factor levels
  all_levels <- union(levels(factor(data_sub$item1)), levels(factor(data_sub$item2)))
  data_sub$item1 <- factor(data_sub$item1, levels = all_levels)
  data_sub$item2 <- factor(data_sub$item2, levels = all_levels)
  
  # Set up player1/player2 with asymmetric difficulty
  player1_df <- data.frame(items = data_sub$item1, difficulty = data_sub$difficulty)
  player2_df <- data.frame(items = data_sub$item2, difficulty = 0)
  
  # Try fitting the model, catch errors
  try({
    bt_model <- BTm(
      outcome = cbind(data_sub$wins1, data_sub$wins2),
      player1 = player1_df,
      player2 = player2_df,
      formula = ~ difficulty,
      id = "items"
    )
    
    summary_bt <- summary(bt_model)
    beta <- summary_bt$coefficients["difficulty", "Estimate"]
    se <- summary_bt$coefficients["difficulty", "Std. Error"]
    p <- summary_bt$coefficients["difficulty", "Pr(>|z|)"]
    
    results <- rbind(results, data.frame(
      participant = pid,
      beta_difficulty = beta,
      se = se,
      p = p
    ))
  }, silent = TRUE)
}

#-------classic BT model over entire dataset - estimate the ability(strength) of each item---
# Ensure item1 and item2 are factors with the same levels
all_levels <- union(levels(factor(bt_data$item1)), levels(factor(bt_data$item2)))
bt_data$item1 <- factor(bt_data$item1, levels = all_levels)
bt_data$item2 <- factor(bt_data$item2, levels = all_levels)

bt_model <- BTm(
  outcome = cbind(bt_data$wins1, bt_data$wins2),
  player1 = bt_data$item1,
  player2 = bt_data$item2,
  id = "items"
)

summary(bt_model)

# Extract item ability estimates
coefs <- coef(bt_model)

# coefficients and convert to odds
odds <- exp(coef(bt_model))
odds

# to probabilities
probabilities <- odds / (1 + odds)
probabilities

scores <- probabilities * 100
scores['car'] <- 50

scores

# rank scores, higher to lower 10 to 1 (if reverse, use -scores)
# Using a Bradley-Terry model, we derived a rank order of actions based on the 
# frequency with which each was chosen as more impactful. 
# This reflects participants' implicit beliefs about climate action efficacy. 
# The results show a divergence from actual impact rankings, 
# suggesting systematic over- and underestimation of certain behaviors
bt_ranks <- rank(scores) 
bt_ranks



