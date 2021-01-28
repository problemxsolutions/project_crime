# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# Julia: Version 1.5.3 (2020-11-09)
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
# We can see here that our "project_crime" database was created properly
# postgres=# \l
# postgres=#

# postgres=# \c project_crime
# project_crime=#

# Create User and Password
# project_crime=# create user analyst with encrypted password "mypassword";

# Grant that user with privileges to the database
# project_crime=# grant all privileges on database project_crime to analyst;


# Now that we have established our database and user we can begin creating
# our tables to store our project data

# if you want to quit your PostgreSQL shell, type:
# project_crime=# \q
# postgres@linux-HP-ProBook-455-G3:~$ exit

# the final command brings you back to your normal shell.

# ***************************************************************************
using CSVFiles
using DataFrames # library(tidyverse)
using Tables
import Chain # library(magrittr)
# using HTTP # library(xml2)
# library(DBI)
# library(RPostgreSQL)

# Source project functions:
base_dir = "/home/linux/ProblemXSolutions.com/DataProjects/DC_Crime"
include("$base_dir/project_crime/scripts_julia/project_functions_db.jl")


# ******************************************************************************
# lets write some data to a new table in our db
base_dir_wx = "$base_dir/data/weather"
filename = "$base_dir_wx/full_wx_data_2009_2019.csv"
wx_data_to_db = load(filename) |> DataFrame

tabel_name = "weather_julia_load"
exe_s = string(
  "CREATE TABLE ", tabel_name, " (",
  "date       timestamp,",
  "datatype   varchar(4),",
  "station    varchar(17),",
  "value      int,",
  "fl_m       varchar(2),",
  "fl_q       varchar(10),",
  "fl_so      varchar(1),",
  "fl_t       int,",
  "units      varchar(25)",
  ");")

result = LibPQ.execute(pg_connect(), exe_s)

dbWriteTable_df(conn = pg_connect(),
                df = wx_data_to_db,
                tabel_name = tabel_name,
                return_head = true)

# Need to create version of function in Julia
# dbReadTable(con, "weather") %>% head()

# List all the tables currently in the connected database
# dbListTables(pg_connect()) # Need to create version of function in Julia

# Load the rest of the weather, temperature, moon phase and sun time data
# NOAA CDO temperature data for DCA airport 2009-2019
base_dir_wx = "$base_dir/data/weather"
filename = "$base_dir_wx/weather_temp_table.csv"
temperature_data = load(filename) |> DataFrame
# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
                df = temperature_data,
                tabel_name = "temperature_jl")

# Moon Phase data from 2009-01-01 to 2020-11-24
filename = "$base_dir_wx/moon_phase_data.csv"
moon_phase_data = load(filename) |> DataFrame
# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
                df = moon_phase_data,
                tabel_name = "moon_phase_jl")


# Sunrise/Sunset data for Washington DC from 2009-01-01 to 2020-11-24
filename = "$base_dir_wx/suntimes_data.csv"
suntimes_data = load(filename) |> DataFrame
# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
                df = suntimes_data,
                tabel_name = "sunrise_sunset_jl")

# List all the tables currently in the connected database
# Need to create version of function in Julia
# dbListTables(pg_connect())

# ******************************************************************************
# DC by Ward Employment Data
base_dir_emp = "$base_dir/data/employment"
filename = "$base_dir_emp/PROCESSED_CY2009_2019_unemployment_ward_month_year.csv"
employment = load(filename) |> DataFrame
# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
                df = employment,
                tabel_name = "dc_unemployed_ward_jl")

# DC Unemployed Insurance Claims
filename = "$base_dir_emp/PROCESSED_CY2009_2021_weekly_unemployment_insurance_claims.csv"
doleta_data = load(filename) |> DataFrame
# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
               df = doleta_data,
               tabel_name = "dc_unemployed_insurance_jl")

# National Unemployment Rate
filename = "$base_dir_emp/PROCESSED_USBLS_unemploymentrates_bymonth_2009_2020.csv"
bls_data = load(filename) |> DataFrame
# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
               df = bls_data,
               tabel_name = "national_unemployed_jl")

# ******************************************************************************

# Now I will read in the crime data files and write them to a single table in my PostgreSQL database
base_dir_crime = "$base_dir/data/crime"
filename = "$base_dir_crime/crime_table_CY2009.csv"
db_crime_data = load(filename) |> DataFrame
# Since there I have not created nor defined the crime table previously
# I will use the first file of data to create the table.  The for-loop
# below will append the rest of the data to the crime table

# *** Still need to create table processes ***

dbWriteTable_df(conn = pg_connect(),
               df = db_crime_data,
               tabel_name = "crime_jl")

for(source_year in 2010:2020){
  print(paste( "start:", source_year))

  filename = string(base_dir_crime,"/", "crime_table_CY", source_year,".csv")
  db_crime_data = load(filename) |> DataFrame
"""
DEV NOTE: Need to determine if my current function appends to the table it
is writing to if it already has data in it
"""
  dbWriteTable_df(conn = pg_connect(),
                 df = db_crime_data,
                 tabel_name = "crime_jl")
  # R VERSION:
  # dbWriteTable(conn = pg_connect(),
  #              append = T,
  #              name = "crime",
  #              value = db_crime_data %>%  as.data.frame(.))
  #
  println(string( "end: ", source_year))
}
println("Crime data loaded into Project_Crime database")

# ******************************************************************************
# List all the tables currently in the connected database

# Need to create version of function in Julia
# dbListTables(pg_connect())

LibPQ.close(pg_connect())
