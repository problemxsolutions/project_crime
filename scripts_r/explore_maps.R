# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-#/

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)

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

# Get the column names for each table
table_col_names_list <- list()
db_data_list <- list()
for (i in 1:length(db_tables)){
  table_col_names_list[[i]] <- dbListFields(conn = pg_connect(), name = db_tables[i])
  db_data_list[[i]] <- tbl(pg_connect(), db_tables[i])
}