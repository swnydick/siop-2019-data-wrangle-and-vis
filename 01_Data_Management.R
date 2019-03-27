
# Today:

require(lubridate)
require(magrittr)
require(dplyr)
require(reshape2)
require(stringr)
require(ggplot2)

## ## Don't run this code
## responses <- read.table(file = "C://path/to/responses.csv",
##                         header = T,sep = ",")
## ## Read.csv is a shortcut function
## responses <- read.csv("C://path/to/responses.csv")


hr_df <- read.csv("data/hr.csv")
head(hr_df)
tail(hr_df)
str(hr_df)
nrow(hr_df)
summary(hr_df)


## library(readr)
## hr_df <- read_csv("../data/hr.csv")
## library(dplyr)
## class(hr_df)
## ## convert an existing dataframe to a tbl_df
## mtcars <- tbl_df(mtcars)
hr_df$p_sum <- hr_df$p01 + hr_df$p02 + hr_df$p03 + hr_df$p04
names(hr_df)
hr_df <-
  mutate(hr_df,
       p_sum = p01 + p02 + p03 + p04)
names(hr_df)
hr_df$agecat <- cut(hr_df$age,
                    right = FALSE,
                    breaks=c(0,30,40,99),
                    labels = c("Under 30","30's","40 and over"))

# Use table to check the resulting variable
table(hr_df$agecat)
hr_df <-
  mutate(hr_df,
         agecat=cut(age,
                    right = FALSE,
                    breaks=c(0,30,40,99),
                    labels = c("Under 30","30's","40 and over")))
levels(hr_df$agecat)
# Change the levels
levels(hr_df$agecat) <- c("Less than 30", "Thirties", "40 plus")
head(hr_df$agecat)
levels(hr_df$agecat)
# Change the levels
levels(hr_df$agecat)[levels(hr_df$agecat) == "Less than 30"] <-
  c("Twenties")
head(hr_df$agecat)
hr_df$gender <- factor(hr_df$gender)
levels(hr_df$gender)
levels(hr_df$gender)[levels(hr_df$gender) == "female"] <- "F"
levels(hr_df$gender)[levels(hr_df$gender) == "male"] <- "M"
names(hr_df)
# Displays the names
names(hr_df)[4] <- "hire_date"
names(hr_df)
names(hr_df)
names(hr_df)[names(hr_df) == "age"] <- "age.raw"
names(hr_df)
library(dplyr)
hr_df <- rename(hr_df,p1 = p01,p2 = p02, p3=p03, p4=p04)
names(hr_df)
order(hr_df$age.raw)
hr_df[order(hr_df$age.raw), ]
hr_df[order(hr_df$gender, desc(hr_df$age.raw)), ]
hr_df[order(hr_df$gender, -hr_df$age.raw), ]
head(arrange(hr_df, gender, desc(age.raw)))
names(mtcars)
new.df <- mtcars[c("wt", "mpg")]
names(new.df)
names(mtcars[, c(6, 1)])
# using -
names(mtcars)
names(mtcars[, -c(6, 1)])

# using NULL
df <- mtcars
df$mpg <- NULL
names(df)
(hr_df$gender == "M" & hr_df$age.raw > 30)
idx <- which(hr_df$gender == "M" & hr_df$age.raw > 30)
newdata <- hr_df[idx, ]
newdata <- subset(hr_df,
                  gender == "M" & age.raw > 25,
                  select = c(gender:p4, agecat))
summary(newdata)
newdata2 <- droplevels(newdata)
summary(newdata2)
filter(hr_df, gender == "M", age.raw > 25)
# Equivalent, the "and" is the default join
filter(hr_df,
       gender == "M" & age.raw > 25)
# Use the or condition
filter(hr_df,
       gender == "M" | age.raw > 25)
# Select columns
select(hr_df,c(gender:p4, agecat))
# Nested commands
select(filter(hr_df, gender == "M"),
       gender:p4)
# Chained commands using %>%
hr_df %>%
  filter(gender == "M") %>%
  select(gender:p4)
