# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-1

# These are the resources for Washington DC spatial files (shapefile, geoJSON)
# URL: ttps://opendata.dc.gov/

# ******************************************************
# DC Boundary
# URL: https://opendata.dc.gov/datasets/washington-dc-boundary
# GeoJSON:
# dc_boundary <- 'https://opendata.arcgis.com/datasets/7241f6d500b44288ad983f0942b39663_10.geojson'

# ******************************************************
# District of Columbia 2012 election wards
# URL: https://opendata.dc.gov/datasets/ward-from-2012
# GeoJSON:
# ward_data <- 'https://opendata.arcgis.com/datasets/0ef47379cbae44e88267c01eaec2ff6e_31.geojson'

# ******************************************************
# Police Districts
# URL: https://opendata.dc.gov/datasets/police-districts
# GeoJSON:
# police_district <-  'https://opendata.arcgis.com/datasets/d2a63e5246ff41bdaca8ea9be95c8a4b_9.geojson'

# Police Service Areas
# URL: https://opendata.dc.gov/datasets/police-service-areas
# GeoJSON:
# psa_data <- 'https://opendata.arcgis.com/datasets/db24f3b7de994501aea97ce05a50547e_10.geojson'

# ******************************************************
# Zipcodes
# URL: https://opendata.dc.gov/datasets/zip-codes
# GeoJSON:
# zipcode_data <- 'https://opendata.arcgis.com/datasets/5637d4bb43a34668b19fe630120d2b70_4.geojson'

# ******************************************************
# Police Stations
# URL: https://opendata.dc.gov/datasets/police-stations
# GeoJSON:
# police_stations <- 'https://opendata.arcgis.com/datasets/9e465c1e6dfd4605a7632ed5737644f3_11.geojson'

# ******************************************************
# Schools, Public
# URL: https://opendata.dc.gov/datasets/public-schools
# GeoJSON:
# public_schools <- 'https://opendata.arcgis.com/datasets/4ac321b2d409438ebd76a6569ad94034_5.geojson'

# Schools, Charter
# URL: https://opendata.dc.gov/datasets/charter-schools
# GeoJSON:
# charter_schools <- 'https://opendata.arcgis.com/datasets/a3832935b1d644e48c887e6ec5a65fcd_1.geojson'

# Schools, Transformation
# URL: https://opendata.dc.gov/datasets/transformation-schools
# GeoJSON:
# transform_schools <- 'https://opendata.arcgis.com/datasets/470adf108ea34744adf55fce3a4a0359_11.geojson'

# Schools, Summer Public
# URL: https://opendata.dc.gov/datasets/summer-public-schools
# GeoJSON:
# summer_public <- 'https://opendata.arcgis.com/datasets/0d6af0f0485c476981a05dcf96f7c806_3.geojson'

# ******************************************************
# METRO Entrances
# URL: https://opendata.dc.gov/datasets/metro-station-entrances-in-dc
# GeoJSON: 
# metro_stations <- 'https://opendata.arcgis.com/datasets/ab5661e1a4d74a338ee51cd9533ac787_50.geojson'

# Metro Bus Stops
# URL: https://opendata.dc.gov/datasets/metro-bus-stops
# GeoJSON:
# metro_bus_stops <- 'https://opendata.arcgis.com/datasets/e85b5321a5a84ff9af56fd614dab81b3_53.geojson'

# ******************************************************
# Building and Construction Permit data will be covered in a separate R script.


# ******************************************************
# Download all the data and store in a local directory
# ******************************************************

base_url <- 'https://opendata.arcgis.com/datasets/'

map_data_geojson <- c(
  'dc_polygon' = '7241f6d500b44288ad983f0942b39663_10.geojson',
  'ward_polygons' = '0ef47379cbae44e88267c01eaec2ff6e_31.geojson',
  'police_district_polygons' =  'd2a63e5246ff41bdaca8ea9be95c8a4b_9.geojson',
  'psa_polygons' = 'db24f3b7de994501aea97ce05a50547e_10.geojson',
  'zipcode_polygons' = '5637d4bb43a34668b19fe630120d2b70_4.geojson',
  'police_station_points' = '9e465c1e6dfd4605a7632ed5737644f3_11.geojson',
  'public_school_points' = '4ac321b2d409438ebd76a6569ad94034_5.geojson',
  'charter_school_points' = 'a3832935b1d644e48c887e6ec5a65fcd_1.geojson',
  'transform_school_points' = '470adf108ea34744adf55fce3a4a0359_11.geojson',
  'summer_public_points' = '0d6af0f0485c476981a05dcf96f7c806_3.geojson',
  'metro_station_points' = 'ab5661e1a4d74a338ee51cd9533ac787_50.geojson',
  'metro_bus_stop_points' = 'e85b5321a5a84ff9af56fd614dab81b3_53.geojson'
)

dir_destination <- '../data/map_data/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)

for(i in map_data_geojson){
  temp_url <- paste0(base_url, i)
  
  table_basename <- names(which(map_data_geojson == i))
  print(table_basename)
  
  download.file(url = temp_url,
                destfile = paste0(dir_destination, table_basename,'.json'))
}
rm(temp_url, base_url, table_basename, map_data_geojson)
print('Processing Complete')

