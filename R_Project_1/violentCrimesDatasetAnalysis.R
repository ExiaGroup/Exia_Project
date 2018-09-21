library(ggplot2)  
library(reshape2)
library(dplyr)  
library(tibble) 
library(gridExtra)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------Load Data-------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
dataset <- read.csv("DATASET1.csv", header = TRUE)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Turning data types into factors---------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
dataset$lat <- as.factor(dataset$lat)
dataset$long <- as.factor(dataset$long)
dataset$Months <- as.factor(dataset$Months)
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------Discretizing the Violent Crime Data-----------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##creating new feature using the built in cut method 
##bin interval is closed on the left and open on the right
crime_labels <- c('Negligible','Low','Medium','High','Very High')
crime_breaks <- c(0,300,600,1100,2100,4000)
dataset$Crime_Tier <- cut(dataset$Violent_crime_total, crime_breaks, crime_labels, right = FALSE)

##creating a binary feature; 1 = over 150,000 and 0 = under 150,000
population_breaks <- c(0,150001,300000)
population_labels <- c('0','1')
dataset['Over_150000_Population'] <- cut(dataset$Population,population_breaks,population_labels, right = FALSE)

##rearrange the columns so Crime_Tier is next to Violent_crime_total and Over_150,000_Population is next to Population
dataset <- dataset[,c(1,2,3,4,17,5,16,6,7,8,9,10,11,12,13,14,15)]

##writing header of dataframe to MYOUTFILE.txt
header = head(dataset)
write.table(header, file = "MYOUTFILE.txt", sep = " ", append = FALSE)
#------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------Creating Statistic Functions-----------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##1st argument passes the tibble that contains the data of interest
##2nd argument passes the name of the column that contains the different groups;the column data type should be factor
##3rd argument passes the name of the column that contains the numeric data that corresponds to the resepective groups in 2nd
##argument
##2nd and 3rd argument should have not quotation marks around the characters
##data should be cleaned of NA-values; never tested if it works for data that contains NA-values
ANOVA.Calculator <- function(data,group_var,data_var){
  group_cn <- enquo(group_var)
  data_cn <- enquo(data_var)
  b<- group_by(data,!!group_cn)
  ##n() gets the number of data points in each group
  c <- summarise(b, mean = mean(!!data_cn),sum = sum(!!data_cn),n = n())
  total_observations <- summarise(c,sum(n))
  mean_of_all_observations <- summarise(data,mean=mean(!!data_cn))[1,]
  
  c <-mutate(c,temp = (mean-mean_of_all_observations)^2*n) 
  ##the result is a tibble, so we don't need to index it to get a single number for computations
  SSTR <- summarise(c,SSTR = sum(temp))
  
  SST <- summarise(data,SST = sum((!!data_cn - mean_of_all_observations)^2))
  ##the result is a dataframe so we index it to get a single number
  SSE <- (SST-SSTR)[1,]
  
  ##the result is a tibble
  number_of_groups <- summarise(c,number_of_groups = n())
  
  ##the result is a dataframe so we index it to get a single number
  MSTR_df <- (number_of_groups-1)[1,]
  MSTR <- (SSTR/MSTR_df)[1,]
  MSE_df <- (total_observations-number_of_groups)[1,]
  MSE <- SSE/MSE_df
  F_statistic <- MSTR/MSE
  ##pf() is the F-distribution function that returns a p-value; it accepts only numbers, so we have to make sure all passed
  ##arguments are numbers and not data.frame or tibble 
  p_value <- pf(F_statistic, MSTR_df,MSE_df , lower.tail = FALSE)
  
  ANOVA <- data.frame('F-statistic' = F_statistic, 'P-Value' = p_value)
  return(ANOVA)
}

##data should be cleaned of NA-values; never tested if it works for data that contains NA-values
t.test.calculator <- function(data, data1_var, data2_var){
  data1_cn <- enquo(data1_var)
  data2_cn <- enquo(data2_var)
  
  ##selecting the datasets
  dataset1 <- select(data,!!data1_cn)
  dataset2 <- select(data,!!data2_cn)
  
  ##getting mean, variance and number of data values for dataset1
  dataset1_stats <- summarise(dataset1, mean = mean(!!data1_cn),variance = var(!!data1_cn),n = n())
  dataset2_stats <- summarise(dataset2, mean= mean(!!data2_cn),variance = var(!!data2_cn),n = n())
  dataset1_stats

  ##calculating t-statistic
  denominator <- sqrt((dataset1_stats$variance/dataset1_stats$n)+(dataset2_stats$variance/dataset2_stats$n))
  numerator <- dataset1_stats$mean-dataset2_stats$mean
  t_statistic <- numerator/denominator
  t_statistic
  
  ##calculate degrees of freedom
  numerator <- ((dataset1_stats$variance/dataset1_stats$n)+(dataset2_stats$variance/dataset2_stats$n))^2
  denominator <- ((dataset1_stats$variance/dataset1_stats$n)^2)/(dataset1_stats$n-1) + 
    ((dataset2_stats$variance/dataset2_stats$n)^2)/(dataset2_stats$n-1)
  degfree <- numerator/denominator
  degfree
  
  p_value <- pt(t_statistic, degfree, lower.tail = FALSE)
  
  T_Test <- data.frame('T-statistic' = t_statistic, 'P-Value' = p_value,'Degrees of Freedom' = degfree)
  return(T_Test)
}

