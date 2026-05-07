###############################
# analysis script
#
#this script loads the processed, cleaned data, does a simple analysis
#and saves the results to the results folder

#load needed packages. make sure they are installed.
library(ggplot2) #for plotting
library(broom) #for cleaning up output from lm()
library(here) #for data loading/saving
library(tidymodels) #for modeling
#library(randomForest) #for randomforest modeling
library(caret) #modeling
library(ranger) #random forest modeling but different
library(corrplot) #to make a correlation plot of my variables
library(vip) #for seeing random forest results
library(cowplot) #for combining figures
library(gt) #for making tables
library(webshot2) #for saving tables

#path to data
#note the use of the here() package and not absolute paths
data_location1 <- here::here("data","processed-data","processed_merged_data.rds")
data_location2 <- here::here("data","processed-data","processed_enviro_data.rds")
data_location3 <- here::here("data","processed-data","processed_CSS_data.rds")
data_location4 <- here::here("data","processed-data","processed_merged_weekly_data.rds")
#load data. 
mydata <- readRDS(data_location1)
envirodata <- readRDS(data_location2)
CSSdata <- readRDS(data_location3)
weeklydata <- readRDS(data_location4)

######################################
#Data fitting/statistical analysis
######################################

############################
#### First model fit
# fit linear model using complexity as an outcome and temp as a predictor
#Trying this as a baby one just bc I could see they're likely correlated

lmfit1 <- lm(complexity ~ temp, mydata)  

# place results from fit into a data frame with the tidy function
lmtable1 <- broom::tidy(lmfit1)

#look at fit results
print(lmtable1)

# save fit results table  


############################
#### Correlation
#I know that generalized linear mixed models (glmms) assume none of your variables are correlated
#Given that I have 6 different measures of temperature in this study, I assume my variables are correlated
#(and that's not counting other things that might be correlated with temp like radiation)

cor(mydata$temp, mydata$max.temp)
#obviously correlated
#However I'd like a matrix of this especially one I can publish
#I will need to remove all non-numeric variables
#I am going to use the processed_enviro_data.rds since I then wont have to remove CSS data

df1 <- envirodata %>% select(-Day, -Date, - Weekday)
#This removes the non numeric variables that shouldn't have a correlation
cor_matrix <- round(cor(df1, use = "complete.obs"), digits = 3)
cor_matrix
#This I think ignores NA's
#This makes a matrix of correlations rounded to 3 digits!
#No idea what is signifigant tho or how to turn this into a pretty figure
#the default is the pearson correlation which is used for quantitative continuous variables with a linear relationship
#I'd say that applies here

cor_plot1 <- corrplot::corrplot(cor(df1, use = "complete.obs"), method = "number", type = "upper")
cor_plot1

#In other models I have had many hours long meetings discussing we used .75 as a cutoff for correlation
#I think I may stick to that here

#Of the 6 temperature variables (water temp, max air temp, min air temp, 2/4/8in soil temp)
#I will keep water temp (temp) since it's the temperature of the water where the sal is at time of sampling

df2 <- df1 %>% select(-max.temp, -min.temp, -twoinST, -fourinST, -eightinST)

cor_matrix2 <- round(cor(df2, use = "complete.obs"), digits = 3)
cor_matrix2
cor_plot2 <- corrplot::corrplot(cor(df2, use = "complete.obs"), method = "number", type = "upper")
cor_plot2
#This is much easier to read and could be turned into a figure

#I will need to remove: cond or TDS, radiation or ET
#I will remove ET from my model bc I don't think how much water evaporates from plants is physiologically relevent to salmonella
#This means I'm keeping radiation
#I will remove conductivity bc vibes, will find a more scientific method later
table_file1 = here("results", "tables", "resulttable1.rds")
saveRDS(cor_matrix2, file = table_file1)
#I think this saves it as a table

