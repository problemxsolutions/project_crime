# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)

# Source project functions:
source('~/ProblemXSolutions.com/DataProjects/DC_Crime/project_crime/scripts_r/project_functions_db.R')

# create the graphics output directory for saving visualizations
dir_destination <- '../graphics/data_explore/crime_graphics/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)


dbListTables(conn = pg_connect())
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

# Assign the table name to a variable
db_table <- 'crime'

# Get the column names for the table
table_col_names <- dbListFields(conn = pg_connect(), name = db_table)
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
crime <- tbl(pg_connect(), db_table)
# # Source:   table<crime> [?? x 23]
# # Database: postgres [analyst@localhost:5432/project_crime]
#    ANC   BID   BLOCK BLOCK_GROUP CCN   CENSUS_TRACT DISTRICT END_DATE LATITUDE LONGITUDE METHOD NEIGHBORHOOD_CL…
#    <chr> <chr> <chr> <chr>       <chr> <chr>           <dbl> <chr>       <dbl>     <dbl> <chr>  <chr>           
#  1 2B    GOLD… 1000… 010700 1    0800… 010700              2 1970/01…     38.9     -77.0 OTHERS Cluster 6       
#  2 6C    NA    1100… 010600 2    0016… 010600              5 2009/11…     38.9     -77.0 OTHERS Cluster 25      
#  3 1B    NA    2000… 003500 2    0017… 003500              3 2009/12…     38.9     -77.0 OTHERS Cluster 3       
#  4 1B    NA    2200… 003500 2    0200… 003500              3 2002/01…     38.9     -77.0 OTHERS Cluster 3       
#  5 6E    NA    1300… 004902 1    0514… 004902              3 2005/04…     38.9     -77.0 KNIFE  Cluster 7       
#  6 8B    NA    2966… 007502 2    0616… 007502              7 2009/11…     38.9     -77.0 OTHERS Cluster 36      
#  7 8D    NA    2 - … 009807 2    0712… 009807              7 1970/01…     38.8     -77.0 OTHERS Cluster 39      
#  8 1A    NA    500 … 003200 3    0714… 003200              4 2007/10…     38.9     -77.0 OTHERS Cluster 2       
#  9 4C    NA    4300… 002301 2    0809… 002301              4 2008/07…     38.9     -77.0 OTHERS Cluster 18      
# 10 7F    NA    4000… 007803 1    0810… 007803              6 2008/07…     38.9     -76.9 GUN    Cluster 30      
# # … with more rows, and 11 more variables: OBJECTID <dbl>, OCTO_RECORD_ID <chr>, OFFENSE <chr>, PSA <dbl>,
# #   REPORT_DAT <chr>, SHIFT <chr>, START_DATE <chr>, VOTING_PRECINCT <chr>, WARD <dbl>, XBLOCK <dbl>, YBLOCK <dbl>

# **************************************************************************************************
# Define the columns to evaluate first
query_parameters <- table_col_names[
  !(table_col_names %in% c('XBLOCK', 'YBLOCK', 
                           'START_DATE', 'END_DATE', 
                           'REPORT_DAT',
                           'OCTO_RECORD_ID', 'CCN',
                           'LATITUDE', 'LONGITUDE'))
]

# This is my base query to get a distinct list of values for the 'ANC" column and a count per value.
# What this provides is a distribution of values in the dataset.
crime_anc <- crime %>% group_by(ANC) %>% summarise(cnt = n())


# https://db.rstudio.com/databases/postgresql/
# The DBI interface points out a known issue with using ? to mark 
# parameters in a query.  It suggests using $ instead.
# Unfortunately after testing the parameterization, I was not able
# to get the expected results from the queries.

# Taking that concept I can apply it to each column in the dataset.
# I direct the list of returned tables/data frames created into a variable
crime_table_summaries <- 
  lapply(X = query_parameters, 
         FUN = function(X){
           query_string <- paste0('SELECT "', X,
                                  '", COUNT(*) as CNT ',
                                  'FROM ', db_table, ' ',
                                  'GROUP BY "', X,'";')
           # print(query_string)
           RPostgres::dbGetQuery(conn = pg_connect(),
                                 statement = query_string)
         })

