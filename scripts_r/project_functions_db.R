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
                       db_password = 'mypassword',
                       method = 1){
  
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
  #' @param  method Integer. Indicates which method to use to create a connection.  
  #' Default value for my criminal analysis project is method 1.
  #' method 1: uses DBI and RPostgres pacakages.  Did not work over a network.
  #' method 2: uses RPostgres and odbc pacakages. Worked over network
  #' method 3: uses odbc and RPostgreSQL pacakages. Worked over network
  #' method 4: uses the RPostgres pacakage. Worked over network
  #' method 5: uses odbc and RPostgres pacakages. Worked over network
  #' 
  #' @return DBI connection to the PostgreSQL database.  
  #' dbConnect() returns an S4 object that inherits from DBIConnection. 
  #' This object is used to communicate with the database engine. 
  #' A format() method is defined for the connection object. 
  #' It returns a string that consists of a single line of text.
  
  if(method == 1){
    con <- DBI::dbConnect(drive = RPostgres::Postgres(), 
                          dbname       = db, 
                          host         = host_db,
                          port         = db_port,
                          user         = db_user, 
                          password     = db_password)  
  }else if(method == 2){
    con <- RPostgres::dbConnect(odbc::odbc(), 
                                driver   = "PostgreSQL ANSI",
                                database = db,
                                UID      = db_user,
                                PWD      = db_password,
                                host     = host_db,
                                port     = db_port)
  }else if(method == 3){
    con <- RPostgreSQL::dbConnect(odbc::odbc(), 
                                  drv       = dbDriver("PostgreSQL"),
                                  dbname    = db,
                                  user      = db_user,
                                  password  = db_password,
                                  host      = host_db,
                                  port      = db_port)
  }else if(method == 4){
    con <- RPostgres::dbConnect(drv       = RPostgres::Postgres(),
                                dbname    = db,
                                user      = db_user,
                                password  = db_password,
                                host      = host_db,
                                port      = db_port)
  }else if(method == 5){
    con <- odbc::dbConnect(odbc::odbc(), 
                           driver   = "PostgreSQL ANSI",
                           database = db,
                           uid      = db_user,
                           pwd      = db_password,
                           server   = host_db,
                           port     = db_port)
  }
  
  return( con )
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

data_exploration_spatial_initial <- 
  function(connection = pg_connect(), 
           table_name, 
           virtual_data){
    #' @description 
    #' Connect to desired database tables to get exploratory information.
    #' Process spatial tables and output a simple features object
    #' 
    #' @param  connection DBIConnection. DBI connection to a database.  
    #' Default value is `pg_connect()`, which is defined in a separate function
    #' @param  table_name String. String value of desired table name in the 
    #' connecting database
    #' @param  virtual_data Table Connection Object. Contains the virtual connection
    #' to the specified table in the database
    #' 
    #' @return Prints some preliminary exploratory views of the desired table and
    #' returns a simple feature object of the desired data.

    print(virtual_data)
    # virtual_data %>% view
    
    tmp_rc <- virtual_data %>%  
      summarise(count = n()) %>% 
      pull()
    
    print(paste0("Total Rows: ", tmp_rc))
    
    # Display the Table information from the database side
    table_info_output <- rpostgis::dbTableInfo(conn = connection, 
                                               name = table_name)
    print(table_info_output)
    
    # Get the geometry data from the database and 
    # convert into sf object
    spatial_data <- 
      rpostgis::pgGetGeom(conn = connection, 
                          name = table_name, 
                          geom = "geometry") %>% 
      st_as_sf()
    return(spatial_data)
  }
