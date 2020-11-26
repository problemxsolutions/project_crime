# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-1
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-4
# https://problemxsolutions.com/project/crime/criminal-analysis-data-storage-part-2

library(tidyverse) 
library(magrittr)
library(DBI)
library(rpostgis)
library(sf)

# Connect to desired PostgreSQL database
db <- 'project_crime'  # databast name to connect to
host_db <- 'localhost' # Where is db being hosted? default server/host is localhost
db_port <- '5432'  # Which port is the server listening to? default port number for PostgreSQL is 5432
db_user <- 'analyst'  
db_password <- 'mypassword'

con <- dbConnect(RPostgres::Postgres(), 
                 dbname = db, 
                 host=host_db,
                 port=db_port,
                 user=db_user, 
                 password=db_password)  

# Check if database extension is installed.
# I did have to alter my analyst role in psql to superuser to do this on 
# my initial use, but afterward, it wasn't needed to have superuser privileges. 
# psql: 
# project_crime=# alter role analyst superuser; 
pgPostGIS(conn = con)

# After conducting the check, I reverted the analyst role back to nosuperuser
# project_crime=# alter role analyst nosuperuser; 

# **********************************************************************************************
# Test: Get a GeoJSON file and load into the database
# **********************************************************************************************
ward_data <- 'https://opendata.arcgis.com/datasets/0ef47379cbae44e88267c01eaec2ff6e_31.geojson'
filename <- '../data/map_data/ward_data.json'
download.file(ward_data, filename)

dbListTables(conn = con)

data <- st_read(dsn = filename) 

ggplot(data = data)+
  geom_sf(aes(fill= as.numeric(POP_2011_2015))) +
  geom_sf_label(aes(label = WARD))

sf::dbWriteTable(conn = con, 
                 name = "ward_polygons", 
                 value = data, 
                 overwrite = TRUE,
                 driver = RPostgres::Postgres())

# Check the current list of Tables to verify table was created
dbListTables(conn = con)

pgListGeom(conn = con, geog = TRUE)

rpostgis::dbTableInfo(conn = con, name = 'ward_polygons')
rpostgis::pgGetGeom(conn = con, name = 'ward_polygons', geom = "geometry")

dbRemoveTable(conn = con, name = "ward_polygons")
# **********************************************************************************************
# End test case
# **********************************************************************************************

# **********************************************************************************************
# Load all the map data files into PostgreSQL/PostGIS database
# **********************************************************************************************
# If you followed the downloading of map data from the 
# dc_map_data.R script then the following will work.
map_data_path <- '../data/map_data/'
map_data_files <- list.files(path = map_data_path, pattern = ".json")

for(i in map_data_files){
  # If filenames were created to be table name then this is correct
  table_name <- i %>% str_remove(string = ., pattern = ".json")
  
  # Read in the GeoJSON data using the sf::st_read method
  data <- st_read(dsn = paste0(map_data_path, i))
  
  # Load the data into the database
  sf::dbWriteTable(conn = con,
                   name = table_name,
                   value = data, 
                   driver = RPostgres::Postgres())
  print("Data Loaded...Table Created...Complete!")
}
rm(data, table_name, map_data_path, map_data_files)
dbListTables(conn = con)

pgListGeom(conn = con, geog = TRUE)

# **********************************************************************************************
# Load Permit Map Data
# Reference dc_realestate_data.R for more information
# # **********************************************************************************************
dir_destination <- '../data/map_data/realestate/'
map_data_files <- list.files(path = dir_destination, pattern = ".json")

for(i in map_data_files){
  # If filenames were created to be table name then this is correct
  table_name <- 
    i %>%
    str_remove(string = ., pattern = "_20[0-9]{2}.json")
  
  # Read in the GeoJSON data using the sf::st_read method
  data <- st_read(dsn = paste0(dir_destination, i))
  
  if(table_name %in% dbListTables(conn = con)){
    # Load the data into the database
    sf::dbWriteTable(conn = con,
                     name = table_name,
                     value = data,
                     driver = RPostgres::Postgres(),
                     append = T)
  }else{
    # Load the data into the database
    sf::dbWriteTable(conn = con,
                     name = table_name,
                     value = data,
                     driver = RPostgres::Postgres())
  }
  
  print("Data Loaded...Table Created...Complete!")
}
rm(i, j, data, table_name, map_data_path, map_data_files)
dbListTables(conn = con)

pgListGeom(conn = con, geog = TRUE)
