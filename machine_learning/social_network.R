
library(tidyverse)
library(scales)
library(class)

social_network <- read.csv("data/Social_Network_Ads.csv")

# 75% of the sample size
smp_size <- floor(0.75 * nrow(social_network))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(social_network)), size = smp_size)

# split into train test data
train <- social_network[train_ind, c("Age", "EstimatedSalary", "Purchased")]
test <- social_network[-train_ind, c("Age", "EstimatedSalary", "Purchased")]

# scale features
train <- train %>% mutate_at(vars(Age, EstimatedSalary), scale)
test <- test %>% mutate_at(vars(Age, EstimatedSalary), scale)

# run knn prediction
prediction <- knn(train, test, cl = train$Purchased, k = 3)

# confusion matrix
table(prediction, test$Purchased)

# plot results

train %>% 
  ggplot(aes(x = Age, y = EstimatedSalary, color = as.factor(Purchased))) +
  geom_point()

train %>%
  ggplot() + stat_contour(aes(x = Age, y = EstimatedSalary, ))
