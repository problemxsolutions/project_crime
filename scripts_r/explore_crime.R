# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)


# Connect to desired PostgreSQL database
db <- 'project_crime'  # database name to connect to
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

dbListTables(conn = con)
#  [1] "weather"                   "temperature"               "dc_unemployed_ward"       
#  [4] "dc_unemployed_insurance"   "national_unemployed"       "moon_phase"               
#  [7] "sunrise_sunset"            "crime"                     "charter_school_points"    
# [10] "dc_polygon"                "metro_bus_stop_points"     "metro_station_points"     
# [13] "summer_public_points"      "geography_columns"         "geometry_columns"         
# [16] "spatial_ref_sys"           "police_district_polygons"  "police_station_points"    
# [19] "psa_polygons"              "public_school_points"      "transform_school_points"  
# [22] "ward_polygons"             "zipcode_polygons"          "building_permits"         
# [25] "construction_permits"      "Median_Household_Income"   "Rental_Vacany_Rates"      
# [28] "Home_Vacancy_Rates"        "Home_Ownership_Rates"      "Housing_Price_Index"      
# [31] "New_Private_Housing_Units" "Business_Applications"     "rf_price_sales_inventory" 
# [34] "rf_covid_weekly_markets"   "rdc_inventory"            
# **************************************************************************************************
db_table <- 'crime'

dbListFields(conn = con, name = db_table)
# [1] "ANC"                  "BID"                  "BLOCK"               
# [4] "BLOCK_GROUP"          "CCN"                  "CENSUS_TRACT"        
# [7] "DISTRICT"             "END_DATE"             "LATITUDE"            
# [10] "LONGITUDE"            "METHOD"               "NEIGHBORHOOD_CLUSTER"
# [13] "OBJECTID"             "OCTO_RECORD_ID"       "OFFENSE"             
# [16] "PSA"                  "REPORT_DAT"           "SHIFT"               
# [19] "START_DATE"           "VOTING_PRECINCT"      "WARD"                
# [22] "XBLOCK"               "YBLOCK"              

# **************************************************************************************************
# Using the dbplyr library to interact with the database

# This retrieves the our table in the database
crime <- tbl(con, db_table)
# # Source:   table<crime> [?? x 23]
# # Database: postgres [analyst@localhost:5432/project_crime]
# ANC   BID   BLOCK BLOCK_GROUP CCN   CENSUS_TRACT DISTRICT END_DATE LATITUDE LONGITUDE METHOD NEIGHBORHOOD_CL…
# <chr> <chr> <chr> <chr>       <chr> <chr>           <dbl> <chr>       <dbl>     <dbl> <chr>  <chr>           
#   1 2B    GOLD… 1000… 010700 1    0800… 010700              2 1970/01…     38.9     -77.0 OTHERS Cluster 6       
# 2 6C    NA    1100… 010600 2    0016… 010600              5 2009/11…     38.9     -77.0 OTHERS Cluster 25      
# 3 1B    NA    2000… 003500 2    0017… 003500              3 2009/12…     38.9     -77.0 OTHERS Cluster 3       
# 4 1B    NA    2200… 003500 2    0200… 003500              3 2002/01…     38.9     -77.0 OTHERS Cluster 3       
# 5 6E    NA    1300… 004902 1    0514… 004902              3 2005/04…     38.9     -77.0 KNIFE  Cluster 7       
# 6 8B    NA    2966… 007502 2    0616… 007502              7 2009/11…     38.9     -77.0 OTHERS Cluster 36      
# 7 8D    NA    2 - … 009807 2    0712… 009807              7 1970/01…     38.8     -77.0 OTHERS Cluster 39      
# 8 1A    NA    500 … 003200 3    0714… 003200              4 2007/10…     38.9     -77.0 OTHERS Cluster 2       
# 9 4C    NA    4300… 002301 2    0809… 002301              4 2008/07…     38.9     -77.0 OTHERS Cluster 18      
# 10 7F    NA    4000… 007803 1    0810… 007803              6 2008/07…     38.9     -76.9 GUN    Cluster 30      
# # … with more rows, and 11 more variables: OBJECTID <dbl>, OCTO_RECORD_ID <chr>, OFFENSE <chr>, PSA <dbl>,
# #   REPORT_DAT <chr>, SHIFT <chr>, START_DATE <chr>, VOTING_PRECINCT <chr>, WARD <dbl>, XBLOCK <dbl>, YBLOCK <dbl>
# > 


# Look at the data types per columns


# Assess duplicate incidents by CCN and OCTO_RECORD_ID.  Compare results, if any
# If there are duplicate records try to assess why.
# If there are duplicate records, create a new table de-duplicating records to reduce over counting


# Look at spatial groupings.
# Can we create a unique table for spatial aggregation?
# If there are missing values, can we fill in the information?

# During new crime table creation, reduce spatial columns and 
# replace with unique id related to unique spatial aggregation table


# The fields with Date/Time.
# Create table for Date/Time to parse out drill down/roll up values.