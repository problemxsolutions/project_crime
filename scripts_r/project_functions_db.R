# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# This script provides functions to support my database operations for Project_Crime

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)


pg_connect <- function(db = 'project_crime',
                       host_db = 'localhost', 
                       db_port = '5432',
                       db_user = 'analyst',
                       db_password = 'mypassword'){
  
  #' @description 
  #' Connect to desired PostgreSQL database using pg_connect().  Specify arguments if deviating from defaults.
  #' 
  #' @param  db String. The database name to connect to.  Default value is 'project_crime'
  #' @param  host_db String. The host/server where the db being hosted.  Default server/host is 'localhost'
  #' @param  db_port String. Port the server is listening to.  Default port number for PostgreSQL is '5432'
  #' @param  db_user String. The user for the database connecting to.  Default value for my criminal 
  #' analysis project is 'analyst'  
  #' @param  db_password String. The password for the user connecting to the database.  
  #' Default value for my criminal analysis project is 'mypassword'
  #' 
  #' @return DBI connection to the PostgreSQL database.  
  #' dbConnect() returns an S4 object that inherits from DBIConnection. 
  #' This object is used to communicate with the database engine. 
  #' A format() method is defined for the connection object. 
  #' It returns a string that consists of a single line of text.
  
  return(
    DBI::dbConnect(RPostgres::Postgres(), 
                        dbname = db, 
                        host=host_db,
                        port=db_port,
                        user=db_user, 
                        password=db_password)  
  )  
}


bulk_table_connections <- function(connection = pg_connect(), 
                                   db_tables){
    #' @description 
    #' Connect to desired database tables to get exploratory information.  
    #' Specify arguments if deviating from defaults.
    #' 
    #' @param  connection DBIConnection. DBI connection to a database.  
    #' Default value is `pg_connect()`, which is defined in a separate function
    #' @param  db_tables Vector. Vector of strings that correspond to the name 
    #' values of tables in the connecting database
    #' 
    #' @return A list that contains a 2 sub-lists.  The first list contains the column names 
    #' associated with each table provided by the `db_tables` parameter connection.  The  
    #' second is a list of tables via connection, which is not an extract of all data in 
    #' each table, but a virtual connection.
    
    table_col_names_list <- list()
    db_data_list <- list()
    for (i in 1:length(db_tables)){
      table_col_names_list[[i]] <- dbListFields(conn = connection, 
                                                name = db_tables[i])
      db_data_list[[i]] <- tbl(pg_connect(), db_tables[i])
    }
    names(table_col_names_list) <- db_tables
    names(db_data_list) <- db_tables
    
    return(
      list(column_names = table_col_names_list,
           tables = db_data_list)
    )
  }