# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-2b/

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
db_tables <- c('police_station_points',
               'public_school_points',
               'charter_school_points',
               'summer_public_points',
               'transform_school_points',
               'metro_bus_stop_points',
               'metro_station_points',
               'building_permits',
               'construction_permits')

# db_tables_polygons <- db_tables[str_detect(string = db_tables, pattern = "polygon")]
db_tables_points <- db_tables[str_detect(string = db_tables, pattern = "points|permits")]

# Get the column names for each table and establish a connection to each data for querying the data
# db_polygons <- bulk_table_connections(connection = pg_connect(),
#                                       db_tables = db_tables_polygons)
db_points <- bulk_table_connections(connection = pg_connect(), 
                                    db_tables = db_tables_points)

police_districts_polygons <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = 'police_district_polygons', 
                      geom = "geometry") %>% 
  st_as_sf(poly_plot_data)
# *********************************************************************************************
# Explore Points Datasets
# db_points$column_names
# db_points$tables
# *********************************************************************************************

# Explore 1st element: DC Police Stations
# Display as is contained in the variable
db_points$tables[[1]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[1])

# Get the geometry data from the database
point_plot_data <- rpostgis::pgGetGeom(conn = pg_connect(), 
                                      name = db_tables_points[1], 
                                      geom = "geometry")

# Convert into sf object
data = st_as_sf(point_plot_data)

# plot using sf object and ggplot2
ggplot(data) +
  geom_sf(data = police_districts_polygons, 
          aes(fill = NAME), inherit.aes = F) +
  geom_sf() +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(paste0(dir_destination, "dc_police_station.png"), 
       width = 6, height = 6, dpi = "screen")

# *********************************************************************************************

# Explore : DC Public Schools
# Display as is contained in the variable
i_element <- 2
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()

ggplot(point_plot_data) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = FACUSE)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_pub_schools.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)

# *********************************************************************************************

# Explore : DC Charter Schools
# Display as is contained in the variable
i_element <- 3
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()

ggplot(point_plot_data) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = GRADES)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_charter_schools.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)

# *********************************************************************************************
# Explore : DC Charter Schools
# Display as is contained in the variable
i_element <- 4
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()

ggplot(point_plot_data) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = FACUSE)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_summer_schools.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1)


# *********************************************************************************************
# Explore : DC Transformation Schools
# Display as is contained in the variable
i_element <- 5
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()

ggplot(point_plot_data) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = FACUSE)) +
  labs(x = 'Lon', y = 'Lat')

# save the image
ggsave(filename = paste0(dir_destination, "dc_transform_schools.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1)


# *********************************************************************************************
# Explore : DC Metro Bus Stops
# Display as is contained in the variable
i_element <- 6
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()


ggplot(point_plot_data) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = REG_ID)) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Metro Bus Stops')

# save the image
ggsave(filename = paste0(dir_destination, "dc_metro_bus_stops.png"), 
       width = 10, height = 8, 
       dpi = "screen", 
       scale = 1)

# filter the points to only be within the city boundary
# get the city boundary polygon
dc_boundary <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = 'dc_polygon', 
                      geom = "geometry") %>% 
  st_as_sf()

# filter/join the sf objects
point_plot_data_filtered <- 
point_plot_data %>% 
  st_join(dc_boundary, left = F)
rm(dc_boundary)

# plot the results
ggplot(point_plot_data_filtered) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = REG_ID)) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Metro Bus Stops')

