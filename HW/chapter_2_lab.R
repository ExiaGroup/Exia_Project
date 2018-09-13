library(haven)
##dont use foreign library

##loading data
dataset <- read_dta("post_open_refine_clean.dta")



##Number 1
Arlington <- dataset[which(dataset$precinct == "AR49" | dataset$precinct == "AR22" | dataset$precinct == "AR2" 
                           | dataset$precinct == "AR18" | dataset$precinct == "41" | dataset$precinct == "16" 
                           | dataset$precinct == "4" | dataset$precinct == "17" | dataset$precinct == "31" 
                           | dataset$precinct == "48" | (dataset$precinct == "2" & dataset$state == 4)),]

PrinceWilliam <- dataset[which(dataset$precinct == "PW 101" | dataset$precinct == "PW 104" | dataset$precinct == "PW 401" 
                               | dataset$precinct == "PW101" | dataset$precinct == "PW104" | dataset$precinct == "PW402" 
                               | dataset$precinct == "PW406" | dataset$precinct == "401" | dataset$precinct == "402" |
                                 (dataset$precinct == "104" & dataset$state == 4)),]


##Number 2 
DC <- length(which(dataset$state == 1))
MD <- length(which(dataset$state == 2))
OH <- length(which(dataset$state == 3))
VA <- length(which(dataset$state == 4))


##Number 3
##minimum age is 17
##maximum age is 95
colnames(dataset)[80] <- "age"
dataset$age <- sapply(dataset$age, function(x) 2016-x)
##note that age that was greater than 120 was removed
dataset <- subset(dataset, dataset$age < 120)
mean(dataset$age)
##mean is 43.069



##number 4
table(dataset$gender)
##it looks like anything that else got assigned a value of 0 
dataset[which(dataset$gender == 1),'male'] <- 1
table(dataset$male)

##number 5
##clinton's therm max is 200 --> remove data error
dataset$therm_clinton[which(dataset$therm_clinton > 100)] <- NA
summary(dataset$therm_clinton)
summary(dataset$therm_trump)



##number 6 
table(dataset$education)
##you would have to somehow turn the discrete bins into the number of years person received education
##the problem is that the categories are discrete and not continuous





