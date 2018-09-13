library(tidyr)
library(ggplot2)
library(dplyr) 


dataset <- read.csv("HeightWage_MenWomenUS_HW.csv", header = TRUE, sep = ",")

##A
a <- c(7,12,13,16)
datasetSiblingsHeightWage <- dataset[,a]
summary(datasetSiblingsHeightWage)
##The mean height stayed relatively the same, which is odd because you would expect people to grow taller becaues of puberty
##Also, the max height dropped from 83 to 81 showing error in the data collection process
##The amount of NA's is very concerning becaues it will skew the results
##The mean siblings is 3, but the max siblings is 29 and highly unlikely.  This eludes to the possibility that some data points are entered in wrong
##Also, the max wage is 1533 and highly unlikely.  Possible the data was entered in wrong.  


##B
wageHeight <- c(3,4)
datasetSiblingsHeightWage[,wageHeight] %>%
  ggplot(aes(x = wage96, y = height85, color = height85)) +
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()+
  geom_smooth(method = 'lm', fill = NA) 
##the slope is positive which shows a positive correlation between wage and height
##there are outliers in the dataset and is shown in the graph 


##C
datasetSiblingsHeightWage[which(datasetSiblingsHeightWage$wage96 < 500),wageHeight] %>%
  ggplot(aes(x= wage96, y = height85, color = height85)) + 
  scale_color_gradientn(colours = rainbow(5))
  geom_point()+
  geom_smooth(method = 'lm', fill = NA) 
##there is a positive correlation between wage and height


##D
adolescentHeightVsAdultHeight <- c(2,3)
datasetSiblingsHeightWage[,adolescentHeightVsAdultHeight] %>%
  ggplot(aes(x=height85, y = height81, color = height81)) +
  scale_color_gradientn(colours = rainbow(5)) +
  geom_point()
##lets look at points where y = 70.  If the point has x < 70, then those points signal a decrease in height as person ages
##therefore, we ignore those points where people's adolescent height is less than their adult height
##Should not use these observations because it is unlikely that one's height will decrease as one ages. 
datasetSiblingsHeightWage[which(datasetSiblingsHeightWage$height81 > datasetSiblingsHeightWage$height85),] %>%
  ggplot(aes(x=height85, y = height81, color = height81)) +
  scale_color_gradientn(colours = rainbow(5)) +
  geom_point()



