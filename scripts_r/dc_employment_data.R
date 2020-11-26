# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-3

library(tidyverse)
library(magrittr)

# ******************************************************
# DC Department of Employment Services.
# This will provide current information at specific locations in the city.
# URL: https://does.dc.gov/page/labor-statistics

# ******************************************************
# URL: https://does.dc.gov/page/unemployment-data-dc-wards
# ******************************************************
# Note: Estimates for the latest year are subject to revision early the following calendar year.
# Source: DOES - Office of Labor Market Research and Information (OLMRI).
# Preliminary(p); Not seasonally adjusted data

# URL: https://does.dc.gov/sites/default/files/dc/sites/does/page_content/attachments/2009%20Unemployment%20Rate%20by%20Ward.pdf
# Since I was not able to find tabulated data, I had to copy/paste data from a PDF document into a csv file to then parse the information.

old_labels = paste0('X', 1:5)
new_labels <- c('Ward', 'Labor_Force', 'Employment', 'Unemployment', 'Unemployment_Rate')

# sample_data <- read_delim(file = '../data/employment/CY2009.txt', delim = '\t')
sample_data <- read_delim(file = '../data/employment/CY2009_2019_unemployment_ward_month_year.csv', delim = '\t')
data_list <- list()
for(i in 1:nrow(sample_data)){
  data_to_parse <- sample_data$Data[i]
  data_to_parse %<>% 
    str_remove(string = ., pattern = "Ward Labor Force Employment Unemployment Rate ") %>% 
    str_replace_all(string = ., pattern = ',', replacement = '') %>% 
    str_split(string = ., pattern = ' ') %>% 
    unlist() %>% 
    as.numeric() %>% 
    matrix(data = ., ncol = 5, byrow = T) %>% 
    data.frame() %>% 
    tibble() %>% 
    mutate(Year = sample_data$Year[i],
           Month = sample_data$Month[i])
  
  data_list[[i]] <- data_to_parse
}
employment <- data_list %>% bind_rows
colnames(employment)[1:5] <-  new_labels

# Generate a plot to inspect the data.
ggplot(data = employment, aes(x = paste(Year,Month, sep='-'), y = Unemployment_Rate)) +
  geom_bar(aes(fill = Ward), position = position_stack(), stat = 'identity') +
  facet_grid(rows= vars(Ward))

# Write out the data to a csv
write_csv(x = employment, file = '../data/employment/PROCESSED_CY2009_2019_unemployment_ward_month_year.csv')

# ******************************************************
# URL: https://oui.doleta.gov/unemploy/claims.asp
# ******************************************************
doleta_data <- read_delim(file = '../data/employment/CY2009_2021_weekly_unemployment_insurance_claims.csv', 
                        skip = 4, skip_empty_rows = T,  delim = '\t')
doleta_data %>% tail(2)
doleta_data %<>% 
  head(-2) %>% 
  rename_with(~ gsub(pattern = ' ', replacement = '_', x = .)) %>% 
  mutate(Filed_week_ended = as.Date(Filed_week_ended, format='%m/%d/%Y'),
         Reflecting_Week_Ended = as.Date(Reflecting_Week_Ended, format='%m/%d/%Y'))

# Generate a plot to inspect the data.
ggplot(data = doleta_data, aes(x = Filed_week_ended, y = Initial_Claims)) +
  geom_line()

# Write out the data to a csv
write_csv(x = doleta_data, file = '../data/employment/PROCESSED_CY2009_2021_weekly_unemployment_insurance_claims.csv') 

# ******************************************************
# URL: https://beta.bls.gov/dataViewer/view/timeseries/LNS14000000
# ******************************************************
bls_data <- read_csv(file = '../data/employment/USBLS_unemploymentrates_bymonth_2009_2020.csv')
bls_data %<>% 
  rename_with(~ gsub(pattern = ' ', replacement = '_', x = .)) %>% 
  mutate(year_month = parse_date(x = bls_data$Label, format = '%Y %b'))

# Generate a plot to inspect the data.
ggplot(data = bls_data, aes(x = year_month, y = Value)) +
  geom_line()

# Write out the data to a csv
write_csv(x = bls_data, file = '../data/employment/PROCESSED_USBLS_unemploymentrates_bymonth_2009_2020.csv') 
