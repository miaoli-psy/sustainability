# install.packages("irr")
library(irr)

# set working path
setwd("D:/OneDrive/projects/Norway_project/src/Bradley_Terry/")

data <- read.csv(file.choose()) #simu_data_1p.csv

data$trial_n <- as.factor(data$trial_n) 

data_wide <- reshape(data, 
                     timevar = "trial_n", 
                     idvar = c("item1", "item2"),
                     direction = "wide")


names(data_wide) <- gsub("choice.", "", names(data_wide))

kappa_12 <- irr::kappa2(data_wide[, c("1", "2")])
kappa_23 <- irr::kappa2(data_wide[, c("2", "3")])
kappa_13 <- irr::kappa2(data_wide[, c("1", "3")])

average_kappa <- (kappa_12$value + kappa_23$value + kappa_13$value) / 3
average_kappa
