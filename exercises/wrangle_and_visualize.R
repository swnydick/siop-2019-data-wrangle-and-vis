# Here's a condensed script of everything we do to the data in the tutorial.
# Take a look through at the end and recap what you've learned!

require(openxlsx)
require(reshape2)
require(dplyr)
require(magrittr)
require(ggplot2)
require(ggthemes)
require(roperators)

employees <- read.csv("data/employee_data.csv", stringsAsFactors = FALSE)
survey    <- read.xlsx("data/survey_results.xlsx")

employees$age[employees$age == ".."] <- NA

# mutate in dplyr to create/modify columns in the dataframe
# note the reassignment pipe
employees %<>% mutate(age          = as.numeric(age),
                      h_date       = as.Date(h_date, format = "%m/%d/%Y"),
                      tenure       = as.numeric(Sys.Date() - h_date)/365.2422,
                      tenure_label = cut(tenure,
                                         breaks = c(0, 1, 2, 5, 10, Inf),
                                         labels = c("<1 year", "1-2 years",
                                                    "2-5 years", "5-10 years",
                                                    "10+ years"),
                                         right = FALSE,
                                         ordered_result = TRUE),
                      employee_id  = as.character(employee_id))

# all the reshaping in one
survey %<>% melt(id.vars = "question",
                 variable.name = "id",
                 value.name = "score") %>%
            dcast(id ~ question) %>%
            mutate(id = as.character(id))

# bonus: can you rewrite that last pipeline to reformat survey and pipe into a join?
# you may want to think about left vs right joins
all_data <- left_join(employees, survey,
                      by = c("employee_id" = "id"))

all_data %>%
  filter((gender == "female" & sector == "manufacturing" & age > 40)|
         (gender == "male"   & sector == "manufacturing" & age > 40)) %>%
  select(gender, age, sector, q1:q4) %>%
  group_by(gender) %>%
  summarise(avg_q1 = mean(q1),
            avg_q2 = mean(q2),
            avg_q3 = mean(q3),
            avg_q4 = mean(q4))

all_data %>% #take all_data THEN
  group_by(sector) %>% #group it by sector THEN
  summarise(p = mean(q4)) %>% #average of q1 across each group THEN
  ggplot(aes(x = sector, y = p)) + # put it into a plot and add...
  geom_bar(stat = "identity", fill = "turquoise", alpha = 0.5) + # ...bars and...
  ylab("Q4 Response Rate") #

all_data %>% #take all_data THEN
  group_by(sector) %>% #group it by sector THEN
  summarise(p  = mean(q4),
            q  = 1-p,
            n  = n(),
            sd = sqrt((p*q)/n)) %>% #average of q1 across each group THEN
  ggplot(aes(x = sector, y = p)) + # put it into a plot and add...
  geom_bar(stat = "identity", fill = "forest green", alpha = 0.5) + # ...bars and...
  geom_errorbar(aes(ymin = p - sd, ymax = p + sd), width = 0.5) +
  ylab("Average Q4 Response") # ...a custom y axis label

all_data %>% #take all_data THEN
  group_by(gender, sector) %>% #group it by sector THEN
  summarise(p  = mean(q4),
            q  = 1-p,
            n  = n(),
            sd = sqrt((p*q)/n)) %>%
  ggplot(aes(x = sector, y = p)) +
  geom_bar(stat = "identity", position = "dodge",
           aes(fill = gender, linetype = sector)) +
  geom_errorbar(aes(ymin = p - sd, ymax = p + sd,
                    linetype = gender, size = sector, color = sd),
                size = 2, position = "dodge")


all_data %>%
  filter(sector %in% c("sales", "manufacturing", "finance")) %>%
  ggplot(aes(x = age, y = q3, color = sector)) +
  geom_point(alpha = 0.4, aes(color = sector)) +
  geom_smooth(method = "lm", aes(fill = sector), na.rm = TRUE) +
  theme_solarized() +
  ylab("Question 3: Average Rating") +
  labs(fill = expression(paste("Prediction\nError =", sqrt(over(sum(("Y" - "Y'"))^2, "N"))))) +
  scale_fill_solarized() +
  scale_color_solarized(guide = FALSE)


