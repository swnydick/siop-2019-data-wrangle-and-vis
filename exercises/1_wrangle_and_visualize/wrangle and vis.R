require(openxlsx)
require(reshape2)
require(dplyr)
require(magrittr)
require(ggplot2)
require(ggthemes)
require(roperators)

employees <- read.csv("../data/employee_data.csv", stringsAsFactors = FALSE)

survey <- read.xlsx("../data/survey_results.xlsx")

employees$age[employees$age == ".."] <- NA
employees$age                        <- as.numeric(employees$age)

employees$h_date <- as.Date(employees$h_date, format = "%m/%d/%Y")

employees$tenure <- as.numeric(Sys.Date() - employees$h_date)/365.2422

employees$tenure_label <- cut(employees$tenure,
                              breaks = c(0, 1, 2, 5, 10, Inf),
                              labels = c("<1 year", "1-2 years",
                                         "2-5 years", "5-10 years",
                                         "10+ years"),
                              right = FALSE,
                              ordered_result = TRUE)

survey <- melt(survey,
               id.vars = "question",
               variable.name = "id",
               value.name = "score")

survey <- dcast(survey, id ~ question)

employees$employee_id <- as.character(employees$employee_id)
survey$id             <- as.character(survey$id)
all_data              <- left_join(employees, survey,
                                   by = c("employee_id" = "id"))

