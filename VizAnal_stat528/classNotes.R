rm(list = ls())
### ISU - Data Visualization Class Notes

#====Lecture 6 Notes====
x <- c(4, 1, 3, 9)
y <- c(1, 2, 3, 5)
d <- sqrt(sum((x - y)^2))

z <- c(1,2,3,2,1,2,2,3,2,2,2,1,1,3,2,1)
labels <- c('low', 'medium', 'high')
labels[z]

tips <- read.csv("http://www.ggobi.org/book/data/tips.csv", stringsAsFactors = F)
head(tips)
tail(tips)
dim(tips)
names(tips)
summary(tips)
str(tips)
tips$totbill
summary(tips$totbill)
summary(tips[, "totbill"])
tips[1:5,]
tips[1:5, 2:3]

#====Lecture 7 Notes====
library(ggplot2)

tips <- read.csv("http://www.ggobi.org/book/data/tips.csv", stringsAsFactors = F)

ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point() +
  geom_smooth(method = 'lm')

tips.lm <- lm(tip ~ totbill, data = tips)
summary(tips.lm)

ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point() +
  geom_smooth(method = 'lm') +
  #adds an additional line/slope to compare
  #the 'suggested' tip of 15%
  geom_abline(intercept = 0, slope = .15)

#investigating the 'horizontal' lines found in the
#data points which indicate people like to tip
#whole dollar amounts
ggplot(data = tips, aes(x = tip)) +
  geom_histogram(binwidth = 1)

#bin set = 0.1
ggplot(data = tips, aes(x = tip)) +
  geom_histogram(binwidth = .1)

tips$tiprate <- tips$tip / tips$totbill
head(tips)
summary(tips$tiprate)

#histogram of tiprate
ggplot(data = tips, aes(x = tiprate)) +
  geom_histogram()
#does tiprate decrease when total bill goes up
ggplot(data = tips, aes(x = totbill, y = tiprate)) +
  geom_point()

#investigate by sex
ggplot(data = tips, aes(x = sex, y = tiprate)) + geom_point()
#jittering spreads out points in x direction - spread does not
#mean anything, but gets rid of over plotting
ggplot(data = tips, aes(x = sex, y = tiprate)) + geom_jitter()
ggplot(data = tips, aes(x = sex, y = tiprate)) + geom_boxplot()
#gender to color
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point(aes(colour = sex))
#faceting by sex
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point(aes(colour = sex)) +
  facet_wrap(~ sex) +
  #adding lines to both facets
  geom_smooth(method = 'lm')
#this way also changes the color of the regression lines
ggplot(data = tips, aes(x = totbill, y = tip, colour = sex)) +
  geom_point() +
  facet_wrap(~ sex) +
  #adding lines to both facets
  geom_smooth(method = 'lm')

#try it section

#create plots to investigate relationship between tip rate and smoking
ggplot(data = tips, aes(x = smoker, y = tiprate)) + geom_boxplot()
ggplot(data = tips, aes(x = smoker, y = tiprate)) + geom_jitter()
#smoker to color
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point(aes(colour = smoker))
#faceting by smoker
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point(aes(colour = smoker)) +
  facet_wrap(~ smoker) +
  #adding lines to both facets
  geom_smooth(method = 'lm')
#this way also changes the color of the regression lines
ggplot(data = tips, aes(x = totbill, y = tip, colour = smoker)) +
  geom_point() +
  facet_wrap(~ smoker) +
  #adding lines to both facets
  geom_smooth(method = 'lm')
smoker.lm <- lm(tiprate ~ smoker, data = tips)
smoker.lm

#creat plots to investigate whether there is a particularly good day
#of the week for a waiter to volunteer
ggplot(data = tips, aes(x = day, y = tip)) +
  geom_boxplot()
ggplot(data = tips, aes(x = day, y = tiprate)) +
  geom_boxplot()
ggplot(data = tips, aes(x = day)) +
  geom_bar()
