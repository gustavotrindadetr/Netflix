library(dplyr)
library(tidyr)

###
df <- read.csv2("netflix_titles.csv", sep = ',', header = TRUE, encoding = "UTF-8")



### Fix Duration Column
ds_netflix <- df %>%
  separate(duration, into = c('duration_num', 'duration_type'), sep = " ") %>%
  separate_rows(cast, sep = ', ')


### Export File
write.csv2(ds_netflix, "ds_netflix.csv", sep = ';')