

Now, inspect the data you've loaded either from within RStudio's `Environment` tab, or by the `View()` command.

```{r eval=FALSE}
View(wiki)
View(worldbank)
names(worldbank)
```

`wiki` is okay, but `worldbank` has some serious problems:

  1) Missing values are coded as ".." which has turned all of the numeric columns into text!
  2) Values from each year are placed in different columns
3) Variables are seperated by row, not column meaning in each row are from different variables hence the yearly column statistics are meaningless
4) More than one row per observation (country & year)

Happily *this is easy to fix*

  </br>

  ## Recoding the missing values

  Firstly, let's replace those ".." missing value codes with missing values (`NA`). We also want to convert the yearly columns into a `numeric` type. Think about the logic we want to use: we want to go through the columns of `worldbank` and in the year columns, which are named like `####.[YR####]`, turn all cells with `..` into `NA`, and then convert the columns into `numeric`.

Happily, this is all rather easy, but replacing the `..`s will requie a _regular expression_ (periods are a bit tricky to deal with). _Regular expressions_ are a tricky subject, basically they're specially formatted text used to select specific formats of text. You can use _regular expression_`s to do some very complicated text manipulation - but it's more efficient to just look on <http://stackoverflow.com/questions/tagged/regex> for an existing example of something similar to what you're wanting to do.

Note that the below code is a bit odd...
```{r fix_na}
# You could also use an apply statement, but that is harder to read
for(this_column in names(worldbank)){
  if(grepl("YR", this_column)){
    # if "YR" is in this column name...
    worldbank[[this_column]] %regex<-% c("\\.\\.", NA)
    worldbank[[this_column]] <- num(worldbank[[this_column]])
    # Without roperators:
    # worldbank[[this_column]] <- as.numeric(gsub("\\.\\.", NA, worldbank[[this_column]]))
  }
}

```



For the sake of demonstration, we can also subset out the `Country.Code` and `Series.Code` columns like so:

  ```{r subset}
df <- select(worldbank, which(!names(worldbank) %in% c("Country.Code", "Series.Code")))
```

I've cast that into a new `tibble` (a dataframe with some `dplyr` extras) called `df` - that will make it easier to go back and redo things, it also makes it easier to reference.

Take a look at `df` now, in particular the yearly value columns.
```{r eval = FALSE}
View(df)
```

</br>

## Transform into long format

Now, we can focus on turning `df` into a (useable) _long format_ dataset by gathering all of the year colluns together and spreading out the values of the `Series.Name` into different columns. This is where `tidyr` comes in handy.
</br>

### Gather the yearly data together

`tidyr` has a handy function called `gather()` to do just this. You only need to specify:

*`data`
*`key`  - what the resulting aggregated variable will be called
*`value` - what the new column for values will be called

```{r gather}
df2 <- gather(df, key = year, value = value, -c(Country.Name, Series.Name))
head(df2, 5)
```

This is much better, but we still have to deal with

1) ~~Missing values are coded as ".." which has turned all of the numeric columns into text!~~
2) ~~Values from each year are placed in different columns~~
3) Variables are seperated by row, not column meaning in each row are from different variables hence the yearly column statistics are meaningless
4) More than one row per observation (country & year)

But now...

5) Year is a single column, but it is far from a nice number

To turn the values of `year` into nice `integers`, another regular expression is needed:

```{r regex_2}
df2$year %regex=% c("\\..*", "")
df2$year <- int(df2$year)
#<- as.integer(gsub("\\..*","",df2$year))
head(df2)
```

Fixed. Now, to fix our last remaining issues.
</br>

### Spread out each series into its own column

To fix our 3^rd^ and 4^th^ problems, we'll need to spread out the `Series.Name` column. Again, `tidyr` makes that easy for us.

`tidyr` has a handy function called `spread()` to do just this. You only need to specify:

  *`data`
*`key`  - The column whose values will be used as column headings
*`value` - The column whose values will populate the cells.

```{r spread}
df3 <- spread(df2, key = Series.Name, value =  value)
```
```{r eval=FALSE}
View(df3)
```


Excellent! Your data should now be in long format. All we need to do is add our region labels that we pulled from Wiki earlier and we'll be ready to do some work.


1) ~~Missing values are coded as ".." which has turned all of the numeric columns into text!~~
2) ~~Values from each year are placed in different columns~~
3) ~~Variables are seperated by row, not column meaning in each row are from different variables hence the yearly column statistics are meaningless~~
4) ~~More than one row per observation (country & year)~~
5) ~~Year is a single column, but it if far from a nice number~~



