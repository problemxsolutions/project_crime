"""
# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# Julia: Version 1.5.3 (2020-11-09)

# For the full tutorial, please reference URL:
# URL: https://problemxsolutions.com/distributed-computing/distributed-computing-with-julia-by-example/

## Distributed data processing with Julia ##
In this example, I'm going to demonstrate using the base distributed computing package to download GeoJSON files, perform some processing on those files and then write the resultant tables to a CSV file.  The data being used comes from open source criminal activity data provided by Washington DC.  You can view the original post written originally in R here [https://problemxsolutions.com/project/crime/criminal-analysis-data-search-part-0/].

##* Parallel/Distributed Processes ##*
First off, not all tasks are really optimal for parallel or distributed processes.  I think it really depends on the amount of data you are working with and the need to replicate data to each of the processors.  You may find that implementing a distributed workfolow may take longer in comparison to running a task on the current processor.  This is because distributed computing requires starting up and allocating resources as well as replicating the configuration and data needed to complete the task.

In my example, I'm dispatching instructions that are independent operations.  Each processor will fetch the needed data at a unique URL, then process the GeoJSON document and finally writing out the results to a CSV file.  None of this process has dependencies, making it optimal for distributed and parallel processing, assuming you have the resources available on your machine.

## Who is this for? ##
I am working from a personal laptop computer and not operating in the cloud or have access to servers.  This should be a relevant for people interested in learning and applying distributed processing to their local environments.

When you have access to a cloud environment and scalable computing resources, some of the implementation might change but if you design your process to work in both environments (single and multiple processor)


These are the resources for Washington DC Criminal Data (URL: https://opendata.dc.gov/search?collection=Dataset&q=Crime)

## Version and Packages
In this use case, I am using Julia v1.5.3 with the following packages:
"""

using DataFrames # v0.22.4 https://dataframes.juliadata.org/stable/
import HTTP # v0.8.19 https://github.com/JuliaWeb/HTTP.jl
import GeoJSON # v0.5.1 https://github.com/JuliaGeo/GeoJSON.jl
import CSV # v0.8.2 https://github.com/JuliaData/CSV.jl
using Distributed # v1.5.3 https://docs.julialang.org/en/v1/stdlib/Distributed/

"""
## Initial setup

Where are we putting the data?
"""
base_dir = "/home/linux/ProblemXSolutions.com/DataProjects/DC_Crime"
dir_destination = "$base_dir/data/crime"

# ################################################################
# GeoJSON file
# ################################################################
base_url = "https://opendata.arcgis.com/datasets/"

"""
In converting from my R named vector structure, I decided to use the named tuple structure in Julia.  I could have easily used the dictionary structure, but opted for this method instead.  I will also note that I did experiment with both methods.
"""
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


"""
## OPTIONAL STEP
In this section I will get all the data and store the files in a local directory.  During the testing process, this lets me perform lots of experiments without having to do several pulls as I troubleshot the process.  Once the process is refined and workng we can comment this out and switch over to getting the data from the API each time the program is run.

We could just as easily load directly into a database if it were configured already.
"""
for i in crime_data_geojson_tup
  src_yr = i[1]
  src_url = i[2]
  tmp_url = string(base_url, src_url);
  tmp_dest = string("$dir_destination/$src_url")
  download(tmp_url, tmp_dest)
end

"""
## Single instance example
In this example I just demonstrate the structure of the process before applying it in parallel.  You can also see using the API direct method and saving the file locally method.  We process the data the same but one method doesn't require using the `HTTP` package.  To me this is relatively trivial because you still have to get the file either way.  Whether you read it directly into Julia each run or download and read it in the results are the same.
"""
# Sample Preview of the GeoJSON output. Returned the appropriate amount of 31248 records

### API Method
tmp_url = "https://opendata.arcgis.com/datasets/73cd2f2858714cd1a7e2859f8e6e4de4_33.geojson"
doc = HTTP.get(tmp_url).body |> String
data = GeoJSON.read(doc)

# Local File Method
tmp_file = crime_data_geojson_tup[1][2]
download(tmp_url, "$dir_destination/$tmp_file")
data = GeoJSON.read(read("$dir_destination/$tmp_file"))

# Convert into a Dictionary structure
data_dict = geo2dict(data)

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

data = bind_rows(data_dict["features"])

CSV.write("$dir_destination/CY2009_DC_CRIME_jl_test.csv", data)

# ################################################################
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

# This is a single processor.  It took a long time to complete.
# From my observation
# tmp_tup = crime_data_geojson_tup[1:4]
i = crime_data_geojson_tup[2]
src_yr = i[1]
src_url = i[2]

@time process_geojson_file(
  src_yr = src_yr,
  src_url = src_url,
  url = dir_destination,
  dir = dir_destination,
  local_files = true)

