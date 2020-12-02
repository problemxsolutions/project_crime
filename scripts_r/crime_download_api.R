# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-planning/

# These are the resources for Washington DC Criminal Data
# URL: https://opendata.dc.gov/search?collection=Dataset&q=Crime

library(tidyverse)
library(magrittr)
library(jsonlite)
library(geojsonR)

dir_destination <- '../data/crime/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)

# Assess the URLs and reduce to unique portions

# ****************************************************************
# JSON file
# ****************************************************************
base_url <- 'https://maps2.dcgis.dc.gov/dcgis/rest/services/FEEDS/MPD/MapServer'
query_end_url <- 'query?where=1%3D1&outFields=*&outSR=4326&f=json'

crime_data_json <- c(
  '2009' = '33',
  '2010' = '34',
  '2011' = '35',
  '2012' = '11',
  '2013' = '10',
  '2014' = '9',
  '2015' = '27',
  '2016' = '26',
  '2017' = '38',
  '2018' = '0',
  '2019' = '1',
  '2020' = '2'
)

# API URL to the last 30 days of criminal activity
# crime_data_last30days <- '/8'

# Sample Preview of the JSON output.  Returned only 1000 Results
data0 <- fromJSON(txt = paste(base_url, i, query_end_url, sep = '/')) 


# ****************************************************************
# GeoJSON file
# ****************************************************************
base_url <-     'https://opendata.arcgis.com/datasets'

crime_data_geojson <- c(
  '2009' = '73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson',
  '2010' = 'fdacfbdda7654e06a161352247d3a2f0_34.geojson',
  '2011' = '9d5485ffae914c5f97047a7dd86e115b_35.geojson',
  '2012' = '010ac88c55b1409bb67c9270c8fc18b5_11.geojson',
  '2013' = '5fa2e43557f7484d89aac9e1e76158c9_10.geojson',
  '2014' = '6eaf3e9713de44d3aa103622d51053b5_9.geojson',
  '2015' = '35034fcb3b36499c84c94c069ab1a966_27.geojson',
  '2016' = 'bda20763840448b58f8383bae800a843_26.geojson',
  '2017' = '6af5cb8dc38e4bcbac8168b27ee104aa_38.geojson',
  '2018' = '38ba41dd74354563bce28a359b59324e_0.geojson',
  '2019' = 'f08294e5286141c293e9202fcd3e8b57_1.geojson',
  '2020' = 'f516e0dd7b614b088ad781b0c4002331_2.geojson'
)

# Sample Preview of the GeoJSON output. Returned the appropriate amount of 31248 records
data <- FROM_GeoJson(url_file_string = 'https://opendata.arcgis.com/datasets/73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson', 
                     Flatten_Coords = F) 

str(data)
length(data$features)
data$features[[1]] %>% str

# Remove the data we no longer need.  
# This is valid if you use the GeoJSON method as well.
rm(data0, query_end_url, crime_data_json)
write_csv(x = crime_table0, file = "../data/crime/CY2009_DC_CRIME.csv")

# ****************************************************************

# Now we will get all the data and store in local directory.  
# We could just as easily load directly into a database if it were configured already.
# That will be discussed in a later script.

for(i in crime_data_geojson){
  print(names(which(crime_data_geojson == i)))
  source_year <- names(which(crime_data_geojson == i))

  data <- FROM_GeoJson(url_file_string = paste(base_url, i, sep = '/'),
                       Flatten_Coords = F)

  properties_data <- data$features
  
  lapply(properties_data, function(X) X$properties %>% flatten_df) %>%
    bind_rows() %>%
    write_csv(., file = paste0('../data/crime/crime_table_CY', source_year,'.csv'))
  print(paste(source_year, "completed!"))
}
print('Processing Complete')