</br>

## Join the two datasets together

There are several different ways to join data in R, be it base R, `dplyr`, or `data.table` (which wears the performance crown at the moment). Here, we'll only focus on staying within the __tidyverse__ by `dplyr` to join two datasets.

First, rename the `Country.Name` column in `df3` to match the `Country` column in the `wiki` data. Remember that `dplyr` requires that you merge on columns with the same names.

```{r as_dt}
# Remember we need to explicitly change df3
df3 <- rename(df3, Country = Country.Name)
```

Then check for any countries in our data, `df3`, that don't match up to the names in the `wiki` data. This is a common issue with matching countries such as the Democratic People's Republic of Korea aka North Korea, DPRK, and Dem Rep Korea.

```{r set_key}
uniq_df   <- unique(df3$Country)
uniq_wiki <- unique(wiki$Country)

## Print the mismatched names from df3 and wiki
uniq_df[!uniq_df %in% uniq_wiki]
# sort(uniq_wiki[!uniq_wiki %in% uniq_df]) # This prints a lot
```

There are quite a few mismatches, in practice we'd want to fix all of them, but for the sake of time (and tedium) we'll only change a few...

```{r fix_countries}
# Feel free to copy and paste!!
# (in reality I'd have a lookup table as a seperate file to tidy up my code)
# Country names we want to change in wiki data
country_wiki <- c("Tanzania, United Republic of", "Korea, Democratic People's Republic of",
                  "Korea, Republic of" , "Iran, Islamic Republic of", "Congo, The Democratic Republic of the",
                  "Moldova, Republic of", "Hong Kong", "Egypt","Yemen")
# What to change them to
country_df <- c("Tanzania", "Korea, Dem. People’s Rep.",  "Korea, Rep." ,
                "Iran, Islamic Rep.", "Congo, Dem. Rep.", "Moldova",
                "Hong Kong SAR, China", "Egypt, Arab Rep.","Yemen, Rep.")
idx <- 1
for(x in country_wiki){
  # print(x)
  # print(idx)
  wiki$Country[wiki$Country == x] <- country_df[idx]
  idx %+=% 1
}


```

Now that the ID columns match, you can use `dplyr` to merge the two together. We'll want

```{r join, warning=FALSE}
df_full <- left_join(df3, wiki, by = "Country")
```
</br>

Inspect dt_full now - note the last two columns.

### Left vs Right joins

We use a left join because we care about the `df3` data i.e. keep `dt3`'s data, fill in fields that aren't matched in `wiki` with `NA`.


</br>


## `dplyr`

We just used `dplyr` to merge our datasets with `left_join`, let's take a more detailed look at it and see why it's currently the most popular R package. Think of `dplyr` like a data manipulation pipeline. While a lot of its fucntions can be achieved in base R, it offers a cleaner syntax while allowing opperations to be chained together. The syntax invokes the pipe opperator, `%>%`, which passes the result of one opperation to the next. You can think of `%>%` as meaning **THEN**

The workfolow therefore becomes:

`function_1(data) %>%`
  `function_2 %>%`
  `function_3`

Where results are returned at the end of the pipeline and data are passed implicitly from `function_1` to `function_2` and from `function_2` to `function_3`


### The verbs of `dplyr` we will use

`dplyr` has quite a few functions (including its own version of joins), the main ones we will focus on here are:

*`filter`    - Get a subset of rows
*`select`    - Get a subset of columns
*`group_by`  - Tag data for grouped calculations
*`summarise` - Create aggregated data summaries and apply functions to data
*`mutate`    - Add a new variable (also works with grouped data)
*`rename`    - Rename variables
*`arrange`   - Sort the data by selected columns
*`do`        - Do an arbitrary thing


## Try using the verbs

### `rename` some variables

Make the long an cumbersome names to something nicer - note syntax looks backward

```{r}
# Note the back quotes for non-standard column names
df_full <- rename(df_full, growth = `GDP growth (annual %)`,
                  inflation = `Inflation, consumer prices (annual %)`)
```

### `select` the important data

Take a subset of columns you'll actually use here
```{r}
df_sub <- select(df_full, Country, Region, year, growth, inflation)
names(df_sub)
```

### Use `select` to rearrange columns
```{r}
# Before
names(df_sub)

# After (use everything() as a shortcut for everything else)
df_sub <- select(df_sub, year, Region, everything())
names(df_sub)

```