# 448.422140 seconds (41.91 M allocations: 2.322 GiB, 0.91% gc time)
# 598.114513 seconds (18.26 M allocations: 1.218 GiB, 0.72% gc time)
# 7-10 minutes


# 751.165167 seconds (250.78 k allocations: 14.106 MiB, 0.03% gc time)
"""
After timing the process, I can estimate that the total time to accomplish the task over my entire range of data would take quite a while.

When running the example process over all the elements in the tuple it took a long time my first time trying to see how it would perform.  I forgot to time it but it was long enough that I didnt re-run it. It likely took about 2+hrs though.  Based on the rough numbers produced above it would take roughly 120 minutes (12 tasks at ~10 minutes/task) to process all the data in my tuple.
"""



"""
## Distribution Time
Now I am ready to allocate processing resources and process the data tied to each tuple element.

First I'm allocating processors based on what is available on my current machine.  `Sys.cpu_info()` returns information about your CPU in a vector.  For each element you can look at the individual resources if you wish.  I'm concerned with the number of processors which I get by taking the length.  From there I can add feed that number into how many processors I should add, `addprocs()`[https://docs.julialang.org/en/v1/stdlib/Distributed/#Distributed.addprocs].  Please refer to the documentation on function specifics.
"""
addprocs(length(Sys.cpu_info()))

"""
Next, I call the `@everywhere`[https://docs.julialang.org/en/v1/stdlib/Distributed/#Distributed.@everywhere] macro to call the expressions following to be called on the allocated resources.  I need to make sure that the packages needed to execute my process are used or imported into each of the processors.

Then, I distribute my functions.  In practical application, I might put these functions into a module so can call them like the other packages.  But here you can see both methods used to execute the current example.

"""
@everywhere using  DataFrames
@everywhere import CSV, GeoJSON, HTTP

@everywhere function bind_rows(df)
    df_v = [DataFrame(i["properties"]) for i in df]
    df_base = df_v[1]
    for i in df_v[2:end]
      allowmissing!(append!(df_base, i, cols=:union))
    end
    df_base = something.(df_base, "")
    return df_base
end

@everywhere function process_geojson_file(;src_yr, src_url, url, dir, local_files=false)
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
In this function, notice that I call the `@distributed`[https://docs.julialang.org/en/v1/stdlib/Distributed/#Distributed.@distributed] macro before my for loop statement.  This instructs the processors to partition the specified range and execute all all the processors (workers).  I need to also assign this to a variable due to my current structure.  The current form is also structured for asynchronous processing due to my task independence.  If you were going to perform a task in sync, you would precede the `@distributed` with `@sync` (example: `@sync @distributed`).

Below the for-loop you will see that I have a print statement followed by the `wait()` function, followed by another print line.  What this does is tells the system to wait on the task before invoking any other parallel calls.  The print lines give me some feedback in REPL to let me know what is going on (ie the process has started or the process has completed in my implementation).
"""
@everywhere function get_all_geojson_files(;x, url, dir, local_d=false)
    master_task = @distributed for i in x
      src_yr = i[1]
      src_url = i[2]
      process_geojson_file(
        src_yr = src_yr,
        src_url = src_url,
        url = url,
        dir = dir,
        local_files = local_d)
    end

    println("Beginning the process...")
    wait(master_task)
    println("All workers done!")
end

"""
Now that everything has been distributed to the allocated resources, I can execute the distributed process process.  I will also time the process.
"""
@time begin
  get_all_geojson_files(
                        x = crime_data_geojson_tup,
                        url = dir_destination,
                        dir = dir_destination,
                        local_d = true
                        )
end
# julia>
# To release the workers I run the following to remove the processors.  After this you should notice your computer will go back to normal (running speed, fan speed)
rmprocs()

"""
When I did a test run on 4 elements, it completed the task in ~12.5 minutes.  Since I have four processors and 12 tasks, I could estimate that it would take three times that, so roughly 37.5 minutes.
"""
# tmp_tup = crime_data_geojson_tup[1:4]
# # 751.165167 seconds (250.78 k allocations: 14.106 MiB, 0.03% gc time)
# All workers done!

"""
When I ran the full tuple object, it completed the task in 37.467 minutes.  Pretty close estimate.  When assessing it from the estimated time it would take in a non-distributed manner it saves about 75% of the time.
"""

# 2247.996934 seconds (169.29 k allocations: 8.618 MiB)

# julia> 2248/60
# 37.46666666666667
#
# julia> 12.52*12
# 150.24
#
# julia> 37.47/3
# 12.49
#
# julia> 37.47/150.24
# 0.24940095846645366
#
# julia> 1-(37.47 / 150.24)
# 0.7505990415335464
