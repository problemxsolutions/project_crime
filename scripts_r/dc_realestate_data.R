# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-4

library(tidyverse)
library(magrittr)
library(DBI)
# library(RPostgreSQL)

dir_destination <- '../data/real_estate/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)

# ******************************************************
# Open Data DC
# Construction Permits 2013
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2012
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2013
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2014
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2015
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2016
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2017
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2018
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2019
# URL: https://opendata.dc.gov/datasets/construction-permits-in-2020

# GeoJSON:
base_url <- 'https://opendata.arcgis.com/datasets/'

construction_permits <- c(
  '2009' = '',
  '2010' = '',
  '2011' = '',
  '2012' = '9cbe8553d4e2456ab6c140d83c7e83e0_15.geojson',
  '2013' = '3d49e06d51984fa2b68f21eed21eba1f_14.geojson',
  '2014' = '54b57e15f6944af8b413a5e4f88b070c_13.geojson',
  '2015' = 'b3283607f9b74457aff420081eec3190_29.geojson',
  '2016' = '2dc1a7dbb705471eb38af39acfa16238_28.geojson',
  '2017' = '585c8c3ef58c4f1ab1ddf1c759b3a8bd_39.geojson',
  '2018' = 'ca581e1b455a46caa266e3476f8205d2_0.geojson',
  '2019' = '107f535e5d3347a8ac1e46dbc13669d4_6.geojson',
  '2020' = 'ac617c291bbd466bbbea6272f87811d3_8.geojson'
)

# Building Permits 
# URL: https://opendata.dc.gov/datasets/building-permits-in-2009
# URL: https://opendata.dc.gov/datasets/building-permits-in-2010
# URL: https://opendata.dc.gov/datasets/building-permits-in-2011
# URL: https://opendata.dc.gov/datasets/building-permits-in-2012
# URL: https://opendata.dc.gov/datasets/building-permits-in-2013
# URL: https://opendata.dc.gov/datasets/building-permits-in-2014
# URL: https://opendata.dc.gov/datasets/building-permits-in-2015
# URL: https://opendata.dc.gov/datasets/building-permits-in-2016
# URL: https://opendata.dc.gov/datasets/building-permits-in-2017
# URL: https://opendata.dc.gov/datasets/building-permits-in-2018
# URL: https://opendata.dc.gov/datasets/building-permits-in-2019
# URL: https://opendata.dc.gov/datasets/building-permits-in-2020

# GeoJSON:
base_url <- 'https://opendata.arcgis.com/datasets'

building_permits <- c(
  '2009' = '4126c08db8434fea99a9d743cbb518f4_12.geojson',
  '2010' = 'ffd15e5b0d4046c4b904b11360fe66bc_11.geojson',
  '2011' = '0f81c8a90867452b909c1b94dec383e6_10.geojson',
  '2012' = '5f4ea2f25c9a45b29e15e53072126739_7.geojson',
  '2013' = '4911fcf3527246ae9bf81b5553a48c4d_6.geojson',
  '2014' = 'd4891ca6951947538f6707a6b07ae225_5.geojson',
  '2015' = '981c105beef74af38cc4090992661264_25.geojson',
  '2016' = '5d14ae7dcd1544878c54e61edda489c3_24.geojson',
  '2017' = '81a359c031464c53af6230338dbc848e_37.geojson',
  '2018' = '42cbd10c2d6848858374facb06135970_9.geojson',
  '2019' = '52e671890cb445eba9023313b1a85804_8.geojson',
  '2020' = '066cda75c1754a088e821baa1cf8ac18_2.geojson'
)

permits_list <- list(
  'construction' = construction_permits,
  'building' = building_permits
)
rm(building_permits, construction_permits)

dir_destination <- '../data/map_data/realestate/'
if(!dir.exists(dir_destination))
  dir.create(dir_destination)

for(i in 1:length(permits_list)){
  i_list_name <- names(permits_list[i])
  i_list <- permits_list[[i]]
  for(j in i_list){
    if(j != ""){
      temp_url <- paste0(base_url, j)
      element_name <- names(which(i_list == j))
      temp_file_name <- paste(i_list_name, "permits", element_name, sep = "_")

      download.file(url = temp_url,
                    destfile = paste0(dir_destination, temp_file_name,'.json'))
    }
  }
}
rm(temp_url, base_url, temp_file_name, permits_list, i_list_name, i_list)
rm(building_permits, construction_permits)
print('Processing Complete')
# !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * 
#
# Reference the dc_geodb.R script for loading the data into the PostgreSQL/PostGIS database
# https://problemxsolutions.com/project/crime/criminal-analysis-data-storage-part-2/
#
# !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * !!! * 

# ******************************************************
# FRED Economic Data
# S&P/Case-Shiller DC-Washington Home Price Index (WDXRSA)
# URL: https://fred.stlouisfed.org/series/WDXRSA#0

