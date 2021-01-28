# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# Julia: Version 1.5.3 (2020-11-09)

# For the full tutorial, please reference URL:
# https://problemxsolutions.com/project/crime/criminal-analysis-planning/

# These are the resources for Washington DC Criminal Data
# URL: https://opendata.dc.gov/search?collection=Dataset&q=Crime

using DataFrames # library(tidyverse)
using HTTP
using JSON # library(jsonlite)
using GeoJSON # library(geojsonR)
import CSVFiles
base_dir = "/home/linux/ProblemXSolutions.com/DataProjects/DC_Crime"
dir_destination = "$base_dir/data/crime"

if(!ispath(dir_destination))
  mkdir(dir_destination)

# Assess the URLs and reduce to unique portions

# ****************************************************************
# JSON file
# ****************************************************************
base_url = "https://maps2.dcgis.dc.gov/dcgis/rest/services/FEEDS/MPD/MapServer"
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


# ****************************************************************
# GeoJSON file
# ****************************************************************
base_url = "https://opendata.arcgis.com/datasets/"

crime_data_geojson = Dict(
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
# We can access the first element with
crime_data_geojson_tup[1]

# To access either the key or the value simply reference 1 or 2
# 1 = key, 2 = value
crime_data_geojson_tup[1][1] # Key
crime_data_geojson_tup[1][2] # Value

# Sample Preview of the GeoJSON output. Returned the appropriate amount of 31248 records
tmp_url = "https://opendata.arcgis.com/datasets/73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson"
# doc = HTTP.get(tmp_url).body |> String
# data = GeoJSON.read(doc)

download(tmp_url, "$dir_destination/temp.geojson")
data = GeoJSON.read(read("$dir_destination/temp.geojson"))
data_dict = geo2dict(data)

println(length(data.features))
# data.features[1]
#  # geometry → GeoInterface.Point
#  # properties → Dict{String, Any}

# # Convert GeoJSON to Dictionary
# # Slow and single processor
# data_dict = geo2dict(data)
# df1 = DataFrame(data_dict["features"][1]["properties"]);
# for i in data_dict["features"]
#   df2 = DataFrame(i["properties"]);
#   df1 = vcat(df1, df2)
# end

# In this next part I'll demonstrate distributing the processing
using Distributed
addprocs(length(Sys.cpu_info()))
# I have 4 processors

@everywhere using DataFrames
function bind_rows_distributed()
    nheads = @distributed (vcat) for i in data_dict["features"]
      df_i = DataFrame(i["properties"]);
    end
end

@time begin
  df_combined = bind_rows_distributed()
end
# julia> 33.885074 seconds (6.69 M allocations: 227.335 MiB, 2.10% gc time)
# julia> 31.356703 seconds (6.50 M allocations: 217.471 MiB, 0.55% gc time)
# Much faster than the original for loop

function bind_rows(df)
    df_v = [DataFrame(i["properties"]) for i in df]
    df_base = df_v[1]
    for i in df_v[2:end]
      allowmissing!(append!(df_base, i, cols=:union))
    end
    df_base
end

@time begin
  df_combined_nodist = bind_rows(data_dict["features"])
end
# julia> 5.648471 seconds (8.50 M allocations: 523.706 MiB, 4.96% gc time)

# this tells us the results where the same
df_combined_nodist == df_combined

# As we can see the the process didnt save time

# Remove the data we no longer need.
# This is valid if you use the GeoJSON method as well.
data0 = nothing
query_end_url = nothing
crime_data_json = nothing
df_combined = nothing
data_dict = nothing
doc = nothing

CSVFiles.save("$dir_destination/CY2009_DC_CRIME_jl.csv", df_combined_nodist)

# NO METHOD TO SAVE GeoJSON file in the package yet.
# GeoJSON.save("$dir_destination/2009_DC_CRIME_jl.geojson", data)


# ****************************************************************
function process_geojson_file(x1, x2, url, dir)
  # println(string("Processing ", x1))
  # Get Data
  cu = string(url, x2);
  doc = HTTP.get(cu).body |> String
  data = GeoJSON.read(doc)
  data_dict = geo2dict(data)

  df = bind_rows(data_dict["features"])
  CSVFiles.save(string("$dir/crime_table_CY", x1,"_jl.csv"), df)
  println(string(x1, " completed!"))
  println("Processing Complete")
end

# This is a single processor.  It took a long time to complete.
# From my observation
for i in crime_data_geojson
  src_yr = i[1]
  src_url = i[2]
  process_geojson_file(
    src_yr,
    src_url,
    base_url,
    dir_destination)
end


# ***** NOT WORKING YET, IN DEVELOPMENT ***** #
"""
# Now we will get all the data and store in local directory.
# We could just as easily load directly into a database if it were configured already.
# That will be discussed in a later script.

@everywhere using CSVFiles, DataFrames, GeoJSON, HTTP
function get_all_geojson_files(x, url, dir)
    nheads = @distributed for i in x
      src_yr = i[1];
      src_url = i[2];
      process_geojson_file(src_yr, src_url, url, dir)

    end
end

@time begin
  get_all_geojson_files(crime_data_geojson, base_url, dir_destination)
end
# julia>
"""
