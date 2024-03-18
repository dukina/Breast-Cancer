# Load required libraries
library(mlbench)
library(ggplot2)
library(rpart)
library(klaR)
library(nnet)
library(randomForest)
library(caret)

# Load dataset
data(BreastCancer)
BreastCancer <- na.omit(BreastCancer)
BreastCancer$Id <- NULL

# Exploratory Data Analysis
ggplot(BreastCancer, aes(x = Class, fill = Class)) +
  geom_bar() +
  labs(title = "Class Distribution", x = "Class", y = "Frequency")

ggplot(BreastCancer, aes(x = Cl.thickness, y = Cell.size, color = Class)) +
  geom_point() +
  labs(title = "Scatter plot of Cl.thickness vs Cell.size", x = "Cl.thickness", y = "Cell.size", color = "Class")

ggplot(BreastCancer, aes(x = Class, y = Cell.shape, fill = Class)) +
  geom_boxplot() +
  labs(title = "Box plot of Cell.shape by Class", x = "Class", y = "Cell.shape")

# Model Training
classifier_rpart <- rpart(Class ~ ., data = BreastCancer)
classifier_nb <- NaiveBayes(Class ~ ., data = BreastCancer)
classifier_nnet <- nnet(Class ~ ., data = BreastCancer, size = 1)
classifier_lda <- lda(Class ~ ., data = BreastCancer)
classifier_rf <- randomForest(Class ~ ., data = BreastCancer)

# Ensemble Classification
pred_rpart <- suppressWarnings(try(predict(classifier_rpart, newdata = BreastCancer, type = "class"), silent = TRUE))
pred_nb <- suppressWarnings(try(predict(classifier_nb, newdata = BreastCancer), silent = TRUE))
pred_nnet <- suppressWarnings(try(predict(classifier_nnet, newdata = BreastCancer, type = "class"), silent = TRUE))
pred_lda <- suppressWarnings(try(predict(classifier_lda, newdata = BreastCancer)$class, silent = TRUE))
pred_rf <- suppressWarnings(try(predict(classifier_rf, newdata = BreastCancer), silent = TRUE))

if (class(pred_rpart) == "try-error" || class(pred_nb) == "try-error" || 
    class(pred_nnet) == "try-error" || class(pred_lda) == "try-error" || 
    class(pred_rf) == "try-error") {
  cat("Error: Unable to make predictions from one or more classifiers.\n")
} else {
  ensemble_predictions <- ifelse(
      rowSums(cbind(pred_rpart == "malignant", pred_nb == "malignant", 
                    pred_nnet == "malignant", pred_lda == "malignant", 
                    pred_rf == "malignant")) >= 3, 
      "malignant", "benign")
  
  # Calculate accuracy
  accuracy <- mean(ensemble_predictions == BreastCancer$Class)
  
  # Display ensemble predictions for the first 10 rows
  head(ensemble_predictions, 10)
}

# Performance Evaluation
ensemble_predictions_factor <- factor(ensemble_predictions, levels = levels(BreastCancer$Class))
actual_classes_factor <- factor(BreastCancer$Class, levels = levels(ensemble_predictions_factor))
conf_matrix <- confusionMatrix(ensemble_predictions_factor, actual_classes_factor)
conf_matrix
