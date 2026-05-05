## ---- packages --------
#load needed packages. make sure they are installed.
library(here) #for data loading/saving
library(dplyr)
library(skimr)
library(ggplot2)
library(tidyr)

## ---- loaddata --------
#Path to data. Note the use of the here() package and not absolute paths
data_location <- here::here("data","processed-data","processed_merged_data.rds")
data_location2 <- here::here("data","processed-data","processed_CSS_data.rds")
#load data
mydata <- readRDS(data_location)
CSSdata <- readRDS(data_location2)

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
#To me this says there is no weekly scheduled salmonella dumping in the water


## ---- Histogram and Area Plot -------

#histogram showing how many samples have each number of serovars in them
complexhist <- CSSdata %>% ggplot(aes(x=complexity)) + geom_histogram() + theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank()) +
  scale_y_continuous(expand = c(0,0)) + scale_x_continuous(expand = c(0,0))
complexhist

#I want to make an area plot of all the serovars over time, first though I want a df that has complexity removed
#Then I want to convert it to long(?) format so I can turn it into an area plot
#I also want to make an other serovar category for the area plot bc it can get to be alot when theres 26 different serovars
df2 <- CSSdata %>% select(-complexity)
df2$Other <- df2$Anat + df2$AquaInve + df2$Infa + df2$Gamn + df2$MontI + df2$Mine + df2$SaitII + df2$KisrI + df2$Luci + df2$BertBuda + df2$MuenII + df2$MbanI + df2$Hada + df2$MissII
df2 <- df2 %>% select(-Anat, -AquaInve, -Infa, -Gamn, -MontI, -Mine, - SaitII, -KisrI, -Luci, -BertBuda, -MuenII, -MbanI, -Hada, - MissII)
df2$check <- df2$BrazI + df2$Brae + df2$MontII + df2$MuenI + df2$Mues + df2$Rubi + df2$Typm + df2$GiveI + df2$NewpII + df2$Hart + df2$Agbe + df2$Oran + df2$Other
df2 <- df2 %>% select(-check)
#I removed serovars that appeared in low amounts/appeared infrequently and bundled them into an "other" category
#Check allows me to make sure everything still adds up to 1 and that I didn't accidentially delete or fail to delete something
df2long <- df2 %>% pivot_longer(cols = 2:14)
#This puts it in the proper format for the area plot
df2long$name <- as.factor(df2long$name)
df2long$Day <- as.integer(df2long$Day)
#these need to be this way so area plot works
df2long$name <- factor(df2long$name, levels = 
    c("Other", "Hart", "Mues", "Oran", "Brae", "Agbe", "GiveI", "NewpII", "Typm", "BrazI", "Rubi", "MuenI", "MontII"), ordered = TRUE)
#now I am ordering the serovars so that the ones that appear most frequently are first and so the area plot looks prettier
#It doesn't matter too much the order, so long as the biggest are on the bottom

#Now to rename the variables

df2long <- df2long %>% rename(
    Serovar = name
)

clrs <- c("#424242", "#ee3b3b", "#b23aee", "#ff1493", "#ffd700", "#ffa500", "#b3ee3a", "#2e8b57", "#ffe1ff", "#cd6600", "#8ee5ee", "#7AC5CD", "#53868B")

area <- df2long %>% ggplot(aes(x=Day, y=value, fill=Serovar)) + geom_area() + 
  scale_y_continuous(expand = c(0,0)) + scale_x_continuous(expand = c(0,0)) + 
  scale_fill_manual(values = clrs)
area

save_location <- here::here("data", "processed-data", "Figures")
ggsave("areaplot.jpeg", plot = area, path = save_location , width = 10, height = 4.5)
ggsave("complexity_histogram.jpeg", plot = complexhist, path = save_location, width = 5, height = 3)

#ggsave for saving area plot