#this way also changes the color of the regression lines
ggplot(data = tips, aes(x = totbill, y = tip, colour = day)) +
  geom_point() +
  facet_wrap(~ day) +
  #adding lines to both facets
  geom_smooth(method = 'lm') +
  #adds an additional line/slope to compare
  #the 'suggested' tip of 15%
  geom_abline(intercept = 0, slope = .15)
day.lm <- lm(tiprate ~ day, data = tips)
day.lm
day.lm2 <- lm(tip ~ day, data = tips)
day.lm2

#create a plot that is facetted by smoking and gender
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point() +
  facet_grid(sex ~ smoker)

#shape and color are both pre-attenative, but not together
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point(aes(colour = sex, shape = smoker))
ggplot(data = tips, aes(x = totbill, y = tip)) +
  geom_point(aes(colour = interaction(sex, smoker)))


#====Lecture 8 Notes====
devtools::install_github("njtierney/visdat")
library(visdat)

happy <- read.csv("F:/School/ISU/Visual Business Analytics/Data and Markdown files/Related Materials week 07/happy.csv")
vis_miss(happy)

#Look at the statements below and describe in words what they are calculating:
rowSums(is.na(happy))
happy[complete.cases(happy),]
identical(is.na(happy$happy), !complete.cases(happy$happy))
ggplot(data = na.omit(happy), aes(x = age, fill = happy)) + geom_bar()
#Determine the average age of participants in the survey


str(happy)
is.factor(happy$region)
is.numeric(happy$region)
levels(happy$region)
happy$income
happy$marital

table(happy$income) #ordered aphabetically
#need to re-code so they are in correct order
happy$income <- factor(happy$income,
                       levels = c("LT $1000", "$1000 TO 2999",
                                  "$3000 TO 3999", "$4000 TO 4999",
                                  "$5000 TO 5999", "$6000 TO 6999",
                                  "$7000 TO 7999", "$8000 TO 9999",
                                  "$10000 - 14999", "$15000 - 19999",
                                  "$20000 - 24999", "$25000 OR MORE"))

library(ggplot2)
ggplot(data = happy, aes(x = income)) + geom_bar()
ggplot(data = happy, aes(x = income)) + geom_bar() +
  coord_flip() #puts income on horizontal level

#marital status
ggplot(data = happy, aes(x = marital)) + geom_bar() +
  coord_flip() #puts income on horizontal level

ggplot(data = happy, aes(x = marital, y = age)) + geom_boxplot() +
  coord_flip() #puts income on horizontal level

#reorder martital status by median
happy$marital <- reorder(happy$marital, happy$age, FUN = median, na.rm = T)

ggplot(data = happy, aes(x = marital, y = age)) + geom_boxplot() +
  coord_flip() #puts income on horizontal level


#try it section

# The variable finrela is a factor variable describing a participant’s
# perceived financial situation compared to the US average.
# Get the categories in the right order from lowest to highest.
head(happy)
levels(happy$finrela)
happy$finrela <- factor(happy$finrela, levels = c("FAR BELOW AVERAGE", "BELOW AVERAGE",
                                                  "AVERAGE", "ABOVE AVERAGE", "FAR ABOVE AVERAGE"))
levels(happy$finrela)

ggplot(data = happy, aes(x = finrela)) + geom_bar()

# The variable degree is the highest educational degree the
# participant has. Does ordering the categories by their median age
# bring them into an order from lowest educational degree to highest?
# Check with side-by-side boxplots of age by degree.
#reorder martital status by median
levels(happy$degree)
happy$degree <- reorder(happy$degree, happy$age, FUN = median, na.rm = T)

ggplot(data = happy, aes(x = degree, y = age)) + geom_boxplot() +
  coord_flip() #puts income on horizontal level

#add year
ggplot(data = happy, aes(x = year, fill = degree)) + geom_bar(position = 'fill')

happy$year <- factor(happy$year)
str(happy)
ggplot(data = happy, aes(x = year, fill = degree)) + geom_bar(position = 'fill')



