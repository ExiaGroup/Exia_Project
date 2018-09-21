library(tidyr)
library(psych)
library(ggplot2)
library(reshape2)
#------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------Loading DataFrame--------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##Reading csv file into a dataframe
titanic_training_data <- read.csv('Titanic_Training_Data.csv', header = TRUE, sep = ",", dec = ".", na.strings = c("NA",""))
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Changing Column Types-------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##Turning int into factors
titanic_training_data$PassengerId <- as.factor(titanic_training_data$PassengerId)
titanic_training_data$Survived <- as.factor(titanic_training_data$Survived)
titanic_training_data$Pclass <- as.factor(titanic_training_data$Pclass)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Removing the Cabin column---------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##Removing and storing cabin because it isnt a quantitative variable and it has a lot of NA values
titanic_training_data_cabin <- titanic_training_data[11]
titanic_training_data <- titanic_training_data[,-11]
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Fixing NA's in Embarked Column----------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##fixing Embarked
##each value represents the port in which passengers embarked from
##C = Cherbourg, Q = Queenstown, S = Southampton
##set the missing values equal to the mode, which turns out to be Southampton
titanic_training_data$Embarked[which(is.na(titanic_training_data$Embarked))] <- 'S'
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Fixing NA's in Age Column---------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##remove all missing Age variable
titanic_training_data <- titanic_training_data[complete.cases(titanic_training_data$Age),]

##fixing age less than 1
##Age above .5 was rounded to 1
##Age below .5 was rounded to 0
titanic_training_data$Age[which(titanic_training_data$Age < 1)] <- round(titanic_training_data$Age[which(titanic_training_data$Age < 1)], digits = 0)

##fixing decimal age
titanic_training_data$Age <- round(titanic_training_data$Age, digits = 0)

##converting numerical type into integer type for age variable
titanic_training_data$Age <- as.integer(titanic_training_data$Age)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Fixing Fare Column----------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##round Fare to 2 decimal places
##this makes the sale price seem more realistic
titanic_training_data$Fare <- round(titanic_training_data$Fare, digits = 2)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Clean Data after 1st round of cleaning--------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
clean_titanic_training_data <- titanic_training_data
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Summary Statistics----------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##calculating and print out summary statistics on numeric data 
for (name in names(clean_titanic_training_data)){
  if (sapply(clean_titanic_training_data[name], is.numeric)){
    cat('Summary Statistics for',name, 'variable:',summary(clean_titanic_training_data[name]),'\n')
    variable_variance <- var(clean_titanic_training_data[name])
    variable_sd <- sqrt(variable_variance)
    cat('The Standard Deviation for ',name,' is: ',variable_sd,'\n')
    cat('The Variance for ',name,' is: ',variable_variance,'\n\n')
  }
}
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Normalizing Age and Fare----------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##normalizing Age and Fare
##the following is a function that uses the min max normalization method
min_max_function <- function(x){
  return( (x-min(x))/(max(x)-min(x)) )
}
##creating a df with only Age and Fare 
age_fare_df <- as.data.frame(titanic_training_data[,c(6,10)])
normalized_age_fare_df <- as.data.frame(sapply(age_fare_df, min_max_function))
#------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------Normal Probability Plot/Histograms for Age/Fare------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##create a normal probability plot for Age data and Fare data 
##Age sample data looks approximately normal 
##Fare sample data does not look approximately normal
qqnorm(normalized_age_fare_df$Age,main = 'Normal Q-Q Plot for Age')
qqnorm(normalized_age_fare_df$Fare, main = 'Normal Q_Q plot for Fare')


##creating a Histogram of Age
ggplot(normalized_age_fare_df,aes(x = Age)) + 
  geom_histogram(breaks = seq(0,1,by = .1) , aes(y = ..density.., fill=..count..))+
  stat_function(fun = dnorm, args = with(normalized_age_fare_df, c(mean = mean(Age), sd = sd(Age))))+
  scale_fill_gradient('Count',low = 'blue', high = 'red')+
  labs(x = "Values", y = "Frequency", title = "Histogram of Age and Fare")


