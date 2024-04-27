

# set working path
setwd("D:/OneDrive/projects/Norway_project/src/simu_explicit/")

data_with_child <- read.csv(file.choose()) # data_with_child.csv
data_no_child <- read.csv(file.choose()) # data_without_child.csv

data <- data_with_child

data$deviation = data$norm_real