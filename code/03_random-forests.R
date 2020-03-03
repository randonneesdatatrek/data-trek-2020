## Acknowledgments:
# Awesome resources who inspired this tutorial, check them out!:
# https://uc-r.github.io/random_forests
# https://koalaverse.github.io/machine-learning-in-R/random-forest.html

## Preparation

# Load required packages
library(randomForest)

# Load datasets
red_dataset <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv", sep = ";")
white_dataset <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv", sep = ";")

# Creating working dataframe
red_wine <- red_dataset
white_wine <- white_dataset

head(red_wine)
head(white_wine)

## Arrange dataset
# Add type
red_wine$type <- factor("red")
head(red_wine)
white_wine$type <- factor("white")
head(white_wine)

# Join datasets
both_wine <- rbind(red_wine, white_wine)
head(both_wine)
tail(both_wine)

# Set quality as factors
# red_df <- red_wine
# white_df <- white_wine
# both_df <- both_wine
# 
# red_df$quality <- as.factor(red_wine$quality)
# white_df$quality <- as.factor(white_wine$quality)
# both_df$quality  <- as.factor(both_wine$quality)

## Decision Tree Example
library(rpart)

set.seed(42)
decision_tree <- rpart(type ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree)

set.seed(42)
decision_tree <- rpart(as.factor(quality) ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree)

barplot(table(as.factor(both_wine$quality)))

#### Modelling wine type - Random Forest ####

### Prep the data

train_inds <- sample(1:nrow(both_wine), 0.7*nrow(both_wine))
train_wine <- both_wine[train_inds,]
table(train_wine$type, train_wine$quality)
valid_wine <- both_wine[-train_inds,]
table(train_wine$type, train_wine$quality)
table(valid_wine$type, valid_wine$quality)

## Random Forest with default parameters
set.seed(42)
rf_type <- randomForest(type ~ ., data = train_wine, importance = TRUE) 
rf_type

pred_type <- predict(rf_type, valid_wine)
confusionMatrix(pred_type, valid_wine$type)

## Evaluate variable importance
# Show values
importance(rf_type)

# Plot importance values
windows()
varImpPlot(rf_type) # total.sulfur.dioxides & chlorides are clearly the best

# Plot type as function of best parameters
plot(type ~ chlorides, data = both_wine)
plot(type ~ total.sulfur.dioxide, data = both_wine)

#### Modeling wine quality - Random Forest (classification analysis) ####

### Tune model 

## 1. Model with default parameters
set.seed(42)
rf_qual <- randomForest(as.factor(quality) ~ ., data = both_wine)
rf_qual
# default ntree = 500
# default mtry = 3
# OOB error rate = 28.52%%

## 2. Choose ntree value (where OOB error rate stabilizes at minimum)

# Test model with ntree = 2000, 1000, and 600
set.seed(42)
rf_qual_2000 <- randomForest(as.factor(quality) ~ ., data = both_wine, ntree = 2000)
set.seed(42)
rf_qual_1000 <- randomForest(as.factor(quality) ~ ., data = both_wine, ntree = 1000)
set.seed(42)
rf_qual_600 <- randomForest(as.factor(quality) ~ ., data = both_wine, ntree = 600)

# Plot error rate ~ ntree

par(mfrow=c(2,2))
plot(rf_qual_2000$err.rate[,"OOB"], type = "l", xlab = "ntree",
     ylab = "OOB error rate")
mtext("a)", line = 0.5, adj = 0)
plot(rf_qual_1000$err.rate[,"OOB"], type = "l", xlab = "ntree",
     ylab = "OOB error rate")
mtext("b)", line = 0.5, adj = 0)
plot(rf_qual_600$err.rate[,"OOB"], type = "l", xlab = "ntree",
     ylab = "OOB error rate")
mtext("c)", line = 0.5, adj = 0)
par(mfrow=c(1,1))
# stabilizes around n=500, same as default value. Let's select it

## 3. Find optimal mtry value
set.seed(42)
mtry <- tuneRF(both_wine[-which(names(both_wine)=="quality")],as.factor(both_wine$quality),
               ntreeTry=500, mtryStart = 5,stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE)
# Plot mtry values
mtry
mtext("d)", line = 0.5, adj = 0)
# Best mtry = 3, same as default

#### Modeling wine quality - Random Forest (regression analysis) ####

## Random forest with default parameters
set.seed(42)
rf_qual_reg <- randomForest(quality ~ ., data = both_wine, importance=TRUE) 
rf_qual_reg
# default ntree = 500
# default mtry = 4
# Mean of squared residuals = 0.339
# % Var explained = 55.55

## Verify model accuracy with predicted values as integers
# Extract OOB testing and predicted values from model
testing_qual_reg <- rf_qual_reg$y
predicted_qual_reg <- rf_qual_reg$predicted

## Function to rearrange numeric predictions to integers as in
## Cortez et al. 2009
# Tolerance range is used to determine if predicted value is correct
rf_reg_accuracy <- function(tolerance){ # Wrapped in a function
  
  # Loop for all predicted values
  for(j in 1:length(predicted_qual_reg)){
    
    # Conditional operators to determine if predicted value is within tolerance
    # range of real value
    if(abs(predicted_qual_reg[j]-testing_qual_reg[j]) < tolerance) {
      # if TRUE, predicted value is within tolerance range and considered
      # correct; # hence, real value is selected
      predicted_qual_reg[j] <- testing_qual_reg[j]
    } else {
      # if FALSE, predicted value is incorrect; hence, predicted value is simply
      # rounded to closest integer
      predicted_qual_reg[j] <- round(predicted_qual_reg[j], digits = 0)
    }
    
  }
  # Define datasets as factors with same levels (warnings if not)
  testing_qual_reg <- as.factor(testing_qual_reg)
  predicted_qual_reg <- factor(predicted_qual_reg,
                               levels = levels(testing_qual_reg))
  # Check confusion matrix of predicted values
  print(confusionMatrix(predicted_qual_reg, testing_qual_reg))
}

# Verify model accuracy
library(caret)
rf_reg_accuracy(tolerance = 0.5) # accuracy = 0.700, similar to classification
rf_reg_accuracy(tolerance = 1.0) # accuracy = 0.913

## Evaluate variable importance
# Show values
importance(rf_qual_reg)

# Plot importance values
varImpPlot(rf_qual_reg, main = NULL) # alcohol is the best predictor


#### Party ####
library(party)
rf <- cforest(as.factor(quality) ~ .,
              data = train_wine,
              control = cforest_unbiased(mtry = 2, ntree = 500))

(vars_imp <- varimp(rf, conditional = T))
(vars_imp <- varimp(rf))

pred_wine <- predict(rf, valid_wine, OOB=TRUE)

confusionMatrix(pred_wine, as.factor(train_wine$quality))
