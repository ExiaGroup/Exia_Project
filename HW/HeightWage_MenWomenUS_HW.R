library(tidyr)
library(ggplot2)
library(dplyr) 


dataset <- read.csv("HeightWage_MenWomenUS_HW.csv", header = TRUE, sep = ",")

##A
a <- c(7,12,13,16)
datasetSiblingsHeightWage <- dataset[,a]
summary(datasetSiblingsHeightWage)
##discuss the results 


##B
wageHeight <- c(3,4)
datasetSiblingsHeightWage[,wageHeight] %>%
  ggplot(aes(x = wage96, y = height85, color = height85)) +
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()
##the slope looks like it might be undefined
##height might be normally distributed

##C
datasetSiblingsHeightWage[which(datasetSiblingsHeightWage$wage96 < 500),wageHeight] %>%
  ggplot(aes(x= wage96, y = height85, color = height85)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()


##D
adolescentHeightVsAdultHeight <- c(2,3)
datasetSiblingsHeightWage[,adolescentHeightVsAdultHeight] %>%
  ggplot(aes(x=height85, y = height81, color = height81)) +
  scale_color_gradientn(colours = rainbow(5)) +
  geom_point()
##lets look at points where y = 70.  If the point has x < 70, then those points signal a decrease in height as person ages
##therefore, we ignore those points
##Should not use these observations because it is unlikely that one's height will decrease as one ages. 