df3 <- df2 %>% select(-ET, -COND)
cor_plot3 <- corrplot::corrplot(cor(df3, use = "complete.obs"), method = "number", type = "upper")
cor_plot3

df4 <- mydata %>% select(-ET, -COND, -Day, -Date, - Weekday, -max.temp, -min.temp, -twoinST, -fourinST, -eightinST)
df4 <- df4 %>% select(-Anat, -AquaInve, -BrazI, -Brae, -Infa, -MontII, -MuenI, -Mues, -Rubi, -Typm, -Gamn, -GiveI, 
  -NewpII, -MissII, -MontI, -Hart, -Agbe, -Hada, -Mine, -Oran, -SaitII, -KisrI, -MbanI, -Luci, -BertBuda, -MuenII)

df4$complexity <- as.integer(df4$complexity)

## now I want to edit my test data (the weekly data) so it has the same set of variables as the train
df5 <- weeklydata %>% select(-ET, -COND, -Day, -max.temp, -min.temp, -twoinST, -fourinST, -eightinST)
df6 <- df5 %>% select(TDS, pH, temp, depth, width, rel.humid, wind.speed, radiation, rain, turbidity, flow_avg, complexity)
#This is my final test dataset!

rngseed <- 1234
set.seed(rngseed)

train <- df4
test <- df6
#I will train on the daily, test on the weekly

lm_mod <- linear_reg()

folds <- vfold_cv(train, v = 10)
folds

#This is the full model with all predictors, I will also test models with various combinations of predictors
lm_wf1 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ TDS + pH + temp + depth + width + rel.humid + wind.speed + radiation + rain + turbidity + flow_avg)
lm_fit1 <- lm_wf1 %>% fit(train)
tidy(lm_fit1)
lm_train_pred1 <- predict(lm_fit1, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred1 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_fit_cv1 <- lm_wf1 %>% 
  fit_resamples(folds, control = control_resamples(save_pred = TRUE, save_workflow = TRUE, extract = I))
lm_fit_cv1
collect_metrics(lm_fit_cv1)

lm_pred1 <- collect_predictions(lm_fit_cv1)

lm_p1 <- lm_pred1 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + 
  xlim(1, 11) + ylim(1, 11) +
  xlab(" ") + ylab(" ") +
  theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
lm_p1

#removing radiation
lm_wf2 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ TDS + pH + temp + depth + width + wind.speed + rel.humid + rain + turbidity + flow_avg)
lm_fit_cv2 <- lm_wf2 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE, save_workflow = TRUE))
lm_fit_cv2
collect_metrics(lm_fit_cv2)

lm_fit2 <- lm_wf2 %>% fit(train)
tidy(lm_fit2)
lm_train_pred2 <- predict(lm_fit2, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred2 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred2 <- collect_predictions(lm_fit_cv2)

lm_p2 <- lm_pred2 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + xlim(1, 11) + ylim(1, 11)
lm_p2
#This has a lower rmse

#removing rel.humid and radiation
lm_wf3 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ TDS + pH + temp + depth + width + wind.speed + rain + turbidity + flow_avg)
lm_fit_cv3 <- lm_wf3 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
lm_fit_cv3
collect_metrics(lm_fit_cv3)

lm_fit3 <- lm_wf3 %>% fit(train)
tidy(lm_fit3)
lm_train_pred3 <- predict(lm_fit3, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred3 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred3 <- collect_predictions(lm_fit_cv3)

lm_p3 <- lm_pred3 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + xlim(1, 11) + ylim(1, 11)
lm_p3

#removing rel.humid, radiation, and depth
lm_wf4 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ TDS + pH + temp + width + wind.speed + rain + turbidity + flow_avg)
lm_fit_cv4 <- lm_wf4 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
lm_fit_cv4
collect_metrics(lm_fit_cv4)

