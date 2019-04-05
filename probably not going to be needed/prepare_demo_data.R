require(dplyr)
require(roperators)
require(magrittr)
require(reshape2)
require(openxlsx)

# Create fake HR data  =========================================================
set.seed(1984)
hr_data <- read.csv("data/hr.csv")

sectors <- c("admin", "finance", "manufacturing", "sales")
hr_data$sector <- sample(sectors, nrow(hr_data), replace = TRUE)

hr_data %<>% select(-c(p01:p04))

hr_data$age[hr_data$age > 120] %/=% 10

# Some fake survey responses

fake_q1 <- function(x){
  random_noise <- rnorm(1, 1, 0.5)
  engagement   <- (x$age-mean(hr_data$age))/sd(hr_data$age) * random_noise
  return(engagement + 3.18)
}

fake_q2 <- function(x){

  result <- numeric(length(x$sector))

  for(i in seq_along(result)){
    random_noise <- rnorm(1, 1, 0.5)
    result[i]    <- (x$age[i]-mean(x$age))/sd(x$age) * random_noise
    if(x$sector[i] == "finance") result[i] <- result[i]*0.73 + 2.45
    if(x$sector[i] == "manufacturing") result[i] <- result[i]*1.55 + 3.2
    if(x$sector[i] == "sales") result[i] <- result[i]*0.42 + 1.96
    if(x$sector[i] == "admin") result[i] <- result[i]*0.42 + 2.75
  }
  return(result)
}


fake_q3 <- function(x){
  result       <- rnorm(length(x$sector),3,.8)
  random_noise <- rnorm(length(x$sector), 1, .1)
  result <- result + (random_noise* (x$q2 - mean(x$q2)))
}

fake_q4 <- function(x){

  result <- logical(length(x$sector))

  for(i in 1:length(x$sector)){
    rnum <- runif(1)
    cutoff <- switch (x$sector[i],
                      "admin" = 0.4,
                      "sales" = 0.45,
                      "manufacturing" = 0.575,
                      "finance" = .625
    )

    if(x$gender[i] == "male") cutoff %+=% .1825

    if(rnum < cutoff) result[i] <- TRUE
    else result[i] <- FALSE
  }

  return(result)
}

hr_data$q1 <- fake_q1(hr_data)
hr_data$q2 <- fake_q2(hr_data)
hr_data$q3 <- fake_q3(hr_data)
hr_data$q4 <- fake_q4(hr_data)

head(hr_data)

# Split into two files for merging  ============================================

employee_data <- hr_data[, c("employee_id", "gender", "age", "h_date", "sector")]
survey_data   <- hr_data[, c("employee_id", "q1", "q2", "q3", "q4")]


# Cast one into wide  ==========================================================

# make this awful...
survey_data_long <- survey_data %>%
                    melt(id.vars = "employee_id", variable.name = "question") %>%
                    arrange(employee_id)

survey_data_wide <- survey_data_long %>%
                    dcast(question ~ employee_id)


melt(survey_data_wide, id.vars = "question", variable.name = "id", value.name = "score") %>%
dcast(id ~ question) %>%
head()

# gross
write.xlsx(survey_data_wide, "data/survey_results.xlsx")


# Screw up some variables ======================================================

# mess up some ages

employee_data$age %+=% runif(nrow(employee_data), -5, 5)
employee_data$age %<>% round()
employee_data$age %<>% sapply(max, 18)

employee_data$age[c(3, 18, 36, 42, 64, 99)] <- ".."

write.csv(employee_data, "data/employee_data.csv", row.names = FALSE)

