library(dplyr)
library(tidyr)
library(tibble)
library(rvest)
library(stringr)
library(quantmod)

options(scipen = 999)


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
oscars_url <- read_html("https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films")
netflix_url <- read_html("https://en.wikipedia.org/wiki/Netflix#Film_and_television_deals")
imdb_url <- read_html("https://www.imdb.com/chart/top?ref_=nv_wl_img_3")

ds_oscars <- oscars_url %>%
  html_node("table") %>%
  html_table() %>%
  rename(title = Film)

ds_finance <- netflix_url %>%
  html_node("table.wikitable.float-left") %>%
  html_table() %>%
  transmute(year = Year,
            revenue = `Revenuein mil. USD-$`, 
            netIncome = `Net incomein mil. USD-$`) %>%
  mutate(revenue = str_replace_all(revenue, ",", ""), netIncome = str_replace_all(netIncome, ",", "")) %>%
  mutate(revenue = as.numeric(revenue) * 1000000, netIncome = as.numeric(netIncome) * 1000000)


ds_expansion <- netflix_url %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table[4]') %>%
  html_table() %>%
  transmute('Year' = X1, 'info' = X2)

ds_vod <- netflix_url %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table[5]') %>%
  html_table() %>%
  transmute(year = substr(`End of year`,4,7), 
            vodCustomers = `paying VOD customers (in millions)`,
            dvdCustomers = `paying DVD customers (in millions)`)

ds_imdb_title <- imdb_url %>%
  html_nodes('.titleColumn a') %>%
  html_text()

ds_imdb_rank <- imdb_url %>%
  html_nodes('.imdbRating strong') %>%
  html_text()

ds_imdb <- as_tibble(cbind(ds_imdb_title, ds_imdb_rank))



####################
## Getting Stonks ##
####################

ds_stonks <- getSymbols('NFLX', src = "yahoo")

ds_stocks <- as.data.frame(NFLX) %>%
  rownames_to_column(var = "date") %>%
  select(date, NFLX.Close, NFLX.Volume) %>%
  rename(stockPrice = NFLX.Close, stockVolume = NFLX.Volume)



##############################
## Exporting Results as csv ##
##############################

## Joining Netflix Movies with Oscars]
ds_netflix <- left_join(ds_netflix_titles, ds_oscars, by = "title")
write.csv2(ds_netflix, "ds_netflix.csv", sep = ';', row.names = F)
write.csv2(ds_finance, "ds_finance.csv", sep = ';', row.names = F)
write.csv2(ds_expansion, "ds_expansion.csv", sep = ';', row.names = F)
write.csv2(ds_vod, "ds_vod.csv", sep = ';', row.names = F)
write.csv2(ds_stocks, "ds_stocks.csv", sep = ';', row.names = F)
