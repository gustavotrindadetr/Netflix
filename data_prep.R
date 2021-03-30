################
##  PACKAGES  ##
################

library(dplyr)
library(tidyr)
library(rvest)
library(quantmod)
library(httr)
library(tibble)


####################
## Kaggle Dataset ##
####################

## Read CSV ##
df1 <- read.csv("netflix_titles.csv", header = T, sep = ',', encoding = "UTF-8")

## Fix Duration and Cast columns ##
ds_netflix_titles <- df1 %>%
  separate(duration, into = c("duration_num","duration_type"), sep =  " ") %>%
  separate_rows(cast, sep = ", ")

## Export file ##
write.csv2(ds_netflix_titles, "ds_netflix_titles.csv", sep = ';')



##########################
## Wikipedia html Table ##
##########################

## URL Wikipedia ##
oscars_url <- "https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films"

## Getting Oscars' table ##

## Using Class ##
#ds_oscars <- read_html(oscars_url) %>%
#  html_node("table") %>%
#  html_table()

## Using X-Path ##
ds_oscars <- read_html(oscars_url) %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table') %>%
  html_table() %>%
  select(title = Film, Awards)


## Export file ##
write.csv2(ds_oscars, "ds_oscars.csv", sep = ";")



#################
## IMDB Rating ##
#################

## URL IMDB ##
imdb_url <- "https://www.imdb.com/chart/top/?ref_=nv_mv_250" 

## Getting the title names in english ##
ds_imdb_title <- imdb_url %>%
  html_session(add_headers("Accept-Language" = "en")) %>%
  read_html() %>%
  html_nodes(".titleColumn a") %>%
  html_text()
  
## Getting the Imbd rating ##
ds_imdb_rating <- read_html(imdb_url) %>%
  html_nodes(".imdbRating strong") %>%
  html_text()
  
## Creating imbd table ##
ds_imdb <- as.tibble(cbind(title = ds_imdb_title, rating = ds_imdb_rating))


## Export file ##
write.csv2(ds_imdb, "ds_imdb.csv", sep = ";")
  

####################################
## Yahoo Finance - Netflix Stocks ##
####################################

## Getting the stock history ##
getSymbols("NFLX", src = "yahoo")

## Fix rownames and selecting Close and Volume columns ##
ds_stonks <- as.data.frame(NFLX) %>%
  rownames_to_column(var = "date") %>%
  select(date, price = NFLX.Close, volume = NFLX.Volume)

## Export File ##
write.csv2(ds_stonks, "ds_stonks.csv", sep = ";")
