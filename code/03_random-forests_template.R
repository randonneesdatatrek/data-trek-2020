#### Random Forests - Tutorial test ####

## Preparation ####
# Show a random forest representation
library(png)
img <- readPNG("./code/random-forests.png")
grid::grid.raster(img)

# Load required packages
library(randomForest) # main package for random forests
library(rpart) # package for single decision trees
library(caret) # only needed for one function in this case


## Prepare data
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
head(both_wine)
table(both_wine$type)
table(both_wine$quality)

## Decision Tree Example ####
set.seed(42)
decision_tree <- rpart(type ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree, xpd = NA)

set.seed(42)
decision_tree <- rpart(as.factor(quality) ~ ., data = both_wine)
plot(decision_tree)
text(decision_tree)


########

## Prepare training & validation sets ####
# Training set
train_inds <- sample(1:nrow(both_wine), 0.7*nrow(both_wine))
train_wine <- both_wine[train_inds,]
table(train_wine$type, train_wine$quality)

# Validation set
valid_wine <- both_wine[-train_inds,]
table(train_wine$type, train_wine$quality)
table(valid_wine$type, valid_wine$quality)


## Random Forest with default parameters
set.seed(42)
rf_type <- randomForest(type ~ ., data = train_wine, importance = TRUE)
rf_type

rf_type <- randomForest(type ~ ., data = train_wine, importance = TRUE,
                        xtest = valid_wine[,-type_ind], ytest = valid_wine$type)
rf_type

plot(rf_type)

# Variable importance
importance(rf_type)
varImpPlot(rf_type)

## Random forest on wine quality
set.seed(42)
rf_qual <- randomForest(quality ~ ., data = train_wine, importance = TRUE)
rf_qual

?randomForest

rf_qual_200 <- randomForest(quality ~ ., data = train_wine, importance = TRUE, ntree = 200)
rf_qual_200
rf_qual <- randomForest(quality ~ ., data = train_wine, importance = TRUE)
rf_qual
rf_qual_2000 <- randomForest(quality ~ ., data = train_wine, importance = TRUE, ntree = 2000)
rf_qual_2000



tuned_rf <- tuneRF(x = train_wine[,-quality_ind],
       y = train_wine$quality,
       mtryStart=3, stepFactor = 1.5, improve = 0.01,
       trace = TRUE, plot = TRUE)

varImpPlot(rf_qual)
