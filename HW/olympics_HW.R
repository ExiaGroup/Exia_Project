library(tidyr)
library(ggplot2)
library(dplyr) 


dataset <- read.csv("olympics.txt", header = TRUE, sep = " ")

sapply(dataset, table)
colSums(is.na(dataset))

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
  ggplot(aes(x = medals, y = athletes, color = atheletes)) +
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()
##looks like a positive correlation

##E
##it is possible that higher gdp means better trained athletes
##higher population means more atheletes



##F
d <- c(12,14)
dataset[,d] %>%
  ggplot(aes(x = medals, y = GDP, color = GDP)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()
##there is no relationship


##G
d <- c(11,14)
dataset[,d] %>%
  ggplot(aes(x = medals, y = population, color = population)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point()
##there seems to be no correlation

##h
d <- c(5,14)
dataset[,d] %>%
  ggplot(aes(x = medals, y = temp, color = temp)) + 
  scale_color_gradientn(colours = rainbow(5))+
  geom_point(shape = 18, size = 3)
##there is no correlation











