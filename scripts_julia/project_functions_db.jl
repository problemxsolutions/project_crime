# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# Julia: Version 1.5.3 (2020-11-09)

# This script provides functions to support my database operations for Project_Crime
import CSV
using DataFrames # library(tidyverse)
import Chain # library(magrittr)
import DBInterface # library(DBI)
import LibPQ
# library(RPostgreSQL)

"""
  pg_connect()
  Connect to desired PostgreSQL database using pg_connect().  Specify arguments if deviating from defaults.

  # Arguments
  - db: String. The database name to connect to.  Default value is "project_crime"
  - host_db: String. The host/server where the db being hosted.  Default server/host is "localhost"
  - db_port: String. Port the server is listening to.  Default port number for PostgreSQL is "5432"
  - db_user: String. The user for the database connecting to.  Default value for my criminal
  analysis project is "analyst"
  - db_password: String. The password for the user connecting to the database.
  Default value for my criminal analysis project is "mypassword"


  @return DBI connection to the PostgreSQL database.
  dbConnect() returns an S4 object that inherits from DBIConnection.
  This object is used to communicate with the database engine.
  A format() method is defined for the connection object.
  It returns a string that consists of a single line of text.
"""
function pg_connect(;db = "project_crime",
                    host_db = "localhost",
                    db_port = "5432",
                    db_user = "analyst",
                    db_password = "mypassword")

  conn_string = string(
    "dbname=$db",
    " host=$host_db",
    " port=$db_port",
    " user=$db_user",
    " password=$db_password",
    " connect_timeout=10"
    )

  return LibPQ.Connection( conn_string )
end

"""
  dbWriteTable_df()
  Initial workflow to mimic the R DBI::dbWriteTable.
  User will need to create table first.

  # Arguments
  - conn: LibPQ Connection to a PostgreSQL database.
  Default value is `pg_connect()`, which is defined in a separate function
  - df: DataFrame to upload into database
  - tableName: Name given to db table for the data
  - return_head: Boolean value for returning the top 5 rows of table
"""
function dbWriteTable_df(;conn=pg_connect(),
                        df,
                        tabel_name,
                        return_head = true)
  colnames_s = join(map(string, names(df)), ',')
  value_s = string("\$", join(map(string, [1:1:ncol(df);]), ",\$"))

  # Bulk Insertion method greatly increases performance
  LibPQ.execute(conn, "BEGIN;")
  LibPQ.load!(df,
    conn,
    string("INSERT INTO ", tabel_name, " (",colnames_s,") ",
      "VALUES (", value_s,");")
  )
  LibPQ.execute(conn, "COMMIT;")

  if return_head
    query_result = LibPQ.execute(conn,
      string("SELECT * FROM ", tabel_name, " LIMIT 5;"))
    query_results = DataFrame(query_result)
    print(query_results)
  end

end


"""
  dbCreateTable()
  Create Tables with string values for table name and column definitions.
  Please reference PostgreSQL datatypes documentation for more details
  on datatypes. https://www.postgresql.org/docs/13/datatype.html

  # Arguments
  - conn: LibPQ Connection to a PostgreSQL database.
  Default value is `pg_connect()`, which is defined in a separate function
  - df: DataFrame to upload into database
  - tableName: Name given to db table for the data
  - column_defs: string with column names and datatypes.
    Ex: colname1  datatype1, colname2  datatype2, ...
"""
function dbCreateTable(;conn=pg_connect(), tableName, column_defs)

  exe_s = string(
    "CREATE TABLE ", tableName,
    " (",column_defs, ");")

  result = LibPQ.execute(conn, exe_s)

end
"""
******************************************************
************** CURRENTLY IN DEVELOPMENT **************
******************************************************
"""

"""
  csv_to_db()
  Read in CSV file and load it into desired database.
  Specify arguments if deviating from defaults.

  # Arguments
  - file: CSV Filename to read and load into database
  - tableName: Name given to db table for the data
  - connection: LibPQ Connection to a PostgreSQL database.
  Default value is `pg_connect()`, which is defined in a separate function
"""
function csv_to_db(;file,
                   tableName="test_table",
                   connection=pg_connect())

  # csv_data = CSV.read(file, DataFrame)
  #
  # dbWriteTable_df(conn = connection,
  #                 df = csv_data,
  #                 tabel_name = tableName)
  #
  # println("Data Loading Complete.")
  # println() # Get Table Summary (tableName : row count, column count)
end


"""
  bulk_table_connections()
  Connect to desired database tables to get exploratory information.
  Specify arguments if deviating from defaults.

  # Arguments
  - connection: LibPQ Connection to a PostgreSQL database.
  Default value is `pg_connect()`, which is defined in a separate function
  - db_tables: Vector. Vector of strings that correspond to the name
  values of tables in the connecting database

  @return A list that contains a 2 sub-lists.  The first list contains the column names
  associated with each table provided by the `db_tables` parameter connection.  The
  second is a list of tables via connection, which is not an extract of all data in
  each table, but a virtual connection.
"""
function bulk_table_connections(;db_tables, connection=pg_connect())
  table_col_names_list = []
  db_data_list = []
  # for i in 1:length(db_tables)
  #   table_col_names_list[i] = LibPQ.column_names(jl_conn = connection,
  #                                             name = db_tables[i])
  #   db_data_list[i] = tbl(pg_connect(), db_tables[i])
  # end
  #
  # names(table_col_names_list) = db_tables
  # names(db_data_list) = db_tables
  #
  return
    Dict(column_names = table_col_names_list,
         tables = db_data_list)

end


"""
  data_exploration_spatial_initial()
  Connect to desired database tables to get exploratory information.
  Process spatial tables and output a simple features object

  # Arguments
  - connection: DBIConnection. DBI connection to a database.
  Default value is `pg_connect()`, which is defined in a separate function
  - table_name: String. String value of desired table name in the
  connecting database
  - virtual_data: Table Connection Object. Contains the virtual connection
  to the specified table in the database

  @return printlns some preliminary exploratory views of the desired table and
  returns a simple feature object of the desired data.
"""
function data_exploration_spatial_initial(;
  connection = pg_connect(),
  table_name,
  virtual_data)

    # println(virtual_data)
    # virtual_data %>% view

    # tmp_rc =
    #   virtual_data %>%
    #   summarise(count = n()) %>%
    #   pull()
    #
    # println(string("Total Rows: ", tmp_rc))
    #
    # # Display the Table information from the database side
    # table_info_output = rpostgis::dbTableInfo(conn = connection,
    #                                            name = table_name)
    # println(table_info_output)
    #
    # # Get the geometry data from the database and
    # # convert into sf object
    spatial_data = []
    #   rpostgis::pgGetGeom(conn = connection,
    #                       name = table_name,
    #                       geom = "geometry") %>%
    #   st_as_sf()
    return spatial_data
end
