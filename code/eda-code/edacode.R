## ---- packages --------
#load needed packages. make sure they are installed.
library(here) #for data loading/saving
library(dplyr)
library(skimr)
library(ggplot2)

## ---- loaddata --------
#Path to data. Note the use of the here() package and not absolute paths
data_location <- here::here("data","processed-data","processed_merged_data.rds")
#load data
mydata <- readRDS(data_location)

## ---- ComplexityByTime -------
plot1 <- mydata %>% ggplot(aes(x=Day, y=complexity)) + geom_point()
plot1
#Maybe some cyclical things?

## ---- ComplexityByWeather -------
#This is to see if any of these look like they're correlated with complexity
#Also to check for potentially non-linear relationships since I plan to use a linear model
#This is also only looking at any of these values on the day of sampling
#It may be worth (especially for things like rain which is a variable of high interest) looking at the weather the day before

plot2 <- mydata %>% ggplot(aes(x=COND, y=complexity)) + geom_point()
plot2
#I see no relationship
plot3 <- mydata %>% ggplot(aes(x=TDS, y=complexity)) + geom_point()
plot3
#this looks exactly the same as conductivity
plot4 <- mydata %>% ggplot(aes(x=pH, y=complexity)) + geom_point()
plot4
#there is one day where pH is really high
#There is maybe a relationship?
plot5 <- mydata %>% ggplot(aes(x=temp, y=complexity)) + geom_point()
plot5
#This might actually have a relationship!
#for clarity this is temp of water
plot6 <- mydata %>% ggplot(aes(x=depth, y=complexity)) + geom_point()
plot6
#this looks the same as COND and TDS
plot7 <- mydata %>% ggplot(aes(x=width, y=complexity)) + geom_point()
plot7
#There are clearly 2 groups, my hypothesis is one group is from where Dawson measured the creek, and the other group is from where I measured the creek
plot8 <- mydata %>% ggplot(aes(x=max.temp, y=complexity)) + geom_point()
plot8
#This also looks like it's correlated!
#this is temp of air
plot9 <- mydata %>% ggplot(aes(x=min.temp, y=complexity)) + geom_point()
plot9
#this also looks correlated, same as the other temps
plot10 <- mydata %>% ggplot(aes(x=rel.humid, y=complexity)) + geom_point()
plot10
#this looks like maybe theres some correlation!
plot11 <- mydata %>% ggplot(aes(x=twoinST, y=complexity)) + geom_point()
plot11
#I am not going to graph every soil temp bc I'm fairly sure they're all the same
#This like all the other temp variables looks correlated
plot12 <- mydata %>% ggplot(aes(x=wind.speed, y=complexity)) + geom_point()
plot12
#I would argue no correlation
plot13 <- mydata %>% ggplot(aes(x=radiation, y=complexity)) + geom_point()
plot13
#this looks like a correlation!
plot14 <- mydata %>% ggplot(aes(x=rain, y=complexity)) + geom_point()
plot14
#Ouch I would argue no correlation
plot15 <- mydata %>% ggplot(aes(x=ET, y=complexity)) + geom_point()
plot15
#This looks correlated which is weird bc I think this is how much water evaporates from plants
#Might be a temp thing
#even if it has no direct physiological effect it might be worth something as a predictor?
plot16 <- mydata %>% ggplot(aes(x=turbidity, y=complexity)) + geom_point()
plot16
#This looks like it might be correlated!!
plot17 <- mydata %>% ggplot(aes(x=flow_avg, y=complexity)) + geom_point()
plot17
#Maybe correlated??
plot18 <- mydata %>% ggplot(aes(x=Weekday, y=complexity)) + geom_boxplot()
plot18
#These are not in order but I just kinda wanted to see what these looked like

