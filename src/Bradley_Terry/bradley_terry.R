# install.packages("BradleyTerry2", repos="http://cran.r-project.org")

library(BradleyTerry2)


# set working path
setwd("D:/OneDrive/projects/Norway_project/src/Bradley_Terry/")

data <- read.csv(file.choose()) #simu_res_1p.csv

all_trials <- unique(c(data$trial1, data$trial2))
data$trial1 <- factor(data$trial1, levels = all_trials)
data$trial2 <- factor(data$trial2, levels = all_trials)

str(data)

bt_model <- BTm(cbind(wins1, wins2), trial1, trial2, id = "items", data = data)

# model coef
coef(bt_model)

summary(bt_model)

# Model diagnostics
plot(bt_model)

# coefficients and convert to odds
odds <- exp(coef(bt_model))
odds

# to probabilities
probabilities <- odds / (1 + odds)
probabilities

# normalize scores (e.g., scale:0-100)
# first item 'A' has log(1) = 0 -> p = 0.5
scores <- probabilities * 100
scores['trialsA'] <- 50

scores

# rank scores, higher to lower 10 to 1 (if reverse, use -scores)
bt_ranks <- rank(scores) 
bt_ranks
