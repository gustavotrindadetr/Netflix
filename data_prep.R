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


##############################
## Getting wikipedia Tables ##
##############################


## Getting Oscars' Table
oscars_url <- html("https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films")
netflix_url <- html("https://en.wikipedia.org/wiki/Netflix#Film_and_television_deals")
originals_url <- html("https://en.wikipedia.org/wiki/List_of_Netflix_original_programming")

ds_oscars <- oscars_url %>%
  html_node("table") %>%
  html_table() %>%
  rename(title = Film)

ds_finance <- netflix_url %>%
  html_node("table.wikitable.float-left") %>%
  html_table()

ds_expansion <- netflix_url %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table[4]') %>%
  html_table(fill = T)

ds_vod <- netflix_url %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table[5]') %>%
  html_table()

ds_originals <- originals_url %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table[1]') %>%
  html_table()

##############################
## Exporting Results as csv ##
##############################


## Joining Netflix Movies with Oscars]
ds_netflix <- left_join(ds_netflix_titles, ds_oscars, by = "title")
write.csv2(ds_netflix, "ds_netflix.csv", sep = ';')
write.csv2(ds_finance, "ds_finance.csv", sep = ';')
write.csv2(ds_expansion, "ds_expansion.csv", sep = ';')
write.csv2(ds_vod, "ds_vod.csv", sep = ';')