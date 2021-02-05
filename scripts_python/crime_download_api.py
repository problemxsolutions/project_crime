# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# Python: Version 3.8.5 (2020-07-20)

# For the full tutorial, please reference URL: 
# https://problemxsolutions.com/project/crime/criminal-analysis-planning/
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-0/

# These are the resources for Washington DC Criminal Data
# URL: https://opendata.dc.gov/search?collection=Dataset&q=Crime

import requests # https://2.python-requests.org/en/master/
import pandas as pd
import json
import geojson as gj #v2.5.0
import geopandas as gpd #v0.8.2

base_dir = "/home/linux/ProblemXSolutions.com/DataProjects/DC_Crime"
dir_destination = base_dir + "/data/crime"

if(!dir.exists(dir_destination))
  dir.create(dir_destination)

# Assess the URLs and reduce to unique portions

# ****************************************************************
# JSON file
# ****************************************************************
base_url = "https://maps2.dcgis.dc.gov/dcgis/rest/services/FEEDS/MPD/MapServer"
query_end_url = "query?where=1%3D1&outFields=*&outSR=4326&f=json"

crime_data_json = [
  {"year" : "2009", "doc" : "33"},
  {"year" : "2010", "doc" :  "34"},
  {"year" : "2011", "doc" : "35"},
  {"year" : "2012", "doc" : "11"},
  {"year" : "2013", "doc" : "10"},
  {"year" : "2014", "doc" : "9"},
  {"year" : "2015", "doc" : "27"},
  {"year" : "2016", "doc" : "26"},
  {"year" : "2017", "doc" : "38"},
  {"year" : "2018", "doc" : "0"},
  {"year" : "2019", "doc" : "1"},
  {"year" : "2020", "doc" : "2"}
]

# API URL to the last 30 days of criminal activity
# crime_data_last30days = "/8"

# Sample Preview of the JSON output.  Returned only 1000 Results
i = crime_data_json["2014"]
full_url = base_url + "/" + i + "/" + query_end_url
doc = requests.get(full_url)
data0 = doc.json() 
# data0['fields']

# alternative 
data01 = json.loads(doc.text)
data01["fields"]
data01['fields'][0]

# ****************************************************************
# GeoJSON file
# ****************************************************************
base_url = "https://opendata.arcgis.com/datasets/"

crime_data_geojson_dict = [
  {"year" : "2009", "doc" : "73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson"},
  {"year" : "2010", "doc" :  "fdacfbdda7654e06a161352247d3a2f0_34.geojson"},
  {"year" : "2011", "doc" : "9d5485ffae914c5f97047a7dd86e115b_35.geojson"},
  {"year" : "2012", "doc" : "010ac88c55b1409bb67c9270c8fc18b5_11.geojson"},
  {"year" : "2013", "doc" : "5fa2e43557f7484d89aac9e1e76158c9_10.geojson"},
  {"year" : "2014", "doc" : "6eaf3e9713de44d3aa103622d51053b5_9.geojson"},
  {"year" : "2015", "doc" : "35034fcb3b36499c84c94c069ab1a966_27.geojson"},
  {"year" : "2016", "doc" : "bda20763840448b58f8383bae800a843_26.geojson"},
  {"year" : "2017", "doc" : "6af5cb8dc38e4bcbac8168b27ee104aa_38.geojson"},
  {"year" : "2018", "doc" : "38ba41dd74354563bce28a359b59324e_0.geojson"},
  {"year" : "2019", "doc" : "f08294e5286141c293e9202fcd3e8b57_1.geojson"},
  {"year" : "2020", "doc" : "f516e0dd7b614b088ad781b0c4002331_2.geojson"}
]
# We can access the dictionary using the index
crime_data_geojson_dict[0]

# To access either the year or the doc values, simply reference either for the given list element.
crime_data_geojson_dict[0]["year"]
crime_data_geojson_dict[0]["doc"]

# Alternatively using a list structure
crime_data_geojson_list = [
  ["2009" , "73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson"],
  ["2010" , "fdacfbdda7654e06a161352247d3a2f0_34.geojson"],
  ["2011" , "9d5485ffae914c5f97047a7dd86e115b_35.geojson"],
  ["2012" , "010ac88c55b1409bb67c9270c8fc18b5_11.geojson"],
  ["2013" , "5fa2e43557f7484d89aac9e1e76158c9_10.geojson"],
  ["2014" , "6eaf3e9713de44d3aa103622d51053b5_9.geojson"],
  ["2015" , "35034fcb3b36499c84c94c069ab1a966_27.geojson"],
  ["2016" , "bda20763840448b58f8383bae800a843_26.geojson"],
  ["2017" , "6af5cb8dc38e4bcbac8168b27ee104aa_38.geojson"],
  ["2018" , "38ba41dd74354563bce28a359b59324e_0.geojson"],
  ["2019" , "f08294e5286141c293e9202fcd3e8b57_1.geojson"],
  ["2020" , "f516e0dd7b614b088ad781b0c4002331_2.geojson"]
]
# We can access the first element of the list with:
crime_data_geojson_list[0]

# To access either the "key" or the "value" simply reference 0 or 1
# 0 = key, 2 = value
crime_data_geojson_list[0][0] # Key
crime_data_geojson_list[0][1] # Value

# Sample Preview of the GeoJSON output. Returned the appropriate amount of 31248 records
tmp_file = crime_data_geojson_list[0][1]



# Method 1
doc = requests.get(base_url + tmp_file)
data = gj.loads(doc.text)  

len(data.features)
data.features[1] # to access the 2nd element in the "features" key structure

# Python has a nice clean function to convert the object to a dataframe, unlike Julia.
crime_table0 = pd.json_normalize(data["features"])


# Method 2: GeoPandas
# I prefer this method and have used it extensively on other projects.
# It converts the GeoJSON document to a DataFrame.
data = gpd.read_file(base_url + tmp_file)


# Remove the data we no longer need.  
# This is valid if you use the GeoJSON method as well.
del(data0, data01, query_end_url, crime_data_json)
data.to_csv(dir_destination +"/" + "CY2009_DC_CRIME_py.csv", index = False)

src_yr = i["year"]
src_url = i["doc"]
data = gpd.read_file(dir_destination + "/" + src_url) # Same Data saved locally                     
print(data.head())
# ****************************************************************

# Now we will get all the data and store in local directory.  
# We could just as easily load directly into a database if it were configured already.
# That will be discussed in a later script.

for i in crime_data_geojson_dict:
  src_yr = i["year"]
  src_url = i["doc"]
  print("Starting " + src_yr )
  print(dir_destination + "/" + src_url)
  # data = gpd.read_file(base_url + "/" + src_url) # Data at the API URL
  data = gpd.read_file(dir_destination + "/" + src_url) # Same Data saved locally
  print(data.head())
  data.to_csv(dir_destination +"/" + "crime_table_CY" + src_yr + "_py.csv", index = False)
  print(src_yr + " completed!")
  
  
print("Processing Complete")