dates <- as.Date(c("2012-12-01", "2012-01-12"))
dates
class(dates)
library(lubridate)
dates <- ymd(c("2012-12-01", "2012-01-12"))
dates
class(dates)
dates <- as.Date(c("01/14/2011", "02/25/2012"),
                 format = "%m/%d/%Y")
dates
dates <- mdy(c("01/14/2011", "02/25/2012"))
dates
format(dates,"%B %d %y")
format(dates,"%b %d %Y %A")
wday(dates)
month(dates)
year(dates)
quarter(dates)
dates[1] - dates[2]
difftime(dates[1], dates[2], units="weeks")
hr_df$hire_date_new <- as.Date(hr_df$hire_date)
hr_df$Time_Worked <-
  as.Date("2015-01-01") - hr_df$hire_date_new
xx <- c(3, 5, 8, NA, 9, NA, 12)
xx
is.na(xx)
!is.na(xx)
sum(hr_df$p4)
sum(hr_df$p4,na.rm=TRUE)
mean(hr_df$p4)
mean(hr_df$p4,na.rm=TRUE)
newdata <- na.omit(hr_df)
head(newdata,3)
tf <- complete.cases(hr_df[,5:8])
head(hr_df[tf,])
# Applying the is.na() function in two dimensions
head(is.na(hr_df[, 5:8]))
a <- c(1, 2, 3)
a
is.numeric(a)
is.vector(a)
a <- as.character(a)
a
is.vector(a)
is.character(a)
type <- c("AA","BA","AA","O","AB","BB")
is.character(type)
type <- factor(type)
type
is.factor(type)
as.character(type)
ID <- 121:108
is.numeric(ID)
ID <- factor(ID)
ID
is.factor(type)
as.numeric(ID)
xx <- 1:50
sample(xx, 10, replace = FALSE)
set.seed(42)
mtcars[sample(1:nrow(mtcars), 10, replace = FALSE), ]
mtcars[sample(1:nrow(mtcars), 10, replace = FALSE), ]
set.seed(42)
sample_n(mtcars,4,replace = T)
sample_frac(mtcars,.1,replace = T)
set.seed(42)
idx <- sample(1:nrow(hr_df), size = 30, replace = FALSE)
newdat <- hr_df[idx, ]
table(newdat$employee_id)
sample_frac(hr_df,.1, replace = F)
df1 <- data.frame(Cust_ID = c(10:12),
                  Acc_ID = c(110:115),
                  AccType    = c(rep("Checking", 3),
                                 rep("Saving", 3)))
df2 <- data.frame(Customer_ID = c(10:11),
                  State      = c("Oklahoma",
                                 "Texas"))
df3 <- data.frame(Customer_ID = c(10:12),
                  Credit      = c(rep("Bad", 1),
                                 rep("Good", 2)))
# outer join
merge(x = df1, y = df2, by.x = "Cust_ID",
      by.y= "Customer_ID", all = TRUE)

# outer join
merge(x = df1, y = df2, by.x = "Cust_ID",
      by.y= "Customer_ID", all = TRUE)

# left outer
merge(x = df1, y = df2, by.x = "Cust_ID",
      by.y= "Customer_ID", all.x = TRUE)

# right outer
merge(x = df2, y = df3, by = "Customer_ID", all.y = TRUE)
# inner join
inner_join(df2,df3, by= "Customer_ID")
# outer left join
left_join(df2,df3, by= "Customer_ID")
# outer right join
right_join(df2,df3, by= "Customer_ID")
# Full join
full_join(df2,df3, by= "Customer_ID")
df1 <- data.frame(id     = 1:6,
                  age    = 20:25,
                  height = 60:65)
df2 <- data.frame(hair   = rep("brown", 6),
                  weight = seq(140, 160, length = 6))
df3 <- data.frame(id     = 7:8,
                  age    = 26:27,
                  height = 66:67)
rbind(df1,df3)
cbind(df1,df2)

