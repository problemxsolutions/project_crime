# project_crime
Project focused on the workflow to analyze criminal activity data.

This is a tri-lingual project, meaning I will be demonstrating and posting scripts for R, Julia and Python.  In initial published posts have been written for R but as I translate and create the reciprocal scripts in Julia and Python, I will be posting those scripts to this repo and updating each of the published posts to reflect.  Next to each section title, I will denote ` (R, Julia, Python, etc)` to indicate what is currently available.

For the associated posts providing context and details for the scripts in this project, please refer to these:

## Project Planning
This post describes the project and lays out an initial project plan to help structure my tasks, ideas and references.  This post also leads into collecting the  primary crime data used for the entire project.
* https://problemxsolutions.com/data-project/crime/criminal-analysis-planning/

## Data Search
The next posts detailing "Data Search" describe each of the parts of the project that I would like to gather supplemental data to mix in and analyze with my primary source of criminal activity data.  

### Part 0 (R, Julia, Python)
Focuses on Criminal Activity Data.  This is the cornerstone of the project, meaning there is no project without criminal activity data per the project plan.
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-search-part-0/

### Part 1 (R)
Focuses on Map Data.  This provides spatial polygons to structure the analysis and provide visual context.  The spatial regions referenced in the criminal activity data as well so matching up the data sources should not require much transformation.
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-search-part-1/

### Part 2 (R)
Focuses on weather and solar/lunar activity.
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-search-part-2/

### Part 3 (R)
Focuses on employment/unemployment data and labor statistics.  There is also a blurb on real estate data and additional map data.
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-search-part-3/

### Part 4 (R)
Focuses on real estate, permit (building and construction) and economic data.
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-search-part-4/

## Data Storage (R)
The first two post describe creating a PostgreSQL/PostGIS database to store all the data for this project.  The third post details transitioning the data in PostgresSQL database to Elasticsearch.

### PostgreSQL (R)
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-storage/

### PostGIS (R)
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-storage-part-2/

### Elastic Stack (R)
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-storage-part-3/

## Data Exploration
This portion of the project will look at each dataset loaded into the database and explore what is provided and identify any transformations.

### Introduction and Plan for Exploratory Data Analysis 
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration/

### Part 1: Criminal Data  (R)
* https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-1/

### Part 2: Map Data (R)
* Polygon Datasets: https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-2a/
* Point Datasets: https://problemxsolutions.com/data-project/crime/criminal-analysis-data-exploration-part-2b/

### Part 3: Weather, Solar, Lunar Data
* Coming Soon

### Part 4: Economics Data
* Coming Soon

