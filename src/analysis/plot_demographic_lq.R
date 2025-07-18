library(dplyr)
library(ggplot2)
library(tidyverse)


setwd("D:/OneDrive/projects/sustainability/src/analysis/")

# =====================demograpic task========================================
data_dmgrphc <- readr::read_csv(file.choose()) #data_demographic_lq.csv

# Set theme

theme <- theme(axis.title.x = element_text(color="black", size=14, face="bold"),
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
               axis.text.x = element_text(size = 12, face = "bold"),
               axis.text.y = element_text(size = 12, face = "bold"),
               # legend size
               legend.title = element_text(size = 12, face = "bold"),
               legend.text = element_text(size = 10),
               # facet wrap title
               strip.text.x = element_text(size = 12, face = "bold"))

# Sex
data_sex <- data_dmgrphc %>% 
  group_by(sex) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )

sex_colors <- c("Female" = "#D55E00", "Male" = "#0072B2")

plot_sex <- ggplot() +
  geom_bar(data = data_sex,
           aes(
             x = "",
             y = percentage,
             fill = sex
           ),
           stat = "identity",
           position = "stack", 
           alpha = 0.3,
           show.legend = FALSE) +

  geom_text(data = data_sex,
            aes(x = "", y = percentage, label = sprintf("%.1f%%", percentage)),
            position = position_stack(vjust = 0.4)) +

  geom_text(data = data_sex,
            aes(x = "", y = percentage, label = sex),
            position = position_stack(vjust = 0.6),
            fontface = "bold") + 
  
  labs(y = "Percentage (%)", x = "Sex") + 
  
  scale_fill_manual(labels = c("Female", "Male"),
                     values = c("#D55E00", "#0072B2")
                     ) +
  theme 
  
  
plot_sex

# ggsave(file = "sex.svg", plot = plot_sex, width = 2, height = 5, units = "in")


# sexual_orientation
data_sexual_orientation <- data_dmgrphc %>% 
  group_by(sexual_orientation) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )

plot_sexual_orientation<- ggplot() +
  geom_bar(data = data_sexual_orientation,
           aes(
             x = sexual_orientation,
             y = percentage,
             fill = sexual_orientation
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_sexual_orientation,
            aes(x = sexual_orientation, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Sexual Orientation") + 
  
  # scale_fill_manual(labels = c("Female", "Male"),
  #                   values = c("#D55E00", "#0072B2")
  # ) +
  theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"))

plot_sexual_orientation

# ggsave(file = "sexual_orientation.svg", plot = plot_sexual_orientation, width = 4.5, height = 5, units = "in")


# age
data_age <- data_dmgrphc %>% 
  group_by(age) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )


plot_age<- ggplot() +
  geom_bar(data = data_age,
           aes(
             x = age,
             y = percentage,
             fill = age
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_age,
            aes(x = age, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Age") + 
  
  theme +
  
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"))

plot_age

# ggsave(file = "age.svg", plot = plot_age, width = 6.5, height = 5, units = "in")



# education

data_education <- data_dmgrphc %>% 
  group_by(education) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )


plot_education<- ggplot() +
  geom_bar(data = data_education,
           aes(
             x = education,
             y = percentage,
             fill = education
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_education,
            aes(x = education, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Education") + 
  
  theme +
  
  theme(axis.text.x = element_text(angle = 55, hjust = 1, size = 12, face = "bold"))

plot_education

# ggsave(file = "education.svg", plot = plot_education, width = 5, height = 5, units = "in")


# race

data_race <- data_dmgrphc %>% 
  group_by(race) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )

race_order <- c("African American", "Asian", "Hispanic", "Native American", "White/Caucasian", "Other")

data_race$race <- factor(data_race$race, levels = race_order)



plot_race<- ggplot() +
  geom_bar(data = data_race,
           aes(
             x = race,
             y = percentage,
             fill = race
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_race,
            aes(x = race, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Race") + 
  
  theme +
  
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"))

plot_race

# ggsave(file = "race.svg", plot = plot_race, width = 5, height = 5, units = "in")


# employment_status

data_employment_status <- data_dmgrphc %>% 
  group_by(employment_status) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )

employment_status_order <- c("Full-Time", "Not in paid work", "Part-Time", "Starting new job soon", "Unemployed (job seeking)", "Other")

data_employment_status$employment_status <- factor(data_employment_status$employment_status, levels = employment_status_order)


plot_employment_status<- ggplot() +
  geom_bar(data = data_employment_status,
           aes(
             x = employment_status,
             y = percentage,
             fill = employment_status
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_employment_status,
            aes(x = employment_status, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Employment Status") + 
  
  theme +
  
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"))

plot_employment_status

# ggsave(file = "employment_status.svg", plot = plot_employment_status, width = 5, height = 5, units = "in")


# diet

data_diet <- data_dmgrphc %>% 
  group_by(diet) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )


plot_diet<- ggplot() +
  geom_bar(data = data_diet,
           aes(
             x = diet,
             y = percentage,
             fill = diet
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_diet,
            aes(x = diet, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Diet") + 
  
  theme +
  
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"))

plot_diet

# ggsave(file = "diet.svg", plot = plot_diet, width = 4.5, height = 5, units = "in")

# air_travel_freq


data_air_travel_freq <- data_dmgrphc %>% 
  group_by(air_travel_freq) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )


plot_air_travel_freq<- ggplot() +
  geom_bar(data = data_air_travel_freq,
           aes(
             x = air_travel_freq,
             y = percentage,
             fill = air_travel_freq
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_air_travel_freq,
            aes(x = air_travel_freq, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Air travel frequency per year") + 
  
  theme +
  
  scale_x_discrete(
    labels = c(
      "Flights: 0" = "0",
      "Flights: 1-2" = "1-2",
      "Flights: 3-4" = "3-4",
      "Flights: 4-5" = "4-5",
      "Flights: 6+" = "6+"
    )
  )

plot_air_travel_freq

# ggsave(file = "air_travel.svg", plot = plot_air_travel_freq, width = 4.5, height = 5, units = "in")

# num_children

data_num_children <- data_dmgrphc %>% 
  group_by(num_children) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )


plot_num_children<- ggplot() +
  geom_bar(data = data_num_children,
           aes(
             x = as.factor(num_children),
             y = percentage,
             fill = num_children
           ),
           stat = "identity",
           alpha = 0.4,
           show.legend = FALSE) +
  
  geom_text(data = data_num_children,
            aes(x = as.factor(num_children), y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Children Number") + 
  
  theme 
  

plot_num_children

# ggsave(file = "num_children.svg", plot = plot_num_children, width = 5, height = 5, units = "in")

# car_ownership


data_car_ownership <- data_dmgrphc %>% 
  group_by(car_ownership) %>% 
  summarise(
    n = n(),
    percentage = round(n() / nrow(data_dmgrphc) * 100, 2)
  )


plot_car_ownership<- ggplot() +
  geom_bar(data = data_car_ownership,
           aes(
             x = car_ownership,
             y = percentage,
             fill = car_ownership
           ),
           stat = "identity",
           alpha = 0.3,
           show.legend = FALSE) +
  
  geom_text(data = data_car_ownership,
            aes(x = car_ownership, y = percentage, label = sprintf("%.1f%%", percentage)),
            vjust = -0.5,
            fontface = "bold") + 
  
  
  labs(y = "Percentage (%)", x = "Car Ownership") + 
  
  theme +
  
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"))
  

plot_car_ownership

# ggsave(file = "car_ownership.svg", plot = plot_car_ownership, width = 5, height = 5, units = "in")