### `filter` to take a subset of rows

Find all African countries that begin with an S
```{r}
filter(wiki, Region == "Africa" & grepl("^S", Country))
```


### `group_by` and `summarise`- time to chain

Find the average growth for all African countries that begin with an S
```{r}
df_sub %>%
  filter(Region == "Africa" & grepl("^S", Country)) %>%
  group_by(Country) %>%
  summarise(avg_growth = mean(growth, na.rm = TRUE))

```


### ...then `arrange` the previous summary by average growth

```{r}
df_sub %>%
  filter(Region == "Africa" & grepl("^S", Country)) %>%
  group_by(Country) %>%
  summarise(avg_growth = mean(growth, na.rm = TRUE)) %>%
  arrange(desc(avg_growth))

```

### `do` something a bit different

Let's try regressions between inflation and growth in our African countries that begin with S

```{r}
df_sub %>%
  filter(Region == "Africa" & grepl("^S", Country)) %>%
  group_by(Country) %>%
  do(model_list = lm(inflation ~ growth + year, data = . )) %>%
  # Since data isn't the first argument in lm(), normal piping won't work
  # To get around that, we use a . to refer to the dataframe in the pipe
  broom::tidy(model_list) %>%
  # broom::tidy(object_list) unpacks the models we made into a tible
  # Let's find only significant year effects
filter(p.value < 0.05 & term == "year")


```



### Saving with `->`

It can be handy to save results, you can do that nicely with the right-assignment
arrow at the end of your pipeline like so:

  ```{r}
df_sub %>%
  filter(year > 2000) %>%
  group_by(Country, Region) %>%
  summarise(av_growth = round(mean(growth, na.rm = TRUE),1),
            av_inflation = round(mean(inflation, na.rm = TRUE),1)) ->
  df4

```

### Pipe and save with `%<>%

Furthermore, if you want to use a pipeline and save over the original data at the end,
you can use one of the most underrated `magrittr` functions to do just that: `%<>%`

let's sort the factor levels in df4
such that they're in descending order relative to average growth. Happily
it's just a matter of turning `Country`
into a factor [again] with levels in the order that they aoppear in df4.

```{r}
# To sort the rows of df4 by averge growth in descending order....
df4 %<>%
  ungroup() %>%  # The group by country we did earlier still holds so we need to ungroup it
  arrange(-(av_growth)) %>%
  mutate(Country = factor(.$Country, levels = .$Country))

# You can use . to refer to the data in the pipe in its present state -
# we did that because we want to feed in the factor levels as a sorted vector


```


## `ggplot2` & making graphs with help from `dplyr`


Now, let's combine `ggplot2` and `dplyr` to show a graph of average growth and inflation
from only countries from Europe and North America.

```{r}
df4 %>%
  filter(Region %in% c("Europe","Asia & Pacific","Arab States") &
           av_inflation < 100) %>%
  ggplot(aes(x = av_growth, y = av_inflation, color = Region,
             fill = Region)) +
  # aes = aesthetic mapping, or what data ggplot will draw figures to
  geom_point() +
  geom_smooth(method = lm, formula = y ~ x + poly(x,2))+
  # geom_ribbon
  theme_fivethirtyeight() + # from ggthemes package
  scale_color_fivethirtyeight() +
  scale_fill_fivethirtyeight() +
  xlab("Average GDP growth") +
  ylab("Average inflation")
```


Now, on to something a little more complicated

#TODO ggthemes seems a bit poorly now...

```{r}
df4 %>%
  filter(Region %in% c("Europe", "North America")) %>%
  ggplot(aes(x = Country, y = av_growth)) +
  geom_bar(stat = "identity", alpha = 0.7, aes(fill = av_growth < 0)) +
  theme_solarized() +
  # a dashed horozontal line at 1
  geom_hline(aes(yintercept = 0), linetype = "dashed", size = 1) +
  # change the y label
  ylab("Average yearly growth since 2000") +
  # put the x-axis text on an angle
  theme(axis.text.x = element_text(angle = 90)) +
  # use a colorscheme to match the theme
  scale_fill_solarized(guide = FALSE) +
  # set the y axis ticks be
  scale_y_continuous(breaks = seq(from = -5, to = 5,by = .5)) +
  # Add label for the US
  geom_label(data=subset(df4, Country == "United States"),
             aes(label="USA"), vjust = 0, nudge_y = 0.02) +
  geom_label(data=subset(df4, Country == "Canada"),
             aes(label="Canada"), vjust = 0, nudge_y = 0.02)

```