lm_fit4 <- lm_wf4 %>% fit(train)
tidy(lm_fit4)
lm_train_pred4 <- predict(lm_fit4, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred4 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred4 <- collect_predictions(lm_fit_cv4)

lm_p4 <- lm_pred4 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + xlim(1, 11) + ylim(1, 11)
lm_p4

#removing rel.humid, radiation, depth, and width
lm_wf5 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ TDS + pH + temp + wind.speed + rain + turbidity + flow_avg)
lm_fit_cv5 <- lm_wf5 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
lm_fit_cv5
collect_metrics(lm_fit_cv5)

lm_fit5 <- lm_wf5 %>% fit(train)
tidy(lm_fit5)
lm_train_pred5 <- predict(lm_fit5, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred5 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred5 <- collect_predictions(lm_fit_cv5)

lm_p5 <- lm_pred5 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + xlim(1, 11) + ylim(1, 11)
lm_p5

#removing rel.humid, radiation, depth, width, and TDS
lm_wf6 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ pH + temp + wind.speed + rain + turbidity + flow_avg)
lm_fit_cv6 <- lm_wf6 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
lm_fit_cv6
collect_metrics(lm_fit_cv6)

lm_fit6 <- lm_wf6 %>% fit(train)
tidy(lm_fit6)
lm_train_pred6 <- predict(lm_fit6, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred6 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred6 <- collect_predictions(lm_fit_cv6)

lm_p6 <- lm_pred6 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + xlim(1, 11) + ylim(1, 11)
lm_p6

#removing rel.humid, radiation, depth, width, TDS, and flow average
lm_wf7 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ pH + temp + wind.speed + rain + turbidity)
lm_fit_cv7 <- lm_wf7 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
lm_fit_cv7
collect_metrics(lm_fit_cv7)