mymean <- function(x, na.rm = F) {
  x <- as.numeric(x)
  if(na.rm == T) x <- na.omit(x)
  result <- sum(x)/length(x)
  
  return(result)
}


mymean(1:5)
mymean(c('one', 'two'))
mymean(c(1:5, NA))
mymean(c(1:5, NA), na.rm = T)


mysd <- function(x, na.rm = F) {
  x <- as.numeric(x)
  if(na.rm == T) {x <- na.omit(x)}
  
  n <- length(x)
  xbar <- mean(x)
  
  sdsq <- sum((x - xbar)^2) / (n - 1)
  
  sqrt(sdsq)
}


sd(1:5)
mysd(1:5)
mysd(c('one', 'two'))
mysd(c(1:5, NA))
mysd(c(1:5, NA), na.rm = T)

inwords <- function(x) {
  hund <- x %/% 100
  
  tens <- x %/% 10
  digi <- x %% 10
  
  
}

#====Lecture 9 Notes====

library(readr)
happy <- read_csv("F:/School/ISU/Visual Business Analytics/Data and Markdown files/Related Materials week 07/happy.csv")
happy

library(dplyr)
filter(happy, sex == "FEMALE")
arrange(filter(happy, sex == "FEMALE"), degree)
arrange(filter(happy, sex == "FEMALE"), degree, age)
arrange(filter(happy, sex == "FEMALE"), degree, desc(age))
select(happy, partyid, polviews, age)
mutate(happy, agedecade = cut(age, breaks = c(18, 25, 35, 45, 55, 65, 75, 89)))

summarise(group_by(happy, sex, marital),
          n = n(),
          meanage = mean(age, na.rm = T),
          sdage = sd(age, na.rm = T),
          missing = sum(is.na(age)))

library(ggplot2)

hdata <- happy

hdata %>% filter(!is.na(happy)) %>%
ggplot(aes(x = factor(year), fill = happy)) + geom_bar(position = 'fill')

hdata %>% filter(!is.na(happy)) %>%
  group_by(year, sex) %>%
  summarise(perchappy = sum(happy == "NOT TOO HAPPY")/n()*100,
            n = n()) %>%
  ggplot(aes(x = year, y = perchappy, colour = sex)) + geom_point() + geom_smooth()


hdata %>% filter(!is.na(happy)) %>%
  ggplot(aes(x = factor(year), fill = happy)) + geom_bar(position = 'fill')

hdata %>% filter(!is.na(happy), happy != "DK", happy != "IAP") %>%
  group_by(year, sex) %>%
  mutate(total = n()) %>%
  group_by(year, sex, happy) %>%
  summarise(perc = n()/mean(total)*100) %>%
  ggplot(aes(x = year, y = perc, colour = happy, shape = sex)) + geom_point() + geom_smooth(aes(group = happy))

#######
#how is happiness affected by ...
# gender
# age
# money

hdata %>% filter(!is.na(happy), happy != "DK", happy != "IAP") %>%
  ggplot(aes(x = age, fill = happy)) + geom_bar(position = "fill") +
  facet_grid(sex ~ .)


hdata %>% filter(!is.na(happy), happy != "DK", happy != "IAP") %>%
  ggplot(aes(x = finrela, fill = happy)) + geom_bar(position = "fill") +
  coord_flip()

#====Quizzes====
#quiz 5
y <- matrix(data = c(1, 1, 5, 3, 4, 2), nrow = 3, ncol = 2)
y

f1<- function(x, y)  c(x ^2 , x+y) 
f2 <- function(x, y)  c(x+2 , y+5)

f1(1,2)*f2(2,3)

y <- matrix(data = c(2, 1, 3, 2, 4, 3), nrow = 3, ncol = 2)
y
apply(X =y, MARGIN = 2, FUN = sd)

y <- matrix(data = c(8, 2, 2 , 4 ,1, 4, 3, 1, 4, 2), nrow = 5, ncol = 2)
y
apply(X =y, MARGIN = 2, FUN = sum)

