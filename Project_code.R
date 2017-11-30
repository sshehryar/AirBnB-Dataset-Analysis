#loading libraries


library(stringr)
library(rpart)
library(rpart.plot)
library(pROC)
library(caret)
library(ggplot2)
library(lattice)
library(data.table)
library(tidyr)
library(Matrix)
library(xgboost)
library(bit64)
library(dataQualityR)
library(RColorBrewer)
library(reshape2)
library(car)
library(dplyr)
library(compare)
library(readr)



countries_df <- read.csv('Datasets/countries.csv')
age_gender_bkts_df <- read.csv('Datasets/age_gender_bkts.csv')
testData <- read.csv('Datasets/test_users.csv')
trainingData <- read.csv('Datasets/train_users_2.csv')


str(countries_df)

str(sessions_df)

str(age_gender_bkts_df)
dim(age_gender_bkts_df)
head(age_gender_bkts_df)

str(trainingData)

str(testData)




summary(trainingData$country_destination)
#sort the countries of destination before doing a bar plot
trainingData <- within(trainingData, 
                   country_destination <- factor(country_destination, 
                                      levels=names(sort(table(country_destination), 
                                                        decreasing=TRUE))))
#draw a bar plot
ggplot(trainingData, aes(x=trainingData$country_destination))+ geom_bar () + scale_fill_distiller(palette = "RdYlGn") + theme_bw() + ggtitle("Distribution of Countries by Destination") +
  theme(plot.title = element_text(face="bold", lineheight = .8, hjust = 0.5) ,
        axis.title.x = element_text(face="bold", vjust=-0.5, size=14),
        axis.text.x  = element_text(size=12),
        axis.title.y = element_text(face="bold", vjust=1, size=14),
        axis.text.y  = element_text(size=12)) + labs(x= "Country", y="Number of Users")

#gender distribution
ggplot(trainingData, aes(x=trainingData$gender))+ geom_bar () + scale_fill_distiller(palette = "RdYlGn") + theme_bw() + ggtitle("Distribution of Gender by First Booking") +
  theme(plot.title = element_text(face="bold", lineheight = .8, hjust = 0.5) ,
        axis.title.x = element_text(face="bold", vjust=-0.5, size=14),
        axis.text.x  = element_text(size=12),
        axis.title.y = element_text(face="bold", vjust=1, size=14),
        axis.text.y  = element_text(size=12)) + labs(x= "Gender", y="Number of Users")




ggplot(age_gender_bkts_df, aes(x=age_gender_bkts_df$age_bucket,  age_gender_bkts_df$population_in_thousands))+ geom_bar (stat = "identity",aes(sort(age_gender_bkts_df$age_bucket,decreasing = T))) + scale_fill_distiller(palette = "RdYlGn") + theme_bw() + ggtitle("Distribution of Age of Users") +
  theme(plot.title = element_text(face="bold", lineheight = .8, hjust = 0.5) ,
        axis.title.x = element_text(face="bold", vjust=-0.5, size=14),
        axis.text.x  = element_text(size=12,angle = 90),
        axis.title.y = element_text(face="bold", vjust=1, size=14),
        axis.text.y  = element_text(size=12)) + labs(x= "Age bracket", y="Number of Users")

summary_language <- summary(trainingData$language)
count_df <- data.frame(country=names(summary_language), count = summary_language)


trainingData <- within(trainingData, 
                   language <- factor(language, 
                                      levels=names(sort(table(language), 
                                                        decreasing=TRUE))))

ggplot(trainingData, aes(x=trainingData$language))+ geom_bar () + scale_fill_distiller(palette = "RdYlGn") + theme_bw() + ggtitle("Distribution of language") + 
  theme(plot.title = element_text(face="bold", lineheight = .8, hjust = 0.5) ,
        axis.title.x = element_text(face="bold", vjust=-0.5, size=14),
        axis.text.x  = element_text(size=12,angle = 90),
        axis.title.y = element_text(face="bold", vjust=1, size=14),
        axis.text.y  = element_text(size=12)) + labs(x= "language", y="Count")


str(trainingData$age)

trainingData$age <- as.numeric(as.character(trainingData$age))

summary(trainingData$age)

trainingData$age[trainingData$age < 18] <- NA 
summary(trainingData$age)

summary(trainingData$gender)


#There are 95688 -unknown- values that need to be removed

summary(trainingData$country_destination)


dim(trainingData)

dim(testData)

str(testData$age)
str(trainingData$age)
master_data<-merge(trainingData, testData, all= T)
dim(master_data)
dim(master_data)

dim(sessions_df)


dim(countries_df)

str(countries_df)

master_data2 <- merge(master_data, countries_df, by = "country_destination", all = T)

dim(master_data2)


###### Cleaning Dataset, Preprocessing and Some Points and observations you should consider 


#lets start with the cleaning

summary(master_data2$age)


master_data2$age[master_data2$age < 18] <- NA

#Remove all age values greater than 127 -> the age of world's oldest living person

master_data2$age[master_data2$age > 127] <- NA

summary(master_data2$age)

summary(master_data2$gender)
dim(master_data2)

master_data2 <- subset(master_data2, gender != '-unknown-')


dim(master_data2)

master_data2 <- subset(master_data2, country_destination != 'other')

dim(master_data2)

summary(master_data2$age)

master_data3 <- master_data2

master_data3$age[is.na(master_data3$age)] <- median(master_data3$age, na.rm = TRUE)

summary(master_data3$age)


#From now on, moving forward, we'll be playing with master_data_3


master_data4 <- master_data3


master_data4 <- subset(master_data4, select = -date_first_booking) #remove date_first_booking


