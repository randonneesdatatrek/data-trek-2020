######## Random Forests - Live coding tutorial ########

#### 1. Preparation ####

# Load required packages
library(randomForest) # main package for random forests
library(rpart) # package for single decision trees
library(caret) # only needed for one function in this case

# Load datasets
red_dataset <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv", sep = ";")
white_dataset <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv", sep = ";")

# Create working dataframes
red_wine <- red_dataset
white_wine <- white_dataset

# Add wine type
red_wine$type <- factor("red")
white_wine$type <- factor("white")
# Extract index of wine type
type_ind <- which(names(white_wine) == "type")

# Join datasets
both_wine <- rbind(red_wine, white_wine)

# Backup dataframe with quality as numeric
both_wine_numeric <-both_wine
# Convert quality to factor
both_wine$quality <- as.factor(both_wine$quality)
# Extract index of wine quality
quality_ind <- which(names(both_wine) == "quality")


#### 2. Data visualisation ####
# Preview data
head(both_wine)

# Preview classes distribution
table(both_wine$type)
table(both_wine$quality)


#### 3. Decision Tree Example ####
# Decision Tree for wine type
set.seed(42)
decision_tree <- rpart(type ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree, xpd = NA)

# Decision Tree for wine quality
set.seed(42)
decision_tree <- rpart(as.factor(quality) ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree)


#### 4. Prepare training & validation sets ####
# Training set
set.seed(42)
train_inds <- sample(1:nrow(both_wine), 0.7*nrow(both_wine))
train_wine <- both_wine[train_inds,]
table(train_wine$type, train_wine$quality)

# Validation set
valid_wine <- both_wine[-train_inds,]
table(train_wine$type, train_wine$quality)
table(valid_wine$type, valid_wine$quality)

######## Random Forests ########

#### 5. Predict wine type with default parameters ####
# Simplest way
set.seed(42)
rf_type <- randomForest(type ~ ., data = train_wine, importance = TRUE)
rf_type

# With validation dataset
set.seed(42)
rf_type_test <- randomForest(type ~ ., data = train_wine, importance = TRUE,
                        xtest = valid_wine[,-type_ind], ytest = valid_wine$type)
rf_type_test

# Plot the model
plot(rf_type) # black line is overall error rate, red line is red wine, green line is white wine

# Variable importance
importance(rf_type)
varImpPlot(rf_type)

# Plot type as function of best parameters
plot(type ~ chlorides, data = both_wine)
plot(type ~ total.sulfur.dioxide, data = both_wine)


#### 6. Predict wine quality ####
# Simplest way
set.seed(42)
rf_qual <- randomForest(quality ~ ., data = train_wine, importance = TRUE)
rf_qual

# Check variable importance for wine quality
varImpPlot(rf_qual)

# Check possible parameters to tune model
?randomForest

## Tune model
# 1. Change ntree
ntrees <- c(200, 500, 2000)
tuned_ntrees <- list(rf200 = NULL, rf500 = NULL, rf2000 = NULL)
for (i in 1:length(ntrees)) {
  set.seed(42)
  tuned_ntrees[[i]] <- randomForest(quality ~ ., data = train_wine, importance = TRUE, ntree = ntrees[i],
                                    xtest = valid_wine[,-quality_ind], ytest = valid_wine$quality, mtry = 2)
}

# Check error rate stability with number of trees
plot(tuned_ntrees$rf2000$err.rate[,"OOB"], type = "l", 
     xlab = "ntree", ylab = "OOB error rate", )
plot(tuned_ntrees$rf500$err.rate[,"OOB"], type = "l", 
     xlab = "ntree", ylab = "OOB error rate", )
plot(tuned_ntrees$rf200$err.rate[,"OOB"], type = "l", 
     xlab = "ntree", ylab = "OOB error rate", )

# 2. Change mtry
set.seed(42)
tuned_rf <- tuneRF(x = train_wine[,-quality_ind],
       y = train_wine$quality,
       mtryStart=3, stepFactor = 1.5, improve = 0.01,
       trace = TRUE, plot = TRUE)

## Check quality variable importance
varImpPlot(rf_qual)


######## Supplementary material ########

# S1. Regression analysis using randomForest
# S2. Random forests using package "ranger" (faster than randomFore)

