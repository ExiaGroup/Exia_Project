library(tidyr)
library(ggplot2)
library(dplyr) 

##make sure the data file is saved in the working directory
dataset <- read.csv("olympics.txt", header = TRUE, sep = " ")


##A
a <- c(12,14,15)
summary(dataset[,a])


##B
b <- c(2,4,14,12,15)
head(dataset[,b],n = 5)

##C
table(dataset$year)


##D
c <- c(14,15)
dataset[,c] %>%
  ggplot(aes(x = medals, y = athletes, color = athletes)) +
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()
##looks like a positive correlation between medals and athletes


##E
##it is possible that higher gdp means better trained athletes, which means more medals
##higher gdp means higher population. therefore, more atheletes



##F
d <- c(12,14)
dataset[,d] %>%
  ggplot(aes(x = medals, y = GDP, color = GDP)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()+
  geom_smooth(method = 'lm', fill = NA) 
##there is a positive correlation between medals and GDP


##G
d <- c(11,14)
dataset[,d] %>%
  ggplot(aes(x = medals, y = population, color = population)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point() +
  geom_smooth(method = 'lm', fill = NA) 
##there seems to be a positive correlation between medals and population


##h
d <- c(5,14)
dataset[,d] %>%
  ggplot(aes(x = medals, y = temp, color = temp)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point(shape = 18, size = 3)+
  geom_smooth(method = 'lm', fill = NA) 
##There is a negative correlation between medals and temperature