<!-- dt5 <- select(df_full, Region, inflation, year) %>% -->
  <!--   filter(year > 2000 & -->
                  <!--            Region != "Unknown" & -->
                  <!--            Region != "CIS" & -->
                  <!--            !is.na(Region) ) %>% -->
  <!--   group_by(Region) %>% -->
  <!--   summarise(av_inflation = round(mean(inflation, na.rm = TRUE),1), -->
                     <!--             sd_inflation = round(sd(inflation, na.rm = TRUE),1)) %>% -->
  <!--   arrange(-av_inflation) %>% -->
  <!--   mutate(region = factor(Region, levels = Region)) -->

  <!-- ggplot(dt5, aes(x = region, y = av_inflation)) + -->
  <!--   geom_bar(stat = "identity") + -->
  <!--   geom_errorbar(aes(ymin = av_inflation - sd_inflation, ymax = av_inflation + sd_inflation)) -->




  <!-- # Group my data by region and year  %>% (THEN) -->
  <!-- # Create summary statistics  %>% (THEN) -->
  <!-- # Filter to the regions we want to look at  %>% (THEN) -->
  <!-- # Make a plot -->
  <!-- group_by(dt_full, Region, year) %>% -->
  <!--   summarise(fertility = mean(`Fertility rate, total (births per woman)`, na.rm = T), -->
                     <!--             life_expectancy = mean(`Life expectancy at birth, total (years)`, na.rm = T), -->
                     <!--             se_lifeexp = sd(`Life expectancy at birth, total (years)`, na.rm = T)/sqrt(n()), -->
                     <!--             gdp_percapita = mean(`GDP per capita (current US$)`, na.rm = T), -->
                     <!--             pop_millions = mean(`Population, total`)/1000000) %>% -->
  <!--   filter(Region != "Unknown" & Region != "CIS" & Region != "Arab States") %>% -->
  <!--   ggplot(aes(x = year, y = life_expectancy, color = Region)) + -->
  <!--   geom_line() + -->
  <!--   geom_ribbon(aes(ymin= life_expectancy - se_lifeexp, ymax=life_expectancy + se_lifeexp, fill = Region), alpha = 0.25, color = "transparent") + -->
  <!--   theme_solarized() + ylab("Life Expectancy at birth (years)") + -->
  <!--   labs(fill =  expression(paste("Country\nWidth = sem ", (over(sigma, sqrt(n)))))) + -->
  <!--   #labs(fill= "Country\nWidth = SEM") + -->
  <!--   scale_fill_solarized() + -->
  <!--   scale_color_solarized(guide = FALSE) -->



  <!-- dt_full[, logGDP := log10(`GDP (current US$)`)] -->
  <!-- dt_full[, Population := `Population, total`] -->
  <!-- dt_full[, GDP_PerCapita := `GDP per capita (current US$)`] -->
  <!-- dt_full[, LifeExpectancy := `Life expectancy at birth, total (years)`] -->

  <!-- # With smaller data, you can use Google's plotting API -->

  <!-- countries <- c("Uganda","Etheopia","Somalia","Nigeria","Tanzania", -->
                        <!--               "Kenya", "Botswana", "South Africa", -->
                        <!--               "United Kingdom","Lithuania","Moldova","Sweeden","Iceland","France", -->
                        <!--               "Spain","Italy","Germany","Romania", "Finland", -->
                        <!--               "China","India","Israel","Iraq","Nepal","Malaysia","Pakistan", -->
                        <!--               "Papua New Guinea", "Afghanistan", "Saudi Arabia", -->
                        <!--               "Australia","New Zealand","Fiji","Tonga","Samoa","New Caledonia", "Philippines", -->
                        <!--               "Japan", "China", "India", "Korea, Rep", "Singapore", -->
                        <!--               "Brazil","Argentina","Columbia","Nicaragua","Panama","Peru","Mexico", -->
                        <!--               "United States", "Canada") -->
  <!-- dt_reduced <- filter(dt_full, Country %in% countries) -->

  <!-- gChart <- gvisMotionChart(dt_reduced, -->
                                   <!--                          idvar = "Country", timevar = "year", -->
                                   <!--                          xvar = "GDP_PerCapita", yvar = "LifeExpectancy", -->
                                   <!--                          sizevar = "Population", colorvar = "Region") -->

  <!-- plot(gChart) -->



  <!-- ## Making animations -->


