##1st argument is for the dataframe that contains the data set 
##2nd argument specifies which column corresponds to the data values for z-test
##mu and var represents the population's mean and variance
##data should be cleaned of NA-values--> never tested if it works for data that contains NA-values
z.test.calculator <- function(data, data_var, mu, var){
  data_cn <- enquo(data_var)
  dataset <- select(data,!!data_cn)
  dataset_stats <- summarise(dataset, mean = mean(!!data_cn),variance = var(!!data_cn),n = n())
  
  zeta <- ((dataset_stats$mean)- mu)/(sqrt(var/dataset_stats$n))
  p_value <- pnorm(zeta, mean = 0, sd = 1, lower.tail = FALSE)
  p_value
  
  z_test <- data.frame('z-statistic' = zeta, 'p-value' = p_value)
  return(z_test)
}


##accepts a dataframe that contains data of interest
##data should be separated by columns
##computes the summary statistics for all numeric columns in a dataframe
##returns a single dataframe that contains all the summary statistics for input data
summary.stats <- function(data){
  Summary_stats <- data.frame()
  for (name in names(data)){
    if (sapply(data[name], is.numeric)){
      ##summarise returns a dataframe
      some_stats <- summarise(data, mean = mean(data[,name]),median = median(data[,name]),
                        min = min(data[,name]),max = max(data[,name]))
      ##quantile returns a vector; use rbind to turn the vector into a dataframe
      quartile <- rbind(quantile(data[,name]))
      merged_data<- merge(some_stats,quartile)
      ##merged_data is a single row data.frame so we change the index name to the name of the data
      row.names(merged_data) <- name
      Summary_stats <- rbind(Summary_stats, merged_data)
    }
  }
  return(Summary_stats)
}

##the last line 'sink()' disables the sink; all lines between these two lines will have their output written into the file
sink("MYOUTFILE.txt", append = TRUE)
ANOVA.Calculator(dataset,Crime_Tier,Violent_crime_total)
t.test.calculator(dataset, Burglary,Robbery)
z.test.calculator(dataset,Violent_crime_total,745.0704,346869.3)
summary.stats(dataset)
sink()
#------------------------------------------------------------------------------------------------------------------------------
#------------------------------------Different Plots Using ggplot2 library-----------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##Boxplots for Population, Violent_crime_total, Robbery, and Burglary on the same Figure
##using ggplot2 library to create the plots 
c <- c('Population','Violent_crime_total','Robbery','Burglary')
ggplot(data = melt(dataset[c]),aes(x=variable , y = value, color = variable))+
  facet_wrap(~variable, scales = 'free')+ 
  labs(title = 'Multiple Boxplots',x = 'Datasets',y = 'Values' ,color = 'Datasets')+
  geom_boxplot(alpha = .6)


##Scatterplot between population and Violent_crime_total with linear least squares regression line
ggplot(dataset, aes(x = Violent_crime_total,y = Population,color = Population))+
  geom_point(alpha = .8) + 
  labs(title = 'Pop. vs Violent crimes regression \n',x = 'Violent Crime',y = 'Population' ,color = 'Pop.')+
  scale_color_gradientn(colours = rainbow(5))+
  geom_smooth(method = 'lm', fill = NA)


##Multiple Bar graphs on same Figure
p1 <- ggplot(dataset, aes(x=Crime_Tier, fill=Crime_Tier))+
  geom_bar()+
  labs(title = 'Crime Tier Frequency',x = 'Crime Tier',y = 'Frequency', color = 'Crime Tier')
p2 <- ggplot(dataset, aes(x=Crime_Tier,y = Forcible_rape, fill=Crime_Tier))+
  geom_bar(stat = 'identity')+
  labs(title = 'Crime Tier and Forcible Rape Comparison',x = 'Crime Tier',y = 'Forcible Rape frequency', color = 'Crime Tier')
##plotting multiple plots on a figure
grid.arrange(p1, p2, nrow = 1)


##creating histogram with density curve and histogram with normal curve on same plot
p3<- ggplot(dataset, aes(x = Violent_crime_total))+
  geom_histogram(breaks = seq(0,3400,by = 245) , aes(y = ..density.., fill=..count..))+
  geom_density()+
  scale_fill_gradient('Count',low = 'blue', high = 'red')+
  labs(title = 'Violent Crime per Police Department Distribution',x = 'Violent Crimes',y = 'Frequency', color = 'Frequency')
p4 <- ggplot(dataset, aes(x = Violent_crime_total))+
  geom_histogram(breaks = seq(0,3400,by = 245) , aes(y = ..density..,fill=..count..))+
  stat_function(fun = dnorm, args = with(dataset, c(mean = mean(Violent_crime_total), sd = sd(Violent_crime_total)))) +
  labs(title = 'With Normal Curve', x = 'Violent Crimes',y = 'Probability Density')
grid.arrange(p3,p4,nrow =2, ncol = 1)


##normal probability plot for total violent crimes
a <-data.frame(setNames(qqnorm(dataset$Violent_crime_total,plot.it=FALSE), c("Theoretical_Quantiles",'Sample_Quantiles')))
ggplot(a) +
  geom_point(aes(x=Theoretical_Quantiles, y = Sample_Quantiles, color = Theoretical_Quantiles))+
  labs(title = 'Normal Probability Plot')
##the curve is not a straight line which means the random sample data violates the normality assumption
##the points lie in a quadratic-like manner
