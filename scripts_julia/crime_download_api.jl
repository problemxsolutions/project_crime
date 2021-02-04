# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# Julia: Version 1.5.3 (2020-11-09)

# For the full tutorial writen for R, please reference URL:
# https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-0/

# These are the resources for Washington DC Criminal Data
# URL: https://opendata.dc.gov/search?collection=Dataset&q=Crime

using DataFrames # library(tidyverse)
using HTTP
using JSON # library(jsonlite)
using GeoJSON # library(geojsonR)
import CSV

base_dir = "/home/linux/ProblemXSolutions.com/DataProjects/DC_Crime"
dir_destination = "$base_dir/data/crime"

if(!ispath(dir_destination))
  mkdir(dir_destination)

# Assess the URLs and reduce to unique portions

"""
# ****************************************************************
#                           JSON file
# ****************************************************************
"""base_url = "https://maps2.dcgis.dc.gov/dcgis/rest/services/FEEDS/MPD/MapServer"
query_end_url = "query?where=1%3D1&outFields=*&outSR=4326&f=json"

crime_data_json = Dict(
  "2009" => "33",
  "2010" => "34",
  "2011" => "35",
  "2012" => "11",
  "2013" => "10",
  "2014" => "9",
  "2015" => "27",
  "2016" => "26",
  "2017" => "38",
  "2018" => "0",
  "2019" => "1",
  "2020" => "2"
)

# API URL to the last 30 days of criminal activity
# crime_data_last30days = "/8"

# Sample Preview of the JSON output.  Returned only 1000 Results
i = crime_data_json["2014"]
doc = HTTP.get(string(base_url,"/", i,"/", query_end_url))
doc = String(doc.body)
data0 = JSON.Parser.parse(String(doc))
# data0["fields"]


"""
# ****************************************************************
#                       GeoJSON file
# ****************************************************************
"""
base_url = "https://opendata.arcgis.com/datasets/"

crime_data_geojson_dict = Dict(
  "2009" => "73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson",
  "2010" => "fdacfbdda7654e06a161352247d3a2f0_34.geojson",
  "2011" => "9d5485ffae914c5f97047a7dd86e115b_35.geojson",
  "2012" => "010ac88c55b1409bb67c9270c8fc18b5_11.geojson",
  "2013" => "5fa2e43557f7484d89aac9e1e76158c9_10.geojson",
  "2014" => "6eaf3e9713de44d3aa103622d51053b5_9.geojson",
  "2015" => "35034fcb3b36499c84c94c069ab1a966_27.geojson",
  "2016" => "bda20763840448b58f8383bae800a843_26.geojson",
  "2017" => "6af5cb8dc38e4bcbac8168b27ee104aa_38.geojson",
  "2018" => "38ba41dd74354563bce28a359b59324e_0.geojson",
  "2019" => "f08294e5286141c293e9202fcd3e8b57_1.geojson",
  "2020" => "f516e0dd7b614b088ad781b0c4002331_2.geojson"
)

# We can access the values using the key
crime_data_geojson_dict["2014"]

# To access either the key or the value simply reference either then the index number for the element.
crime_data_geojson_dict.keys[1] # Key
crime_data_geojson_dict.vals[1] # Value


# Alternatively using a named tuple structure
crime_data_geojson_tup = (
  "2009" => "73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson",
  "2010" => "fdacfbdda7654e06a161352247d3a2f0_34.geojson",
  "2011" => "9d5485ffae914c5f97047a7dd86e115b_35.geojson",
  "2012" => "010ac88c55b1409bb67c9270c8fc18b5_11.geojson",
  "2013" => "5fa2e43557f7484d89aac9e1e76158c9_10.geojson",
  "2014" => "6eaf3e9713de44d3aa103622d51053b5_9.geojson",
  "2015" => "35034fcb3b36499c84c94c069ab1a966_27.geojson",
  "2016" => "bda20763840448b58f8383bae800a843_26.geojson",
  "2017" => "6af5cb8dc38e4bcbac8168b27ee104aa_38.geojson",
  "2018" => "38ba41dd74354563bce28a359b59324e_0.geojson",
  "2019" => "f08294e5286141c293e9202fcd3e8b57_1.geojson",
  "2020" => "f516e0dd7b614b088ad781b0c4002331_2.geojson"
)
# We can access the first element of the tuple with:
crime_data_geojson_tup[1]

# To access either the key or the value simply reference 1 or 2
# 1 = key, 2 = value
crime_data_geojson_tup[1][1] # Key
crime_data_geojson_tup[1][2] # Value

# Sample Preview of the GeoJSON output. Returned the appropriate amount of 31248 records
tmp_url = "https://opendata.arcgis.com/datasets/73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson"
# doc = HTTP.get(tmp_url).body |> String
# data = GeoJSON.read(doc)

tmp_file = crime_data_geojson_tup[1][2]
download(tmp_url, "$dir_destination/$tmp_file")
data = GeoJSON.read(read("$dir_destination/$tmp_file"))
data_dict = geo2dict(data)

println(length(data.features))
# data.features[1]
#  # geometry → GeoInterface.Point
#  # properties → Dict{String, Any}

"""
Since I want to convert the GeoJSON structure into a DataFrame (tabular structure), I created a function to handle the processes.  This allows me functionalize the process.

In the function I take the GeoJSON data, convert each of the elements in the document to a DataFrame object.  Then bind all the DataFrames into one DataFrame.  The final [`something.(data, "")`]https://docs.julialang.org/en/v1/base/base/#Base.something) broadcasted function takes the data and changes `nothing` values into the second argument value.  In my case, I used the `""` to make it a blank value.
"""
function bind_rows(df)
    df_v = [DataFrame(i["properties"]) for i in df]
    df_base = df_v[1]
    for i in df_v[2:end]
      allowmissing!(append!(df_base, i, cols=:union))
    end
    df_base = something.(df_base, "")
    return df_base
end

"""
## Functionalize the Process
Here, we combine processes described above into a function.  To add flexibility I have included an argument to allow the processing of local files over getting the data directly from the API each time.

You can see the structure is independent and can be distributed.  There is no need for MapReduce.  Nothing to collect.  Just perform a task.

"""
function process_geojson_file(;src_yr, src_url, url, dir, local_files=false)
  println("Starting $src_yr")
  # Get Data
  if !local_files
    cu = string(url, src_url);
    doc = HTTP.get(cu).body |> String
  else
    doc = string("$dir/$src_url")|> read |> String
  end

  data = GeoJSON.read(doc)
  data_dict = GeoJSON.geo2dict(data)

  df = bind_rows(data_dict["features"])
  df = something.(df, "")
  # CSVFiles.save(string("$dir/crime_table_CY", x1,"_jl.csv"), df)
  CSV.write(
    string("$dir/crime_table_CY", src_yr,"_jl.csv"),
    df,
    missingstring = ""
  )
  println("$src_yr completed!")
end

"""
# Execute the process.
# For information on the distributed version of the process check out the distributed_etl_crime.jl script.

# For the full tutorial, please reference URL:
# URL: https://problemxsolutions.com/distributed-computing/distributed-computing-with-julia-by-example/
"""
for i in crime_data_geojson_tup
  src_yr = i[1]
  src_url = i[2]
  process_geojson_file(
    src_yr = src_yr,
    src_url = src_url,
    url = url,
    dir = dir,
    local_files = local_d)
end