##Fare Histogram
ggplot(normalized_age_fare_df,aes(x = Fare)) + 
  geom_histogram(breaks = seq(0,1,by = .1) , aes(y = ..density.., fill=..count..))+
  stat_function(fun = dnorm, args = with(normalized_age_fare_df, c(mean = mean(Fare), sd = sd(Fare))))+
  scale_fill_gradient('Count',low = 'blue', high = 'red')+
  labs(x = "Values", y = "Frequency", title = "Histogram of Age and Fare")
## histogram shows Fare is very screwed to the left.  (also known as right-skewed distribution)
##definately not normally distributted
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Age/Fare Boxplots and Correlation plot--------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##creating boxplot of Age and Fare
##set x = variable, there are 2 variables so it creates 2 boxplots 
##melt also creates a column, by default called value, that contains all the values of each column name that are not part
##of the id argument and does row-wise pairing with each value to the corresponding column name
##geom_bloxplot() makes the plot be boxplot
ggplot(data = melt(normalized_age_fare_df), 
       aes(x= variable, y=value)) +
  geom_boxplot()



##Correlation graphs 
pairs.panels(clean_titanic_training_data[,c(6,10)], lm= TRUE)
##age has an odd histogram
##.1 pearson correlation tells us Age and Fare are not linearly correlated
#------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------Embarked, Pclass,Sex,SibSp,Parch,Survived bar plots-----------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##the following section creates bar graphs for our data with y axis representing the frequency
##indexed the dataframe for the variables we're interested in graphing
##turned the data into 2 columns-> key-value pairs, where key represent the variable name and value represents the values
##there is a warning message: attributes are not identical across measure variables
##this warning can be ignored; it has to do with having factor variable columns
clean_titanic_training_data[c(2,3,5,7,8,11)] %>%
  gather() %>%
  ggplot(aes(x=value, fill=value))+
  labs(title = 'Multiple bar graphs\n', y = 'Frequency')+
  ##removes the legend
  guides(fill = FALSE)+
  geom_bar()+
  facet_wrap(key~.,scales = 'free')
#------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------Passenger Class Gender bar plot-------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##creating a bar graph for number of males and females in each Passenger Class 
##fill = Pclass allows us to section off the bar to see amount of males or females in each passenger class 
ggplot(clean_titanic_training_data, aes(x = Sex,fill = Pclass))+
  labs(title = 'Gender/Pclass distribution\n' ,x='Gender', y = 'Frequency')+
  geom_bar()
#------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------Survived vs. Gender/Pclass Bar graph--------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##creating a bar graph that shows number of people survived in each Pclass and separated by male/female
ggplot(clean_titanic_training_data, aes(x = Survived))+
  facet_wrap(Sex~.)+
  labs(title = 'Number of Passengers Survived\n' ,x='', y = 'Frequency')+
  geom_bar(aes(fill = Pclass))
#------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------Age vs Fare scatterplots--------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##Scatterplot with rainbow colors
ggplot(clean_titanic_training_data, aes(x=Age, y =Fare, color = Fare))+
  scale_color_gradientn(colours = rainbow(5))+
  geom_point(shape = 18, size = 3)

##Scatterplot is color separated by P class
ggplot(clean_titanic_training_data, aes(x=Age, y =Fare, color = Pclass))+
  geom_point()

#Scatterplot is color separated by Survived
ggplot(clean_titanic_training_data, aes(x=Age, y =Fare, color = Survived))+
  geom_point()

#Scatterplot is shape separated by Embarked Location with rainbow colors
ggplot(clean_titanic_training_data, aes(x=Age, y =Fare, color = Age, shape = Embarked))+
  scale_color_gradientn(colours = rainbow(6))+
  geom_point(size = 1)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Discretizing the Age variable-----------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##BinnedAge
age_breaks <- c(0,15,29,45,200)
labels <- c("15 and Under","Between 16 and 29","Between 30 and 45","46 and older")
clean_titanic_training_data[,'Age_Class'] <- cut(clean_titanic_training_data$Age, age_breaks, labels, right = FALSE)
## right = FALSE means the binn interval is closed on the left and open on the right

## table shows the count for each Age group
table(clean_titanic_training_data[,'Age_Class'])


