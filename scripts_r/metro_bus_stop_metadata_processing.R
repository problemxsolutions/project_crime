# System: Linux 5.4.0-40-generic, Ubuntu 20.04
# R: Version 4.0.3 (2020-10-10)
# RStudio: Version 1.3.1093

# Metro Bus Stops
# URL: https://opendata.dc.gov/datasets/metro-bus-stops
# Metadata URL: https://www.arcgis.com/sharing/rest/content/items/e85b5321a5a84ff9af56fd614dab81b3/info/metadata/metadata.xml?format=default&output=html

library(tidyverse)
library(magrittr)
library(xml2)

# As part of the Data Exploration process for the crime data, 
# I needed to review the definitions of each of the columns.

# For this, I went to the metadata page for Metro Bus Stops.
# I'm interested in getting more information and context behind each column.
# You can view the metadata page at the URL below:
# URL: https://www.arcgis.com/sharing/rest/content/items/
# e85b5321a5a84ff9af56fd614dab81b3/info/metadata/metadata.xml?format=default&output=html

# Download the html page
download.file(url = paste0('https://www.arcgis.com/sharing/rest/content/items/',
                           'e85b5321a5a84ff9af56fd614dab81b3/info/',
                           'metadata/metadata.xml?format=default&output=html'),
              destfile = './data/metadata_dc_metro_bus_stops.html')

# Read in the document
metadata_file <- read_html('./data/metadata_dc_crime_2015.html')

# Process the document after inspecting the html and key words that 
# define the columns.
dt_all <- 
  metadata_file %>% 
  xml_find_all("//dt")

# Recorded the text that defines the start of each column and each 
# of the descriptor attributes
field_attr <- c('Attribute:',
                'Attribute Label:', 
                'Attribute Definition:', 
                'Attribute Definition Source:',
                'Attribute Domain Values:',
                'Unrepresentable Domain:')

# Collapse the strings to search them all in the document.
field_attr_paste <- paste(field_attr, collapse = '|')

# filter the document down to only retain the key attribute fields
reduced_dt_all <- 
  dt_all[grepl(x = dt_all, pattern = field_attr_paste)] %>% 
  xml_text(trim = T) %>% 
  str_trim()

# Clean up the field names
metadata_colnames <- 
  field_attr %>% 
  str_replace_all(string = ., pattern = " ", replacement = "_") %>% 
  str_replace_all(string = ., pattern = "(:)|(Attribute_)", replacement = "")

# Define the positions that start/end each field.
num_attr_pos <- reduced_dt_all %>% str_detect(pattern = "Attribute:") %>% which
num_attr_len <- num_attr_pos %>% length()
# Process the document by pulling out the fields and values.
# Return a data_frame of the attribute values.
metadata_list <- 
  lapply(1:(num_attr_len),
         function(i){
           current_attr <- num_attr_pos[i]
           stop_pos <- if_else(i < num_attr_len, 
                               num_attr_pos[min(i+1, num_attr_len)],
                               length(reduced_dt_all))
           attr_vect <- reduced_dt_all[c(current_attr:stop_pos)]
           
           # Create a simple function to get specific field values
           tmp_key_value <- function(num){
             tmp_value <-
               attr_vect[str_detect(string = attr_vect, pattern = field_attr[num])] %>% 
               str_remove(pattern = field_attr[num]) %>%
               str_trim()
             
             if(is_empty(tmp_value))
               tmp_value <- ""
             
             return(tmp_value)
           }
           
           data_frame(
             'Label' = tmp_key_value(2),
             'Definition' = tmp_key_value(3),
             'Definition_Source' = tmp_key_value(4),
             'Domain_Values' = tmp_key_value(5),
             'Unrepresentable_Domain' = tmp_key_value(6))
         })

# Aggregate the results
metadata_df <- metadata_list %>% bind_rows()

# Write out the processed metadata results for easy reference.
write_csv(x = metadata_df, 
          file = "./data//crime_metadata_processed.csv")

# Remove all variables
rm(metadata_colnames, metadata_file, metadata_list, 
   dt_all, field_attr, field_attr_paste, 
   num_attr_len, num_attr_pos, reduced_dt_all)
