# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-data-storage/

# PostgreSQL Install resources
# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
# For  installation on to computers not on Linux/Ubuntu, 
# please navigate to your specific configuration on their page.
# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
# URL: https://www.postgresql.org/download/linux/ubuntu/

# URL: https://www.postgresqltutorial.com/install-postgresql-linux/

# Starting the database server.  This should be run when you want to use the database if the service was stopped previously.:
# (terminal)$ sudo systemctl start postgresql@13-main

# This will connect you to PostgreSQL using the postgres role (default role)
# (terminal)$ sudo -i -u postgres

# Next we will access PostgreSQL
# (terminal)$ psql
# postgres=# create database project_crime;
# CREATE DATABASE

# This will list the databases that exist.  
# We can see here that our 'project_crime' database was created properly
# postgres=# \l
# postgres=# 

# postgres=# \c project_crime 
# project_crime=# 

# Create User and Password
# project_crime=# create user analyst with encrypted password 'mypassword';

# Grant that user with privileges to the database
# project_crime=# grant all privileges on database project_crime to analyst;


# Now that we have established our database and user we can begin creating 
# our tables to store our project data

# if you want to quit your PostgreSQL shell, type:
# project_crime=# \q 
# postgres@linux-HP-ProBook-455-G3:~$ exit

# the final command brings you back to your normal shell.

# ***************************************************************************
library(tidyverse) 
library(magrittr)
library(DBI)
# library(RPostgreSQL)
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

# ******************************************************************************
# lets write some data to a new table in our db
wx_data_to_db <- read_csv(file = '../data/weather/wx_data_2009_2019.csv')
dbWriteTable(conn = con, 
             name = "weather", 
             value = wx_data %>%  as.data.frame(.))
dbReadTable(con, 'weather') %>% head()

# List all the tables currently in the connected database
dbListTables(con)

# Load the rest of the weather, temperature, moon phase and sun time data
# NOAA CDO temperature data for DCA airport 2009-2019
temperature_data <- read_csv(file = '../data/weather/weather_temp_table.csv')
dbWriteTable(conn = con, 
             name = "temperature", 
             value = temperature_data %>%  as.data.frame(.))

# Moon Phase data from 2009-01-01 to 2020-11-24
moon_phase_data <- read_csv(file = '../data/weather/moon_phase_data.csv')
dbWriteTable(conn = con, 
             name = "moon_phase", 
             value = moon_phase_data %>%  as.data.frame(.))

# Sunrise/Sunset data for Washington DC from 2009-01-01 to 2020-11-24
suntimes_data <- read_csv(file = '../data/weather/suntimes_data.csv')
dbWriteTable(conn = con, 
             name = "sunrise_sunset", 
             value = suntimes_data %>%  as.data.frame(.))

# List all the tables currently in the connected database
dbListTables(con)

# ******************************************************************************
# DC by Ward Employment Data
employment <- read_csv(file = '../data/employment/PROCESSED_CY2009_2019_unemployment_ward_month_year.csv')
dbWriteTable(conn = con, 
             name = "dc_unemployed_ward", 
             value = employment %>%  as.data.frame(.))

# DC Unemployed Insurance Claims
doleta_data <- read_csv(file = '../data/employment/PROCESSED_CY2009_2021_weekly_unemployment_insurance_claims.csv') 
dbWriteTable(conn = con, 
             name = "dc_unemployed_insurance", 
             value = doleta_data %>%  as.data.frame(.))

# National Unemployment Rate
bls_data <- read_csv(file = '../data/employment/PROCESSED_USBLS_unemploymentrates_bymonth_2009_2020.csv') 
dbWriteTable(conn = con, 
             name = "national_unemployed", 
             value = bls_data %>%  as.data.frame(.))

# ******************************************************************************

# Now I will read in the crime data files and write them to a single table in my PostgreSQL database
db_crime_data <- read_csv(file = paste0('../data/crime/crime_table_CY2009.csv'))

# Since there I have not created nor defined the crime table previously 
# I will use the first file of data to create the table.  The for-loop 
# below will append the rest of the data to the crime table
dbWriteTable(conn = con,
             name = "crime",  
             value = db_crime_data %>%  as.data.frame(.))

for(source_year in 2010:2020){
  print(paste( "start:", source_year))
  
  db_crime_data <- read_csv(file = paste0('../data/crime/crime_table_CY', source_year,'.csv'))
  
  dbWriteTable(conn = con, 
               append = T,
               name = "crime",  
               value = db_crime_data %>%  as.data.frame(.))
  print(paste( "end:", source_year))
}
print("Crime data loaded into Project_Crime database")

# ******************************************************************************
# List all the tables currently in the connected database
dbListTables(con)