#### S1. Modeling wine quality - Random Forest (regression analysis) ####

## Random forest with default parameters
set.seed(42)
rf_qual_reg <- randomForest(quality ~ ., data = both_wine_numeric, importance=TRUE) 
rf_qual_reg

# Tune model
# mtry <- tuneRF(x = both_wine_numeric[,-quality_ind], 
#                y = both_wine_numeric$quality,
#                ntreeTry=500, mtryStart = 5,stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE)


## Verify model accuracy with predicted values as integers
# Extract OOB testing and predicted values from model
testing_qual_reg <- rf_qual_reg$y
predicted_qual_reg <- rf_qual_reg$predicted

## Function to rearrange numeric predictions to integers as in
## Cortez et al. 2009 (https://doi.org/10.1016/j.dss.2009.05.016) 
## (article in which the data was published)
## (they used a tolerance range on the predicted values from regression models)

# Tolerance range is used to determine if predicted value is correct
rf_reg_accuracy <- function(testing_set, predicted_set, tolerance){ # Wrapped in a function
  
  # Loop for all predicted values
  for(j in 1:length(predicted_set)){
    
    # Conditional operators to determine if predicted value is within tolerance
    # range of real value
    if(abs(predicted_set[j]-testing_set[j]) < tolerance) {
      # if TRUE, predicted value is within tolerance range and considered
      # correct; # hence, real value is selected
      predicted_set[j] <- testing_set[j]
    } else {
      # if FALSE, predicted value is incorrect; hence, predicted value is simply
      # rounded to closest integer
      predicted_set[j] <- round(predicted_set[j], digits = 0)
    }
    
  }
  # Define datasets as factors with same levels (warnings if not)
  testing_set <- as.factor(testing_set)
  predicted_set <- factor(predicted_set,
                               levels = levels(testing_set))
  # Check confusion matrix of predicted values
  print(confusionMatrix(predicted_set, testing_set))
}

# Verify model accuracy
rf_reg_accuracy(testing_qual_reg, predicted_qual_reg, tolerance = 0.5) # accuracy = 0.700, similar to classification
rf_reg_accuracy(testing_qual_reg, predicted_qual_reg, tolerance = 1.0) # accuracy = 0.913

## Evaluate variable importance
# Show values
importance(rf_qual_reg)

# Plot importance values
varImpPlot(rf_qual_reg) # alcohol is the best predictor

#### S2. Random Forests using package "ranger" ####

# ranger is an alternative package to perform random forests models, much faster than the default one
# It functions in a similiar way, and is especially useful to test multiple parameter combinations given its speed

library(ranger)
# time models
system.time(rf_qual <- randomForest(as.factor(quality) ~ ., data = train_wine))
system.time(ranger_qual <- ranger(as.factor(quality) ~ ., data = train_wine, importance = "impurity"))

## Fine tuning
# Hyperparameter grid search (test multiple parameter combinations)
hyper_grid <- expand.grid(
  mtry       = seq(2, 6, by = 1),
  node_size  = seq(1, 5, by = 1),
  sampe_size = c(.55, .632, .70),
  OOB   = 0
)

# Total number of combinations
nrow(hyper_grid)

# Run all models
system.time(
  for(i in 1:nrow(hyper_grid)) {
    
    # train model
    model <- ranger(formula = as.factor(quality) ~ ., 
                    data = train_wine, 
                    num.trees = 500,
                    mtry = hyper_grid$mtry[i],
                    min.node.size = hyper_grid$node_size[i],
                    sample.fraction = hyper_grid$sampe_size[i],
                    importance = "impurity",
                    seed = 42
    )
    
    # add OOB error to grid
    hyper_grid$OOB[i] <- model$prediction.error
  }
)

# Check results
hyper_grid



#### Acknowledgments: ####
# Awesome resources who inspired this tutorial, check them out!:
#   - https://uc-r.github.io/random_forests
#   - https://koalaverse.github.io/machine-learning-in-R/random-forest.html
#   - https://www.blopig.com/blog/2017/04/a-very-basic-introduction-to-random-forests-using-r/
#   - https://towardsdatascience.com/understanding-auc-roc-curve-68b2303cc9c5
