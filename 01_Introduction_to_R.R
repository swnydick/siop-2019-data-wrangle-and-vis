rm(list = ls())
library(car)
detach("package:car", unload = TRUE)
opts_chunk$set(size      = "footnotesize",
               tidy      = FALSE,
               fig.align = "center",
               out.width = "0.48\\textwidth",
               dev       = "pdf")
# Simple sums
4 + 15

# products
10 * 30
# Simple sums
4 + 9

# products
4 * 9
# log is the natural log (ln)
log(1000)
# Use log10 or log(x, base = 10) to get base 10
log(1000, base = 10)

log10(1000)
log(42, base = 4)
((3 * sin(pi / 6) + 32) / sqrt(23) + 2) - 0.9
weight   <- 210
height   <- 74
constant <- 703
bmi      <- (weight * constant)/height ^ 2
bmi
weight <- weight - 20
bmi
## What happened?
bmi      <- (weight * constant)/height ^ 2
bmi
BMI
# What happened?
bmi
ls()
ls()
bmi
rm("bmi")
ls() 
bmi
ls()

# Etch-A-Sketch End of The World! 
# Clear the whole workspace!
rm(list = ls())
ls()
# data input
height <- c( 60,  62,  61,  65,  69,  70)
# in inches
weight <- c(135, 155, 145, 155, 164, 178)  
# in lbs
sex    <- c("f", "m", "f", "f", "m", "m")
# bmi = weight (lb) per height (inches) squared
constant <- 703
bmi      <- (weight  * constant )/ height^2
length(bmi)
length(constant)
mean(weight)
median(height)
quantile(bmi)
mean(sex)
# find the class of the objects
class(bmi)
class(sex)
height[3] 
bmi[c(4, 5, 6)]
bmi[4:6]
males <- sex == "m"
males
height[males]

# can combine the work into one line, e.g., height of females:
height[sex == "f"]
idx <- which(sex == "m")
idx 
height[idx]
# help("&")
idx <- sex == "m" & height > 66
bmi[idx]
idx <- sex == "f" | height < 63
bmi[idx]
sex[idx]
plot(height, weight)
plot(bmi, height)
my_df <- data.frame(weight, height)

# Calculate the mean height
mean(my_df$height)
# Calculate the mean weight
mean(my_df$weight)
my_df$gender <- sex
my_df$bmi <- (my_df$weight * 703)/my_df$height ^ 2
## # install the "Grammar of Graphics" package
## install.packages("ggplot2")
# quick graph 
library(ggplot2)
qplot(height,weight) 
