# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-#/

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)
library(elastic)

# Establish a connect to ElasticSearch.
# You need to make sure you have already started the service
# (shell)$ sudo systemctl start postgresql@13-main

# Establish a connect to ElasticSearch.
# You need to make sure you have already started the service
# (shell)$ sudo systemctl start elasticsearch.service
# (shell)$ sudo systemctl start kibana.service

# Source project functions:
source('~/ProblemXSolutions.com/DataProjects/DC_Crime/project_crime/scripts_r/project_functions_db.R')

# List database tables
# dbListTables(conn = pg_connect())
# **************************************************************************************************

# Assign the table name to a variable
db_table <- 'crime'

# Get the data for the table as a connection. 
# This does not collect all the data.
db_data <- tbl(pg_connect(), db_table)

# Preview The Start_Date table we created
# db_data_start_date <- tbl(pg_connect(), "crime_start_date")

# Get all the field names for the table
table_col_names <- dbListFields(conn = pg_connect(), 
                                name = db_table)

# Determine which fields not are necessary for the ElasticSearch Database.
#  Modify as you wish.
columns_to_exclude <- c('XBLOCK', 'YBLOCK', 'BLOCK',
                        'BLOCK_GROUP', 'START_DATE')

# Get the subset of column names
table_col_names_subset <- 
   table_col_names[!(table_col_names %in% columns_to_exclude)]

# Combine the vector names into a string, formatted for the database query.
query_select <- 
   str_c(table_col_names_subset, collapse = '", "')

es_connect <- connect()

# ElasticSearch Documentation on the Geo-Poin and Date formats/mappings
# Date:
# https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html
# Geo-Point:
# https://www.elastic.co/guide/en/elasticsearch/reference/current/geo-point.html
index_body <- '{
   "mappings" : {
     "properties" : {
       "location" : { "type" : "geo_point"},
        "datetime" : {
            "type" : "date", 
            "format" : "yyyy-MM-dd HH:mm:ss"
         }
      }
   }
}'

index_name <- 'crime_data'

# Delete index if it exists or you want to start over.
# index_delete(conn = es_connect, index = index_name)

# Create index at the given connection for the given
# index name and specified data mappings.
# index_create(conn = es_connect, index = index_name, body = index_body)

# Bulk loading data by year.  This reduces the amount of data I have in-memory
crime_yr <- c(2009:2020)
for (i in crime_yr){
   
   # Constructed a SQL statement to filter the crime_start_data table on the year
   # Then inner-join with the crime table, selecting the predefined columns from 
   # the crime table and two from the crime_start_data table.
   # Modify to suit your needs.
   query_string <- paste0('SELECT \"', query_select, '\", ',
                          'df2.datetime, df2.date ',
                          'FROM ', db_table, ' ',
                          'INNER JOIN (',
                          'select * from crime_start_date ', 
                          'where year = ', i, 
                          ') as df2 ',
                          'on df2."START_DATE" = ', 
                          db_table, '."START_DATE"',
                          ';')
   
   # Get the data based on the query statement
   db_data_subset <-
      RPostgres::dbGetQuery(conn = pg_connect(),
                            statement = query_string)
   
   # add location field to conform to the ElasticSearch 
   # datatype format for geo-point.  If you want to make
   # additional modifications this is the place to do it
   # before loading the data.
   db_data_subset %<>% 
      mutate(location = paste0(LATITUDE,',', LONGITUDE))
   
   # Bulk load the data into the provided ElasticSearch connection,
   # in the pre-defined index name.  We will also allow ES to create
   # UUIDs for the records.
   invisible(
      docs_bulk(
         conn = es_connect,
         index = index_name, 
         x = db_data_subset, 
         es_ids = T # assigns ElasticSearch UUIDs (True by default)
      )
   )

   # Validate by getting record count in index
   print(paste("finished uploading crime data from :", i))
   count(conn = es_connect, index=index_name) %>% 
      paste("Total Records in Index:", .) %>% 
      print
   
}