library(dplyr)
library(tidyr)
library(rvest)

####################
## Netflix Titles ##
####################

### Read CSV
df1 <- read.csv2("netflix_titles.csv", sep = ',', header = TRUE, encoding = "UTF-8")


### Fix Duration Column and Cast
ds_netflix_titles <- df1 %>%
  separate(duration, into = c('duration_num', 'duration_type'), sep = " ") %>%
  separate_rows(cast, sep = ', ')


### Export File
write.csv2(ds_netflix_titles, "ds_netflix_titles.csv", sep = ';')




#########################################
## List of Academy Award-winning films ##
#########################################


## Getting Oscars' Table
oscars_url <- html("https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films")
ds_oscars <- oscars_url %>%
  html_node("table") %>%
  html_table() %>%
  rename(title = Film)


## Joining Netflix Movies with Oscars]
ds_netflix <- left_join(ds_netflix_titles, ds_oscars, by = "title")