# All-Transactions House Price Index for Washington-Arlington-Alexandria, DC-VA-MD-WV (MSAD)
# Suggested Citation:
# U.S. Federal Housing Finance Agency, All-Transactions House Price Index for 
# Washington-Arlington-Alexandria, DC-VA-MD-WV (MSAD) [ATNHPIUS47894Q], retrieved from FRED, 
# Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/ATNHPIUS47894Q, November 24, 2020.
# URL: https://fred.stlouisfed.org/series/ATNHPIUS47894Q
# Quaterly data

# Real Median Household Income in the District of Columbia
# URL: https://fred.stlouisfed.org/series/MEHOINUSDCA672N

# Homeownership Rate for the District of Columbia
# URL: https://fred.stlouisfed.org/series/DCHOWN

# Rental Vacancy Rate for the District of Columbia
# URL: https://fred.stlouisfed.org/series/DCRVAC

# Home Vacancy Rate for the District of Columbia
# URL: https://fred.stlouisfed.org/series/DCHVAC

# New Private Housing Units Authorized by Building Permits for District of Columbia
# URL: https://fred.stlouisfed.org/series/DCBPPRIV

# Business Applications for District of Columbia
# URL: https://fred.stlouisfed.org/series/BUSAPPWNSADC


# Since there was no API to programmatically download from each of the URLs, 
# I downloaded all the data via csv to a local directory.
econ_data <- c(
  'Median_Household_Income' = '../data/real_estate/RealMedianHouseholdIncome_DC_FRED.csv',
  'Rental_Vacany_Rates' = '../data/real_estate/DCRVAC_FRED.csv',
  'Home_Vacancy_Rates' = '../data/real_estate/DCHVAC_FRED.csv',
  'Home_Ownership_Rates'= '../data/real_estate/DCHOWN_FRED.csv',
  'Housing_Price_Index' = '../data/real_estate/HousingPriceIndex_WashArlAlex_FRED.csv',
  'New_Private_Housing_Units' = '../data/real_estate/DCBPPRIV_FRED.csv',
  'Business_Applications' = '../data/real_estate/BUSAPPWNSADC_FRED.csv'
)

# ******************************************************
# RedFin Data Center 
# Guidelines for Using this Data
# You are welcome to use this data for your own purposes, 
# we just ask that you cite the source. Please include proper
# citation and link to Redfin for the first reference on a 
# page, post, or article.

# Home Prices, Sales and Inventory
# February 2012 through October 2020
# URL: https://www.redfin.com/news/data-center/
# URL: https://redfin-public-data.s3-us-west-2.amazonaws.com/redfin_covid19/weekly_housing_market_data_most_recent.tsv

red_fin <- c(
'rf_price_sales_inventory' = '../data/real_estate/redfin_data_201202_202010.csv',
'rf_covid_weekly_markets' = '../data/real_estate/weekly_housing_market_data_most_recent.csv'
)

# ******************************************************
# Realtor.com Research Data
# Inventory Monthly data
# Market trends and monthly statistics on active for-sale listings 
# (including median list price, average list price, luxury list price, 
# median days on market, average days on market, total active listings, 
# new listings, price increases, price reductions). Attribution: cite 
# any full or partial use of the data to the ‘realtor.com residential 
# listings database.’
# URL: https://www.realtor.com/research/data/

realtor_dot_com <- c(
  'rdc_inventory' = '../data/real_estate/RDC_Inventory_Core_Metrics_County_History.csv'
)


# ***********************************************
# Load data from CSV files into databse
# ***********************************************
# ***************************************************************************

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

data_to_import <- c(econ_data, red_fin, realtor_dot_com)

for(i in data_to_import){
  table_basename <- names(which(data_to_import == i))
  
  # I noticed my Redfin files were not processing correctly so needed a special case
  special_read <- table_basename %>% str_detect(string = ., pattern = "(rf_)")
  
  if(!special_read){
    data <- read_csv(file = i)
  }else{
    data <- read_delim(file = i, delim = '\t', )
    data %<>% rename_with(., ~ gsub(' ', '_', .x, fixed = T))
  }
  
  dbWriteTable(conn = con,
               name = table_basename,
               value = data %>%  as.data.frame(.))
}

dbListTables(conn = con)
# [1] "weather"                   "temperature"               "dc_unemployed_ward"        "dc_unemployed_insurance"   "national_unemployed"      
# [6] "moon_phase"                "sunrise_sunset"            "crime"                     "charter_school_points"     "dc_polygon"               
# [11] "metro_bus_stop_points"     "metro_station_points"      "summer_public_points"      "geography_columns"         "geometry_columns"         
# [16] "spatial_ref_sys"           "police_district_polygons"  "police_station_points"     "psa_polygons"              "public_school_points"     
# [21] "transform_school_points"   "ward_polygons"             "zipcode_polygons"          "building_permits"          "construction_permits"     
# [26] "Median_Household_Income"   "Rental_Vacany_Rates"       "Home_Vacancy_Rates"        "Home_Ownership_Rates"      "Housing_Price_Index"      
# [31] "New_Private_Housing_Units" "Business_Applications"     "rf_price_sales_inventory"  "rf_covid_weekly_markets"   "rdc_inventory"     