# save the image
ggsave(filename = paste0(dir_destination, "dc_metro_bus_stops_reduced.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1)

# *********************************************************************************************
# Explore : DC Metro Stations
# Display as is contained in the variable
i_element <- 7
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()


ggplot(point_plot_data) +
  geom_sf(data = police_districts_polygons, 
          fill = 'grey50', 
          inherit.aes = F) +
  geom_sf(aes(color = LINE)) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Metro Stations')

# save the image
ggsave(filename = paste0(dir_destination, "dc_metro_stations.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)


# *********************************************************************************************
# Explore : DC Building Permits
# Display as is contained in the variable
i_element <- 8
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  summarise(count = n())

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()

point_plot_data %>% select(APPLICATION_STATUS_NAME) %>% distinct

point_plot_data_reduced <- 
  point_plot_data %>% 
  select(ISSUE_DATE, PERMIT_TYPE_NAME, PERMIT_SUBTYPE_NAME, 
         PERMIT_CATEGORY_NAME, WARD, DISTRICT, PSA) %>% 
  mutate(year = lubridate::year(ISSUE_DATE))
  
point_plot_data_reduced %>%
    st_drop_geometry() %>% 
    select(year, PERMIT_TYPE_NAME) %>% 
    group_by(year, PERMIT_TYPE_NAME) %>% 
    summarise(count = n()) %>% 
    pivot_wider(names_from = PERMIT_TYPE_NAME, 
                values_from = count)

point_plot_data_reduced %>%
  st_drop_geometry() %>% 
  filter(PERMIT_TYPE_NAME == "SUPPLEMENTAL") %>% 
  select(year, PERMIT_SUBTYPE_NAME) %>% 
  group_by(year, PERMIT_SUBTYPE_NAME) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = PERMIT_SUBTYPE_NAME, 
              values_from = count)

point_plot_data_reduced %>%
  st_drop_geometry() %>% 
  # filter(PERMIT_TYPE_NAME == "SUPPLEMENTAL") %>% 
  select(year, DISTRICT) %>% 
  group_by(year, DISTRICT) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = DISTRICT, 
              values_from = count)
  
# Visualize 7th District Building Permits by year
bp_2020_supplemental <- 
  point_plot_data_reduced %>% 
  filter(DISTRICT == "SEVENTH",
         PERMIT_TYPE_NAME == "SUPPLEMENTAL",
         year == 2020)

ggplot(bp_2020_supplemental) +
  geom_sf(data = police_districts_polygons %>% 
            filter(DISTRICT == 7), 
          inherit.aes = F) +
  geom_sf(aes(color = PERMIT_SUBTYPE_NAME)) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Building Permits')


# save the image
ggsave(filename = paste0(dir_destination, "dc_building_permits_7d_sup_subtype_2020.png"), 
       width = 8, height = 8, 
       dpi = "screen", 
       scale = 1.5)

ggplot(bp_2020_supplemental) +
  geom_sf(data = police_districts_polygons %>% 
            filter(DISTRICT == 7), 
          inherit.aes = F) +
  geom_sf(aes(color = PERMIT_SUBTYPE_NAME)) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Building Permits') +
  facet_grid(year~PERMIT_SUBTYPE_NAME)

# save the image
ggsave(filename = paste0(dir_destination, "dc_building_permits_7d_sup_subtype_2020_facet.png"), 
       width = 10, height = 4, 
       dpi = "screen", 
       scale = 1.5)


dc_ward_supplemental_electrical <- 
  point_plot_data_reduced %>% 
  filter(PERMIT_SUBTYPE_NAME == "ELECTRICAL")

dc_ward_supplemental_electrical %>% 
  st_drop_geometry() %>% 
  group_by(year, DISTRICT, PERMIT_SUBTYPE_NAME) %>%
  summarise(count = n()) %>% 
  pivot_wider(names_from = DISTRICT, 
              values_from = count)

ggplot(dc_ward_supplemental_electrical) +
  geom_sf(data = police_districts_polygons, 
          inherit.aes = F) +
  geom_sf(aes(color = year)) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Building Permits', subtitle = "Supplemental: Electrical") +
  facet_wrap('year')



# *********************************************************************************************
# Explore : DC Construction Permits
# Display as is contained in the variable
i_element <- 9
db_points$tables[[i_element]] %>% view

db_points$tables[[i_element]] %>%  select(OBJECTID) %>% collect

# Display the Table information from the database side
rpostgis::dbTableInfo(conn = pg_connect(), 
                      name = db_tables_points[i_element])

db_points$tables[[i_element]] %>%  
  select(STATUS) %>% 
  group_by(STATUS) %>% 
  summarise(count = n()) %>% 
  collect()

# Get the geometry data from the database and 
# convert into sf object
point_plot_data <- 
  rpostgis::pgGetGeom(conn = pg_connect(), 
                      name = db_tables_points[i_element], 
                      geom = "geometry") %>% 
  st_as_sf()

# Add a year column
point_plot_data %<>% 
  mutate(year = lubridate::year(EFFECTIVEDATE))

ggplot() +
  geom_sf(data = police_districts_polygons, 
          inherit.aes = F) +
  geom_sf(data = point_plot_data %>% filter(ISPSRENTAL == "T"), 
          aes(color = as.factor(year))) + 
  labs(x = 'Lon', y = 'Lat') +
  ggtitle(label = 'Construction Permits', 
          subtitle = "Portable Storage Rental") +
  facet_wrap("year", nrow = 2)


# save the image
ggsave(filename = paste0(dir_destination, "dc_construct_permits_psrental_by_year.png"), 
       width = 10, height = 6, 
       dpi = "screen", 
       scale = 1.5)
