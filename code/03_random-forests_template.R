#### Random Forests - Live coding tutorial ####

## Preparation ####

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

###########

## Data visualisation ####
# Preview data


# Preview classes distribution


## Decision Tree Example ####
# Decision Tree for wine type
set.seed(42)
decision_tree <- rpart(type ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree, xpd = NA)

# Representation of a forest
library(png)
img <- readPNG("./code/random-forests.png")
grid::grid.raster(img)

# Decision Tree for wine quality
set.seed(42)
decision_tree <- rpart(as.factor(quality) ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree)

###########

## Prepare training & validation sets ####
# Training set
set.seed(42)
train_inds <- sample(1:nrow(both_wine), 0.7*nrow(both_wine))


# Validation set


#######

#### Random Forests ####

## Predict wine type with default parameters ####
# Simplest way



# Plot the model



# Variable importance



# Plot type as function of best parameters



## Predict wine quality ####
# Simplest way


## Tune model
# 1. Change mtry



# 2. Change ntree





# Check quality variable importance








########

## Acknowledgments:
# Awesome resources who inspired this tutorial, check them out!:
#   - https://uc-r.github.io/random_forests
#   - https://koalaverse.github.io/machine-learning-in-R/random-forest.html
#   - https://www.blopig.com/blog/2017/04/a-very-basic-introduction-to-random-forests-using-r/
#   - https://towardsdatascience.com/understanding-auc-roc-curve-68b2303cc9c5