# glance at the results
crime_table_summaries[[14]]

# First I've create a simple test cast to see how the plot will turn out.
# This where I fix up any aesthetics.  This is just an exploration so it'll
# be somewhat crude.
test_df <- crime_table_summaries[[2]] %>% tibble 
test_df %>% nrow()
print(test_df)

ggplot(data = test_df, 
       aes(y = as.numeric(cnt))) +
  geom_point(aes_string(x = colnames(test_df)[1])) +
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 0.5, 
                                   hjust = 1)) +
  labs(y = "Count") +
  ggtitle(label = paste0('Criminal Activity by ', colnames(test_df)[1]))
  

# This gives us a quick view as to what size each of the input field tables were so we can
# see what will not have an associated plot
column_sizes <-
  sapply(1:length(crime_table_summaries), 
         function(x) nrow(crime_table_summaries[[x]])) %>% 
  tibble()
column_sizes %<>% mutate(names = query_parameters)

# Plot the distribution of values for each qualifying field
# The output of the `lapply` function, produces a simple plot to show 
# the count distribution of incidents by their particular field.  It 
# provides no temporal context.  The distributions help to convey where
# the data is and if there are any outliers.
plot_list <- 
  lapply(1:length(query_parameters), 
         function(x) {
           tmp_df <- 
             crime_table_summaries[[x]] %>% 
             tibble 
           
           if (nrow(tmp_df) < 100){
             return(
               ggplot(data = tmp_df, 
                      aes(y = as.numeric(cnt))) +
                 geom_point(aes_string(x = colnames(tmp_df)[1])) +
                 theme(axis.text.x = element_text(angle = 90, 
                                                  vjust = 0.5, 
                                                  hjust = 1)) +
                 labs(y = "Count") +
                 ggtitle(label = paste0('Criminal Activity by ', colnames(tmp_df)[1]))
             )
           }else{
             return("Plot axis too large (>100)")
           }
         })

# Test that a plot was not produced
crime_table_summaries[[13]]
plot_list[[13]]

# Use this to view the plots
plot_list[[11]]

# ** OR **
# You can save off the graphics that were produced to the directory defined 
# at the top of the script
for(i in 1: length(plot_list)){
  if(is.ggplot(plot_list[[i]])){
    plot_name <- colnames(plot_list[[i]]$data)[1]
    ggsave(filename = paste0("Distribution_Crime_by_", plot_name,".png"),
           path = dir_destination, 
           plot = plot_list[[i]], 
           device = "png", 
           width = 8, height = 6, units = "in")  
  }
}

# we could've also put the ggsave function into our original `lapply` loop rather than creating a new

# **********************************************************************************************
# PART II : Record ID, CCN and Date Review
# Assess duplicate incidents by CCN and OCTO_RECORD_ID.  Compare results, if any.
# If there are duplicate records try to assess why.
# If there are duplicate records, create a new table de-duplicating 
# records to reduce over counting
# **********************************************************************************************
query_record_parameters <- 
  table_col_names[ c('OBJECTID', 'OCTO_RECORD_ID', 'CCN') ]

query_string_CCN_RecID <- 
  paste0('SELECT ',
         '"', X, '", ',
         'COUNT(*) as CNT ',
         'FROM ', db_table, ' ',
         'GROUP BY "', X,'";')

RPostgres::dbGetQuery(conn = pg_connect(),
                      statement = query_string)


# **********************************************************************************************
# PART III : Spatial Groupings
# The fields with Date/Time.
# Create table for Date/Time to parse out drill down/roll up values.
query_date_parameters <- 
  table_col_names[ c('START_DATE', 'END_DATE', 'REPORT_DAT') ]



# **********************************************************************************************
# PART IV : Spatial Groupings
# Can we create a unique table for spatial aggregation?
# If there are missing values, can we fill in the information?

# During new crime table creation, reduce spatial columns and 
# replace with unique id related to unique spatial aggregation table