# Comments:
# Using a # will stop R from reading the rest of the line.
# That allows you to leave comments, instructions, and annotations in your programs
# without tripping R up at run time

# Code blocks:
# If you want your code to be collapsable into chunks, end a comment line with multiple
# hyphens or pound signs. See below sections for example. Click on the triangles in the margins to collapse/expand

#      Source Files:                                          ------------

# A source file is an R script designed to be called externally.
#
# When sourced, the entire file is executed in the background.
#
# That allows you to load functions from other scripts that
# would be cumbersome to copy and paste into your own code.
#
# Example, backing up L:/R-Programs
# Since I have already written code to search for and create backup copies of all
# R, C++, and C files in L:/R-Programs, it is much easier for you to simply run my
# code than to re-write your own functions or perform the task manually.
# To load my code for backing up L:/R-Programs, first call

source("L:R-Programs\\_Source Scripts\\__CreateBackUp.R")

# Now the CreateBackUp function (contained in L:R-Programs\\_Source Scripts\\__CreateBackUp.R)
# is available for you to use. Try it now:

CreateBackUp()

# As you can see, source scripts are a great way to reuse existing code while keeping your own
# programs clutter free.

#      Benchmark datasets:                                   ------------

# R contains several built-in data sets that are available for testing your programs on
# You can load them into your workspace by setting them to data frame objects
# Often packages come with example datasets too.
# To see what datasets are available, run:

data()

# to use one of the datasets, either call it directly like so:

head(diamonds)
hist(diamonds$price, col = "goldenrod") #histogram of diamond price with color set as goldenrod

# or you can create a datafram like so

df = data.frame(diamonds)
head(df)
plot(price ~ carat, data = df,
     col = rgb(0,161,161,4, maxColorValue = 255), pch = 16,
     xlim = c(0,3))
# plot price <given> carat for the dataframe called df. Use a blue-green semi transparant color and a different type of point
# xlim sets limit on x axis between 0 and 3

# Some other good datasets to use are:

# quakes          spatial data
# pressure        continious x,y data
# swiss           socio-economic
# C02             mixed categorical / continious
# mtcars          mixed categorical / continious / integer
# treering        single variable time series
# airquality      multi vairate time series
# EuStockMarkets  multiple single variable time series
# iris            for classification of categorical variable

#       (Basic) Statistical models                            -------------

#first we'll make some data
df = data.frame(mpg)
head(df)

#transmission is messy, I want to just have auto vs manual
df$trans2 = ifelse(grepl("manual",df$trans), "manual", "auto")
#make trans2 = "manual" wherever "manual" is found in trans, otherwise make trans2 = "auto
boxplot(df$cty ~ df$trans2) #boxplot vs city mpg

#ANOVA
#to make an ANOVA of mpg for city driving by transmission and car class
modANOVA = aov(cty ~ trans2 + class, data = df)
# there are several ways to get a summary

# You can call summary to get a p value
summary(modANOVA)
#diagnositc plots
plot(modANOVA)



# REGRESSION
#to make a linear regression for city mpg by displacement and cylenders
modLM = lm(cty ~ displ + cyl, data = df)
summary(modLM)
#diagnositc plots
plot(modLM)

# GLM
#You can also just use a glm
modGLM = lm(cty ~ displ + cyl + trans2 + class, data = df)
summary(modGLM)

# To get predicted values
predicted = predict(modGLM, df, type = "response")

# now see predicted vs fit
plot(df$cty ~ predicted)

#add linear trend line between x and y
abline(lm(df$cty ~ predicted))