lm_fit7 <- lm_wf7 %>% fit(train)
tidy(lm_fit7)
lm_train_pred7 <- predict(lm_fit7, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred7 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred7 <- collect_predictions(lm_fit_cv7)

lm_p7 <- lm_pred7 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + xlim(1, 11) + ylim(1, 11)
lm_p7

#removing rel.humid, radiation, depth, width, TDS, flow average, and temp
lm_wf8 <- workflow() %>% add_model(lm_mod) %>% 
  add_formula(complexity ~ pH + wind.speed + rain + turbidity)
lm_fit_cv8 <- lm_wf8 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
lm_fit_cv8
collect_metrics(lm_fit_cv8)

lm_fit8 <- lm_wf8 %>% fit(train)
tidy(lm_fit8)
lm_train_pred8 <- predict(lm_fit8, train) %>% bind_cols(train %>% select(complexity))

lm_train_pred8 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_pred8 <- collect_predictions(lm_fit_cv8)

lm_p8 <- lm_pred8 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + 
  xlim(1, 11) + ylim(1, 11) +
  xlab(" ") + ylab(" ") +
  theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
lm_p8

############################
#### Random Forest attempt

#I want to try a different model other than a linear regression, so I'll try a random forest

rf_mod1 <- rand_forest(trees = 1000) %>% set_engine("ranger", seed = rngseed) %>% set_mode("regression")
rf_wf1 <- workflow() %>% add_model(rf_mod1) %>% add_formula(complexity ~ TDS + pH + temp + depth + width + rel.humid + wind.speed + radiation + rain + turbidity + flow_avg)
rf_fit_cv1 <- rf_wf1 %>% fit_resamples(folds, control = control_resamples(save_pred = TRUE))
rf_fit_cv1
collect_metrics(rf_fit_cv1)

rf_fit1 <- rf_wf1 %>% fit(train)
rf_train_pred1 <- predict(rf_fit1, train) %>% bind_cols(train %>% select(complexity))

rf_train_pred1 %>% yardstick::rmse(truth = complexity, estimate = .pred)

rf_pred1 <- collect_predictions(rf_fit_cv1)

rf_p1 <- rf_pred1 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + 
  xlim(1, 11) + ylim(1, 11) +
  xlab(" ") + ylab(" ") +
  theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
rf_p1

#The rmse for the cv is roughly the same as the linear regression. As such, I'll keep the linear regression since it is easier to interpret

############################
#### Using Test data

#I now want to test all 3 models on my test data
#Model 1 Random Forest
#Model 2 Linear regression full predictors
#Model 3 Linear regression after subset selection of predictors

rf_test_pred1 <- predict(rf_fit1, test) %>% bind_cols(test %>% select(complexity))
rf_test_pred1 %>% yardstick::rmse(truth = complexity, estimate = .pred)

rf_fin_p1 <- rf_test_pred1 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + 
  xlim(1, 11) + ylim(1, 11) +
  xlab(" ") + ylab(" ") +
  theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
rf_fin_p1


lm_test_pred1 <- predict(lm_fit1, test) %>% bind_cols(test %>% select(complexity))
lm_test_pred1 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_fin_p1 <- lm_test_pred1 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + 
  xlim(1, 11) + ylim(1, 11) +
  xlab(" ") + ylab(" ") +
  theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
lm_fin_p1


lm_test_pred8 <- predict(lm_fit8, test) %>% bind_cols(test %>% select(complexity))
lm_test_pred8 %>% yardstick::rmse(truth = complexity, estimate = .pred)

lm_fin_p8 <- lm_test_pred8 %>% ggplot(aes(x=complexity, y=.pred)) + geom_point() + 
  xlim(1, 11) + ylim(1, 11) +
  xlab(" ") + ylab(" ") +
  theme_bw() + 
  theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
lm_fin_p8

#So after the test data, the random forest model has the best RMSE, by like a lot

############################
#### making pretty tables/figures

combined_residuals_plot <- plot_grid(lm_p1, lm_p8, rf_p1, lm_fin_p1, lm_fin_p8, rf_fin_p1, labels = c("A.", "B.", "C.", "D.", "E.", "F."), label_size = 12, label_x = .06)
combined_residuals_plot

finRes_comb <- ggdraw(combined_residuals_plot) + 
  draw_label("Predicted Complexity", x=0, y=.5, angle = 90, vjust = 1.1) + 
  draw_label("Actual Complexity", x=.5, y=0, vjust = -0.9)
finRes_comb
#I would like it noted that I worked very hard to not have the D. overlap with the axis title

tbl1_df <- data.frame(
  Model = c("Random Forest", "Linear regression all predictors", "Linear regression after subset selection"), 
  Train.rmse = c(1.36, 1.39, 1.29),
  Test.rmse = c(1.15, 1.60, 1.51)
)

tbl1 <- gt(tbl1_df) %>% 
  cols_label(Train.rmse = "Train rmse", Test.rmse = "Test rmse") %>%
  cols_align(align = "center", columns = 2:3)

save_location <- here::here("results", "figures")
save_location2 <- here::here("results", "tables")
ggsave("PredictedPlots.jpeg", plot = finRes_comb, path = save_location , width = 6, height = 4)
gtsave(tbl1, filename = "table1.png", path = save_location2)

############################
#### Serovar correlation

#I would like to know if the presense of any serovar correlates with each other
df5 <- CSSdata %>% select(-complexity)
df6 <- df5 %>% ungroup() %>% select(-Day)
#creating a data frame of only serovar data so that I can use it in a corrplot
cor_matrix3 <- round(cor(df6, use = "complete.obs"), digits = 3)
cor_matrix3

cor_plot4 <- corrplot::corrplot(cor(df6, use = "complete.obs"), method = "number", type = "upper")
cor_plot4
#I think it looks like the only real correlations seen are between serovars that do not occur frequently
#I will count the top 10 serovars and create a new corrplot

# df7 <- colSums(df6[c("Anat", "AquaInve")] >0)

df7 <- df6
df7[df7 > 0] <- 1

cor_plot5 <- corrplot::corrplot(cor(df7, use = "everything"), method = "number", type = "upper")
cor_plot5