# split date_account_created in year, month and day
#this will also remove the previous date_account_created variable
dateAccountCreated = as.data.frame(str_split_fixed(master_data4$date_account_created, '-', 3))
master_data4['dac_year'] = dateAccountCreated[,1]
master_data4['dac_month'] = dateAccountCreated[,2]
master_data4['dac_day'] = dateAccountCreated[,3]
master_data4 = master_data4[,-c(which(colnames(master_data4) %in% c('date_account_created')))]


master_data4$dac_day <- as.numeric(as.character(master_data4$dac_day))
master_data4$dac_month <- as.numeric(as.character(master_data4$dac_month))
master_data4$dac_year <- as.numeric(as.character(master_data4$dac_year))

summary(master_data4$dac_day)


summary(master_data4$dac_month)


summary(master_data4$dac_year)




str(master_data4$timestamp_first_active)

master_data4$timestamp_first_active <- as.character(as.numeric(master_data4$timestamp_first_active))

str(master_data4$timestamp_first_active)

head(master_data4$timestamp_first_active)

# split timestamp_first_active in year, month and day
master_data4[,'tfa_year'] = substring(master_data4$timestamp_first_active, 1, 4)
master_data4['tfa_month'] = substring(master_data4$timestamp_first_active, 5, 6)
master_data4['tfa_day'] = substring(master_data4$timestamp_first_active, 7, 8)



#remove previous timestamp_first_active variable
master_data4 = master_data4[,-c(which(colnames(master_data4) %in% c('timestamp_first_active')))]

#View(master_data4)
str(master_data4$tfa_day)

master_data4$tfa_day <- as.numeric(as.character(master_data4$tfa_day))
master_data4$tfa_month <- as.numeric(as.character(master_data4$tfa_month))
master_data4$tfa_year <- as.numeric(as.character(master_data4$tfa_year))


summary(master_data4$tfa_day)

summary(master_data4$tfa_month)

summary(master_data4$tfa_year)

master_data4 <- subset(master_data4, tfa_year != 2009)



dim(master_data4)



summary(master_data4$tfa_year)


one_hot_encoding_features = c('gender', 'signup_method', 'signup_flow', 'language', 'affiliate_channel', 'affiliate_provider', 'first_affiliate_tracked', 'signup_app', 'first_device_type', 'first_browser')

dummies <- dummyVars(~ gender + signup_method + signup_flow + language + affiliate_channel + affiliate_provider + first_affiliate_tracked + signup_app + first_device_type + first_browser, data = master_data4)

master_data_4_ohe <- as.data.frame(predict(dummies, newdata = master_data4))

master_data_4_combined <- cbind(master_data4[,-c(which(colnames(master_data4) %in% one_hot_encoding_features))],master_data_4_ohe)

master_data_4_combined <- subset(master_data_4_combined, select = -`gender.-unknown-` )

master_data_4_combined <- subset(master_data_4_combined, select = -`language.-unknown-` )

master_data_4_combined <- subset(master_data_4_combined, select = -`first_device_type.Other/Unknown` )

master_data_4_combined <- subset(master_data_4_combined, select = -`first_browser.-unknown-` )


master_data_4_combined <- subset(master_data_4_combined, select = - destination_language)

master_data_4_combined[is.na(master_data_4_combined)] <- -1


############################################################################

str(master_data_4_combined$country_destination)
summary(master_data_4_combined$country_destination)

summary(master_data_4_combined$country_destination)

master_5 <- master_data_4_combined

set.seed(123567)
split_xgb<-(0.8)
trainingRowIndex_xgb <- sample(1:nrow(master_data_4_combined),(split_xgb)*nrow(master_data_4_combined))
trainingData_xgb <- master_data_4_combined[trainingRowIndex_xgb, ]  # model training data
testData_xgb <- master_data_4_combined[-trainingRowIndex_xgb, ]

# split train and test
X = master_data_4_combined[master_data_4_combined$id %in% trainingData_xgb$id,]

y <- Recode(trainingData_xgb$country_destination,"'NDF'=0; 'US'=1; 'other'=2; 'FR'=3; 'CA'=4; 'GB'=5; 'ES'=6; 'IT'=7; 'PT'=8; 'NL'=9; 'DE'=10; 'AU'=11")
X_test = master_data_4_combined[master_data_4_combined$id %in% testData_xgb$id,]

# train xgboost
xgb <- xgboost(data = data.matrix(X[,-1]), 
               label = y, 
               eta = 0.1,
               max_depth = 15,  
               nround=120, 
               early_stopping_rounds = 100,
               subsample = 0.5,
               colsample_bytree = 0.5,
               seed = 1,
               eval_metric = "merror",
               objective = "multi:softprob",
               num_class = 12,
               nthread = 3
)


#important features

model <- xgb.dump(xgb, with_stats = T)
model[1:10]

names <- dimnames(data.matrix(X[,-1]))[[2]]

# Compute feature importance matrix
importance_matrix <- xgb.importance(names, model = xgb)
# graph
xgb.plot.importance(importance_matrix[1:20,])

xgb.dump(xgb)



y_pred <- predict(xgb, data.matrix(X_test[,-1]))

# extract the 8 classes with highest probabilities
predictions <- as.data.frame(matrix(y_pred, nrow=12))
#View(predictions)
rownames(predictions) <- c('NDF','US','other','FR','CA','GB','ES','IT','PT','NL','DE','AU')

predictions_top8 <- as.vector(apply(predictions, 2, function(x) names(sort(x)[12:5])))

head(predictions_top8)

pred_variable <- as.data.frame(predictions_top8)

dim(pred_variable)

dim(X_test)

dim(X)

dim(master_data_4_combined)
