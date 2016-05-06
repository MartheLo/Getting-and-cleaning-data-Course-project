# Loading data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "acceldata.zip", method = "curl")
unzip("acceldata.zip", list = TRUE)

# 1. Merging the training and the test sets to create one dataset
testset <- read.table("./UCI HAR Dataset/test/X_test.txt")
trainset <- read.table("./UCI HAR Dataset/train/X_train.txt")
mergedset <- rbind(trainset, testset)

# 2. Extract only the measurements on the mean and standard deviation for each measurement
# 2.1 Add headings
headings <- read.table("./UCI HAR Dataset/features.txt")
colnames(mergedset) <- headings[, 2]

# 2.2 Subset data
mergedsubset <- mergedset[, grep("[Mm]ean|[Ss]td", colnames(mergedset))]

# 3. Uses descriptive activity names to name the activities in the data set
# 3.1 Reading in labels
labelstest <- read.table("./UCI HAR Dataset/test/y_test.txt")
labelstrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
mergedlabels <- rbind(labelstrain, labelstest)

# 3.2 Add labels to dataset
data_with_labels <- cbind(mergedsubset, mergedlabels)
colnames(data_with_labels)[87] <- "labels"

# 3.3 Change numbers to descriptive activity names (from activity_labels.txt)
install.packages("qdap")
library("qdap")
data_with_labels$labels <- multigsub(c("1", "2", "3", "4", "5", "6"), 
                                            c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"),
                                            data_with_labels$labels)

# 4. Appropriately label the data set with descriptive variable names.
names(data_with_labels)<-gsub("^t", "time", names(data_with_labels))
names(data_with_labels)<-gsub("^f", "frequency", names(data_with_labels))
names(data_with_labels)<-gsub("Acc", "Accelerometer", names(data_with_labels))
names(data_with_labels)<-gsub("Gyro", "Gyroscope", names(data_with_labels))
names(data_with_labels)<-gsub("Mag", "Magnitude", names(data_with_labels))
names(data_with_labels)<-gsub("BodyBody", "Body", names(data_with_labels))

# 5. From the data set in step 4, create a second, independent tidy data set with the average of each 
# variable for each activity and each subject.
# 5.1 Add subjects to dataset
subjectstest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
mergedsubjects <- rbind(subjecttrain, subjectstest)
completedata <- cbind(data_with_labels, mergedsubjects)
colnames(completedata)[88] <- "subjects"

# Create average for each activity and each subject
tidy <- aggregate(completedata[,names(completedata) !=c("labels", "activity")], 
                  by=list(activity = completedata$labels, subject = completedata$subjects), mean)

write.table(tidy, file = "./tidydata.txt", row.names = FALSE)