dim(y)[2]

#quiz 6
y <- c(4, 3, 2, 4, 5, 6, 2, 4 , 8)
y==c(4, 2, 4, 2, 4, 2, 4, 2, 4)


ggplot(data = tips, aes(x = totbill, y = tip, color = sex) ) + geom_point()+ 
  ylab("Tips in US dollars") + xlab("Total bill in US dollars")
ggplot(data = tips, aes(x = time, y = totbill)  ) + geom_boxplot() +
  xlab("") + ylab("Total bill in US dollars")


ggplot(data = tips, aes(x = totbill)  ) + geom_histogram() +
  xlab("Total bill in US dollars") + facet_wrap(~time)

y <- c(2, 4, 5, 6, 5, 6, 8, 9, 10)
y[y!=6]

y <- c(1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1)
x <- y==0
table(x)
length(x)
length(y)


ggplot(data = tips, aes(x = time, y = totbill)  ) + geom_boxplot()  +
  xlab("") + ylab("Total bill in US dollars") + facet_grid(smoker ~ sex)


happy$happy <- factor(happy$happy, levels = c("pretty happy", "very   happy","not too happy"))
ggplot(data = na.omit(happy), aes (x = happy)) +geom_bar()


fs <- function(x, y, na.rm = TRUE) {
  if (na.rm == TRUE) {
    x <- na.omit(x)
    y <- na.omit(y)
  }
  if (length(x) == length(y)) {
    sumv <- x+y
  }else{
    print("x and y have different length")
  }
}
fs(c(1, 4, 6, 5), c(2, 6, 5, 3))
fs(1:3,1:5)




happy <- read.csv("F:/School/ISU/Visual Business Analytics/Data and Markdown files/Related Materials week 07/happy.csv")
ggplot(data = na.omit(happy), aes (x = age, fill =happy)) + geom_bar(position = "fill") + facet_wrap( ~sex)
ggplot(data = na.omit(happy), aes (x = age, fill = happy)) +geom_bar()   +       facet_wrap( ~sex)
ggplot(data = happy, aes (x = age, fill =happy)) + geom_bar() +   facet_wrap( ~  sex)
ggplot(data = happy, aes (x = age, fill =happy)) + geom_histogram() +     facet_wrap( ~sex)




sfun1 <- function(x) {
  c(mean(x), median(x), sd(x), mad(x), IQR(x))
}

sfun2 <- function(x) {
  c(mean(x, na.rm = TRUE),
    median(x, na.rm = TRUE),
    sd(x, na.rm = TRUE),
    mad(x, na.rm = TRUE),
    IQR(x, na.rm = TRUE))
}

sfun1(1:3); sfun2(c(NA,1,NA,3,NA,2))
sfun1(rep(2,3))
sfun2(c(2,3))
sfun1(1:5)[3]
median(1:5)



fs <- function(x, y, na.rm = TRUE) {
  if (na.rm == TRUE) {
    x <- na.omit(x)
    y <- na.omit(y)
  }
  if (length(x) == length(y)) {
    sumv <- x+y
  }else{
    print("x and y have different length")
  }
}
fs(c(1, "A", 2), c(1, 2, 3)); c(2, "A +2",  5 )
fs(c(1, 4, 6, 5), c(2, 6, 5, 3))
fs(1:3,1:5)
fs(1:3, 1:3); fs(1:3, c(1, 2, NA, 3))
f2 <- function(val, y){
  if(length(val)!=1) stop("val should be a number")
  if (val > 0) {
    log(y)
  } else {
    (y ^ val)/length(y)
  }
  
}
f2(1:3, 1:3)
f2(0,1:3)
f2(10, c(9, 9, 5))
happy$happy <- factor(happy$happy, levels = c("pretty happy", "very   happy","not too happy"))
ggplot(data = na.omit(happy), aes (x = happy)) +geom_bar()
