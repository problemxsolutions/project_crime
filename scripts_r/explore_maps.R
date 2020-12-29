# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-#/

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)
# library(rpostgis)
library(sf)

# Source project functions:
source('~/ProblemXSolutions.com/DataProjects/DC_Crime/project_crime/scripts_r/project_functions_db.R')

# create the graphics output directory for saving visualizations
dir_destination <- '../graphics/data_explore/maps_graphics/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)


# Display all the tables in the connected database
dbListTables(conn = pg_connect())
# **************************************************************************************************

# Assign the table names to a variable
db_tables <- c('charter_school_points',
              'dc_polygon',
              'metro_bus_stop_points',
              'metro_station_points',
              'police_district_polygons',
              'police_station_points',
              'psa_polygons',
              'public_school_points',
              'summer_public_points',
              'transform_school_points',
              'ward_polygons',
              'zipcode_polygons',
              'building_permits',
              'construction_permits')

db_tables_polygons <- db_tables[str_detect(string = db_tables, pattern = "polygon")]
db_tables_points <- db_tables[str_detect(string = db_tables, pattern = "points|permits")]

# Get the column names for each table and establish a connection to each data for querying the data
db_polygons <- bulk_table_connections(connection = pg_connect(),
                                      db_tables = db_tables_polygons)
db_points <- bulk_table_connections(connection = pg_connect(), 
                                    db_tables = db_tables_points)

# *********************************************************************************************
# Explore Polygon Datasets first
# db_polygons$column_names
# db_polygons$tables
# *********************************************************************************************

# Explore 1st element: DC Polygon.
# Display as is contained in the variable
db_polygons$tables[[1]]

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_polygons[1])

# Get the geometry data from the database
poly_plot_data <- rpostgis::pgGetGeom(conn = pg_connect(), 
                    name = db_tables_polygons[1], 
                    geom = "geometry")

# Convert into sf object
data = st_as_sf(poly_plot_data)

# plot using sf object and ggplot2
ggplot(data) +
  geom_sf() +
  geom_sf_label(aes(label = CITY_NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(paste0(dir_destination, "dc_polygon.png"), 
       width = 6, height = 6, dpi = "screen")

# *********************************************************************************************

# Explore 2nd element: Police Districts
# Display as is contained in the variable
i_element <- 2
db_polygons$tables[[i_element]]

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_polygons[i_element])

# Get the geometry data from the database and 
# convert into sf object
poly_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_polygons[i_element], 
                      geom = "geometry") %>% 
  st_as_sf(poly_plot_data)

ggplot(poly_plot_data) +
  geom_sf(aes(fill = NAME)) +
  geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_pd_polygons.png"), 
       width = 6, height = 6, 
       dpi = "screen", 
       scale = 1.5)


# *********************************************************************************************

# Explore: Police Service Areas
# Display as is contained in the variable
i_element <- 3
db_polygons$tables[[i_element]]

db_polygons$tables[[i_element]] %>% 
  select(OBJECTID) %>% 
  distinct %>% 
  collect

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_polygons[i_element])

# Get the geometry data from the database and 
# convert into sf object
poly_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_polygons[i_element], 
                      geom = "geometry") %>% 
  st_as_sf(poly_plot_data)

ggplot(poly_plot_data) +
  geom_sf(aes(fill = factor(DISTRICT))) +
  geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_psa_polygons.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)


# *********************************************************************************************

# Explore: Wards
# Display as is contained in the variable
# URL: https://opendata.dc.gov/datasets/ward-from-2012
i_element <- 4
db_polygons$tables[[i_element]]


# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_polygons[i_element])

# evaluate numeric columns that are displayed as text
cols_numeric_eval <- db_polygons$tables[[i_element]] %>% 
  select(15:78) %>%
  collect

# double/numeric valued fields
cols_numeric_eval %>% 
  select(contains(c("MEDIAN_", "_RATE", "PCT_"))) %>% 
  view()

# int valued fields
cols_numeric_eval %>% 
  select(!contains(c("MEDIAN_", "_RATE", "PCT_"))) %>% 
  view()


# Get the geometry data from the database and 
# convert into sf object
poly_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_polygons[i_element], 
                      geom = "geometry") %>% 
  st_as_sf(poly_plot_data)

ggplot(poly_plot_data) +
  geom_sf(aes(fill = NAME)) +
  geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_ward_polygons.png"), 
       width = 6, height = 6, 
       dpi = "screen", 
       scale = 1.5)

# # COMMENTED OUT TO PREVENT RUNNING THE WHOLE PROCESS
# for(i in 15:78){
#   tmp_col_name <- colnames(poly_plot_data[i])[1]
#   if(str_detect(string = tmp_col_name, pattern = "((MEDIAN|PCT)_)|(_RATE)")){
#     poly_plot_data[[i]] %<>% as.numeric()
#   }else{
#     poly_plot_data[[i]] %<>% as.integer()
#   }
#   
#   ggplot(poly_plot_data) +
#     geom_sf(aes_string(fill = tmp_col_name)) +
#     geom_sf_label(aes(label = NAME)) +
#     labs(x = 'Lon', y = 'Lat')
#   
#   ggsave(filename = paste0(dir_destination, 
#                            'dc_ward_polygons_', 
#                            tmp_col_name,'.png'), 
#          width = 6, height = 6, 
#          dpi = "screen", 
#          scale = 1.5)
# }


# *********************************************************************************************

# Explore: Zip Code
# Display as is contained in the variable
i_element <- 5
db_polygons$tables[[i_element]]

db_polygons$tables[[i_element]] %>% 
  select(OBJECTID) %>% 
  distinct %>% 
  collect

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_polygons[i_element])

# Get the geometry data from the database and 
# convert into sf object
poly_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_polygons[i_element], 
                      geom = "geometry") %>% 
  st_as_sf(poly_plot_data)

ggplot(poly_plot_data) +
  geom_sf() +
  # geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_zipcode_polygons.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)

# Zipcode: Uninsured Population
ggplot(poly_plot_data) +
  geom_sf(aes(fill =  UNINSURED_POPULATION)) +
  # geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_zipcode_polygons_uninsured_population.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)

# Zipcode: MEDICAID_RECIPIENT
ggplot(poly_plot_data) +
  geom_sf(aes(fill =  MEDICAID_RECIPIENT)) +
  # geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_zipcode_polygons_MEDICAID_RECIPIENT.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)

# Zipcode: POP_2010
ggplot(poly_plot_data) +
  geom_sf(aes(fill =  POP_2010)) +
  # geom_sf_label(aes(label = NAME)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_zipcode_polygons_POP_2010.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)
