library(downloader)
library(data.table)
library(dplyr)
library(reshape2)

#sets working directory to start
setwd("~/Documents/My Documents/Data Science @ Coursera")

#creates a dataset directory
if(!dir.exists("dataset")) { dir.create("dataset")} 
setwd("./dataset")
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "dataset.zip", mode="wb")
unzip ("dataset.zip", exdir = ".")
setwd("./UCI HAR Dataset")

## Get Headers
headerlist <- read.csv("features.txt", sep = " ", header=FALSE, col.names = c("row", "header"))
headers <- headerlist %>%
  filter(header %like% '.*mean.*' | header %like% '.*std.*') %>%
  mutate(header = gsub("-mean", 'Mean', header)) %>%
  mutate(header = gsub("-std", 'Std', header)) %>%
  mutate(header = gsub("()", "", header, fixed = TRUE)) %>%
  mutate(header = gsub("-", "", header, fixed = TRUE))
rm(headerlist)

## Load TRAIN
train <- read.table("train/X_train.txt")[headers$row]
names(train) <- headers$header
trainActivity <- read.table("train/Y_train.txt", col.names = 'Activity')
trainSubjects <- read.table("train/subject_train.txt", col.names = 'Subjects')
train <- bind_cols(train, trainActivity, trainSubjects)
rm(trainActivity)
rm(trainSubjects)

## Load TEST
test <- read.table("test/X_test.txt")[headers$row]
names(test) <- headers$header
testActivity <- read.table("test/Y_test.txt", col.names = 'Activity')
testSubjects <- read.table("test/subject_test.txt", col.names = 'Subjects')
test <- bind_cols(test, testActivity, testSubjects)
rm(testActivity)
rm(trainSubjects)

## merge into full dataset
fullset <- bind_rows(train, test)
rm(train)
rm(test)


## get activity labels
activityLabels <- read.table("activity_labels.txt", col.names = c("row", "activity"))
featureset <- read.table("features.txt")
features <- as.character(featureset[,2])


fullset$Activity <- factor(fullset$Activity, levels = activityLabels$row, labels = activityLabels$activity)
fullset$Subjects <- as.factor(fullset$Subjects)

fullset.melted <- melt(fullset, id = c("Activity", "Subjects"))
fullset.mean <- dcast(fullset.melted, Subjects + Activity ~ variable, mean)

write.table(fullset.mean, "../workfolder/tidyset.txt", row.names = FALSE, quote = FALSE)
