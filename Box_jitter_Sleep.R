library(readxl)
library(crayon)
library(stringr)
library(stringi)
library(openxlsx)
library(janitor)
library(tidyverse)
library(lubridate)
library(dplyr)
library(ggplot2)
library(plotly)
library(plotrix)
library(viridisLite, lib.loc="~/R/win-library/3.5")
library(viridis, lib.loc="~/R/win-library/3.5")
library(hrbrthemes)

# Now that we have loaded the packages, we will import our data:----------------
# Load User's daily activity data:
DailyActs <- read.csv(file.choose(), header = TRUE, sep = ",")
summary(DailyActs)

# The below data being loaded belongs to users who tracked their daily activity and sleep on the respective dates:
Data <- read.csv(file.choose(), header = TRUE, sep = ",")
summary(Data)

# Plots for users who recorded activity and sleep together
Data$TotalTimeMinsBed <- Data$TotalMinsBed/60
Data$TotalMinsSlept <- Data$TotalMinsSlept/60

SleepRecord <-
  ggplot(Data, aes(x=factor(Id), y=TotalMinsSlept, fill=factor(Id))) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, option = "C") +
  theme(legend.position = "none", plot.title = element_text(size=11)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5)) +
  ggtitle("Sleeping Hours of Users with Daily Activity Tracking") +
  xlab("UserIDs") +
  ylab("Sleep(hrs)")

# Lets See how users are tracking their heartrates:
HeartData <- read.csv(file.choose(), header = TRUE, sep = ",")
summary(HeartData)

#Clean-up process: 
HeartData<- HeartData %>% 
  clean_names() %>% 
  mutate(time = mdy_hms(time), weekday = weekdays(time)) %>%
  mutate(date = date(time), hour = hour(time), minute = minute(time), second = second(time))%>%
  select(-time)
HeartData<-HeartData[,c(1,4,3,5,6,7,2)]%>%
  group_by(id, date, weekday, hour, minute)%>% #remember that group_by() calculates the average of values(heart rates) during hh:mm:00 to hh:mm:59. 
  summarise(value=round(mean(value),1)) #this average of values (heart rates) during seconds is reported along hh:mm
head(HeartData,3)
# Not all users have their HR tracked.
USERS <- unique(HeartData$id)

HeartData$weekday<-factor(HeartData$weekday, levels = c("Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))

#To resize graph and plot heart rate through the week

options(repr.plot.width=20, repr.plot.height = 10)

plt <- ggplot(HeartData, aes(x=HeartData$hour, y=value, color=value)) +
  geom_point(alpha=.5) +
  facet_grid(rows=vars(HeartData$weekday)) +
  scale_colour_gradient2(low="darkgreen", high="darkred", mid="yellow", midpoint=105) +
  labs(title="Heart-Rates Throughout The Week") +
  scale_x_continuous(breaks = c(4, 12, 20), label = c("Morning", "Noon", "Night")) +
  scale_y_continuous(breaks = round(seq(min(HeartData$value), max(HeartData$value), by = 45),.4)) +
  theme(text= element_text(size=20))

plt <- plt + 
  # A theme with no background annotations
  theme_minimal(base_family = "Fira Sans Compressed") +
  theme(
    # Top-right position
    legend.position = c(0.975, 0.995),
    # Elements within a guide are placed one next to the other in the same row
    legend.direction = "horizontal",
    # Different guides are stacked vertically
    legend.box = "vertical",
    # No legend title
    legend.title = element_blank(),
    # Light background color
    plot.background = element_rect(fill = "#F5F4EF", color = NA),
    plot.margin = margin(20, 30, 20, 30),
    # Customize the title. Note the new font family and its larger size.
    plot.title = element_text(
      margin = margin(0, 0, 10, 0), 
      size = 20, 
      family = "KyivType Sans", 
      face = "bold", 
      vjust = 0, 
      color = "grey25"
    ),
    plot.caption = element_text(size = 11),
    # Remove titles for x and y axes.
    axis.title = element_blank(),
    # Specify color for the tick labels along both axes 
    axis.text = element_text(color = "grey40"),
    # Specify face and color for the text on top of each panel/facet
    strip.text = element_text(face = "bold", color = "grey20")
  )


# Now let's look at their daily activity
stepup <- ggplot(Data, aes(x=TotalSteps, y=Calories, size=factor(Id))) +
  geom_jitter(size = 0.7, alpha = 0.9) +
  geom_smooth(se = TRUE, method = lm, size = 1) +
  scale_fill_viridis(discrete = TRUE) +
  theme(legend.position = "None", plot.title = element_text(size=11)) +
  ggtitle("Steps versus Calories of all users") +
  xlab("Calories(Cal)") +
  ylab("Steps")



# Is the above observation true for each user? lets have a look at it:
Data$UserID <- factor(Data$Id)
UserStepup <- ggplot(Data, aes(x=TotalSteps, y=Calories, size=UserID, color=UserID)) +
  geom_jitter(size = 0.8, alpha = 0.9) +
  geom_smooth(se = FALSE, method = lm, size = 0.5) +
  scale_fill_viridis(discrete = TRUE) +
  theme(legend.position = "right", plot.title = element_text(size=11)) +
  ggtitle("Steps versus Calories per user") +
  xlab("Calories(Cal)") +
  ylab("Steps")
  
# Thus we can come to a conclusion that more steps they take, more calories they burn.


# Now let's load data containing records of Weights from different users:-------------
Weight_Data <- read.csv(file.choose(), header = TRUE, sep = ",")
Weight_Data$Id <- factor(Weight_Data$Id)
# Grouped scatter plot highlighting user's preferred method of tracking weights:
T_entries <- length(Weight_Data$ManualReport[Weight_Data$ManualReport == TRUE]) #users preferring manual entries
F_entries <- length(Weight_Data$ManualReport[Weight_Data$ManualReport == FALSE])
cent_True <- (T_entries/(T_entries+F_entries)) * 100
cent_False <- (F_entries/(T_entries+F_entries)) * 100
Cents <- data.frame(percentage = c(cent_True , cent_False), Report = c("True", "False"))

Preference <- ggplot(Cents, aes(x=Report , y=percentage, fill = Report)) + 
  geom_bar(stat = "identity", width = 0.3) +
  scale_color_viridis(discrete = TRUE) +
  theme(legend.position = "none", plot.title = element_text(size=11)) +
  ggtitle("Preferred Method of Reporting Weights") +
  ylim(0,100) +
  xlab("Users Reporting Manually") +
  ylab("Percentage")

# Now let's load data containing records of sleep from different users:-------------
Sleep_Data <- read.csv(file.choose(), header = TRUE, sep = ",")
Sleep_Data$TotalTimeInBed <- Sleep_Data$TotalTimeInBed/60
Sleep_Data$TotalMinutesAsleep <- Sleep_Data$TotalMinutesAsleep/60
  

dataSleep%>%
  ggplot(Sleep_Data, aes(x=factor(Id), y=TotalTimeInBed, fill=factor(Id))) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE) +
  theme(legend.position = "none", plot.title = element_text(size=11)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5)) +
  ggtitle("Sleeping hours of Users") +
  xlab("UserIDs") +
  ylab("Sleep(hrs)")




# This confidence interval for all the users who kept a track of their daily activity
# will justify our theories
cor.test(DailyActs$TotalSteps, DailyActs$Calories, method = 'pearson', conf.level = 0.95)

