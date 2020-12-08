-- System: Linux 5.4.0-40-generic, Ubuntu 20.04
-- PostgreSQL: Version 13.1 (2020-11-12)
-- pgAdmin4: Version 4.28 (2020-11-12)


-- Create table base.
SELECT DISTINCT 
  "WARD" as ward, 
  "PSA" as psa,
  "DISTRICT" as district,
  "ANC" as anc, 
  "VOTING_PRECINCT" as voting_precinct, 
  "NEIGHBORHOOD_CLUSTER" as neighborhood_cluster, 
  "CENSUS_TRACT" as census_tract
INTO TABLE dc_spatial_ref
FROM crime
ORDER BY ward;


--***********************************************************************************************
-- Template for creating lookup tables per column
DROP TABLE IF EXISTS [table_name]_index;

CREATE TABLE [table_name]_index (
  [table_name]_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  [table_name] VARCHAR
);

INSERT INTO [table_name]_index ([table_name])
SELECT DISTINCT "[table_name]" AS [table_name] FROM dc_spatial_ref ORDER BY "[table_name]";

--***********************************************************************************************
--Implement the template over the desired attributes
DROP TABLE IF EXISTS ward_index;
CREATE TABLE ward_index (ward_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, ward DOUBLE );
INSERT INTO ward_index (ward) SELECT DISTINCT ward FROM dc_spatial_ref ORDER BY ward;

DROP TABLE IF EXISTS psa_index;
CREATE TABLE psa_index (psa_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, psa DOUBLE );
INSERT INTO psa_index (psa) SELECT DISTINCT psa FROM dc_spatial_ref ORDER BY psa;

DROP TABLE IF EXISTS district_index;
CREATE TABLE district_index (district_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, district DOUBLE );
INSERT INTO district_index (district) SELECT DISTINCT district FROM dc_spatial_ref ORDER BY district;

DROP TABLE IF EXISTS anc_index;
CREATE TABLE anc_index (anc_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, anc VARCHAR );
INSERT INTO anc_index (anc) SELECT DISTINCT anc FROM dc_spatial_ref ORDER BY anc;

DROP TABLE IF EXISTS voting_precinct_index;
CREATE TABLE voting_precinct_index (voting_precinct_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, voting_precinct VARCHAR );
INSERT INTO voting_precinct_index (voting_precinct) SELECT DISTINCT voting_precinct FROM dc_spatial_ref ORDER BY voting_precinct;

DROP TABLE IF EXISTS neighborhood_cluster_index;
CREATE TABLE neighborhood_cluster_index (neighborhood_cluster_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, neighborhood_cluster VARCHAR );
INSERT INTO neighborhood_cluster_index (neighborhood_cluster) SELECT DISTINCT neighborhood_cluster FROM dc_spatial_ref ORDER BY neighborhood_cluster;

DROP TABLE IF EXISTS census_tract_index;
CREATE TABLE census_tract_index (census_tract_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, census_tract VARCHAR );
INSERT INTO census_tract_index (census_tract) SELECT DISTINCT census_tract FROM dc_spatial_ref ORDER BY census_tract;

--***********************************************************************************************
--Insert  index columns
SELECT 
  dc_spatial_ref.*,
  ward_index.ward_id,
  psa_index.psa_id, 
  district_index.district_id, 
  anc_index.anc_id, 
  voting_precinct_index.voting_precinct_id, 
  neighborhood_cluster_index.neighborhood_cluster_id, 
  census_tract_index.census_tract_id 
FROM dc_spatial_ref
LEFT JOIN ward_index ON dc_spatial_ref.ward = ward_index.ward
LEFT JOIN psa_index ON dc_spatial_ref.psa = psa_index.psa 
LEFT JOIN district_index ON dc_spatial_ref.district = district_index.district 
LEFT JOIN anc_index ON dc_spatial_ref.anc = anc_index.anc 
LEFT JOIN voting_precinct_index ON dc_spatial_ref.voting_precinct = voting_precinct_index.voting_precinct 
LEFT JOIN neighborhood_cluster_index ON dc_spatial_ref.neighborhood_cluster = neighborhood_cluster_index.neighborhood_cluster 
LEFT JOIN census_tract_index ON dc_spatial_ref.census_tract = census_tract_index.ensus_tract;


--***********************************************************************************************
--Alter table to include an id field which will be its primary key
ALTER TABLE dc_spatial_fact_table ADD id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;

--Then alter table to make all the other fields foreign keys, referencing their respective table/column
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (ward_id) REFERENCES ward_index(ward_id);
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (psa_id) REFERENCES psa_index(psa_id);
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (district_id) REFERENCES district_index(district_id);
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (anc_id) REFERENCES anc_index(anc_id);
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (voting_precinct_id) REFERENCES voting_precinct_index(voting_precinct_id);
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (neighborhood_cluster_id) REFERENCES neighborhood_cluster_index(neighborhood_cluster_id);
ALTER TABLE dc_spatial_fact_table ADD FOREIGN KEY (census_tract_id) REFERENCES census_tract_index(census_tract_id);