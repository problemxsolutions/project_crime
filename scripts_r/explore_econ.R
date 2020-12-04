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