# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-2

library(tidyverse)
library(magrittr)

dir_destination <- '../data/weather/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)

# ******************************************************
# DC Weather Data.
# This will provide current information at specific locations in the city.
# URL: https://opendata.dc.gov/datasets/roadway-weather-information-systems-sensors

# DC Weather Data. NOAA
# This will provide current information at specific locations in the city.
# URL: https://www.ncdc.noaa.gov/cdo-web/

# ***********************************************************************
# # weatherData package
# ***********************************************************************
# # URL: http://ram-n.github.io/weatherData/
# install.packages("devtools")
# library("devtools")
# install_github("Ram-N/weatherData")
# 
# library(weatherData)
# getWeatherForDate(station_id = "KDCA", start_date = "2009-01-01", opt_detailed = T, station_type = 'ID')
# # This returns returns errors.  Function internals are not current.
# getStationCode("Washington", 'DC')

# ***********************************************************************
# rnoaa package
# ***********************************************************************
# # URL: https://docs.ropensci.org/rnoaa/
install.packages('rnoaa')
library(rnoaa)

email_add <- "email@address.com"
noaa_token <- "noaa_token_id_str"
options(noaakey = noaa_token)

# Find a station: https://www.ncdc.noaa.gov/cdo-web/datatools/findstation
stationid_list <- c(dca = "GHCND:USW00013743")

# Get weather station information
station_metadata_wx <- ncdc_stations(stationid = stationid_list[1])

# Get weather day
query_date_sequence <- seq.Date(from = as.Date('2009-01-01'), to = as.Date('2020-01-01'), by = 75)
wx_list <- list()
for (i in 1:length(query_date_sequence)){
  i_start = query_date_sequence[i]
  i_end = if_else(is.na(query_date_sequence[i+1]), 
                  as.Date('2019-12-31'), 
                  query_date_sequence[i+1]-1)
  
  station_data_wx <- ncdc(stationid = station_metadata_wx$data$id,
                          datasetid='GHCND',
                          datatypeid = c('PRCP',
                                         'SNWD', 'SNOW',
                                         'TAVG', 'TMAX', 'TMIN',
                                         'AWND',
                                         'WDF2', 'WDF5',
                                         'WSF2', 'WSF5',
                                         'WT01', 'WT06', 'WT02', 'WT08', 'WT03'),
                          startdate = i_start, enddate = i_end,
                          limit = 1000, offset = 0, add_units = T)

  wx_list[[i]] <- station_data_wx$data
}

# Combine our lists of data into one table
wx_data <- 
  wx_list %>% 
  bind_rows

# Write out the data to a csv
write_csv(x = wx_data, file = '../data/weather/full_wx_data_2009_2019.csv')

# Create a separate table with just temperature information.
# Do some initial transformations to convert the units they 
# provided (celcius_tenths) into Fahrenheit
temp_data <- 
  wx_data %>% 
  filter(datatype == c('TAVG', 'TMIN', 'TMAX')) %>% 
  distinct %>% 
  mutate(date = as.Date(date)) %>% 
  drop_na() %>% 
  mutate(Temp_Normalize = value/10,
         Temp_F = (value/10)*(9/5)+32)

# Generate a quickplot of the data  
qplot(data = temp_data, x = date, y = Temp_F, color = datatype)

# Write out the data to a csv
write_csv(x = temp_data, file = '../data/weather/weather_temp_table.csv')

# Create a separate table with just precipitation information.
precip_data <- 
  wx_data %>% 
  filter(datatype == c('PRCP', 'SNOW', 'SNWD')) %>% 
  distinct %>% 
  mutate(date = as.Date(date))

# Generate a plot of the data to see what its doing
ggplot(data = precip_data, aes(x = date, y = value)) + 
  geom_point() +    
  facet_wrap('datatype', nrow = 3)

# Write out the data to a csv
write_csv(x = temp_data, file = '../data/weather/weather_precipsnow_table.csv')

# ***********************************************************************
# suncalc package
# ***********************************************************************
library("suncalc")

# Generate a list of the dates we want information for
date_range <- seq.Date(from = as.Date('2009-01-01'), 
                       to = as.Date('2020-11-24'), 
                       by = 1)
# Moon Phases
moon_phase_data <- getMoonIllumination(date = date_range)

# Write out the data to a csv
write_csv(x = moon_phase_data, file = '../data/weather/moon_phase_data.csv')

# Sunrise/Sunset Time for Washington DC.
suntimes_data <- getSunlightTimes(date = date_range, 
                                  lat = 38.89511, 
                                  lon = -77.03637)

# Write out the data to a csv
write_csv(x = suntimes_data, file = '../data/weather/suntimes_data.csv')


