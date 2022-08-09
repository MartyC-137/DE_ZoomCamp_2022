/* My answers to the homework problems for week 3 */

-- Question 1 
SELECT COUNT(*) 
    FROM `data-eng-zoomcamp-353222.trips_data_all.fhv_tripdata_partitoned` 
    WHERE EXTRACT(YEAR from pickup_datetime) = 2019;

-- Question 2 
SELECT COUNT(DISTINCT dispatching_base_num)
    FROM `data-eng-zoomcamp-353222.trips_data_all.fhv_tripdata_partitoned`
    WHERE EXTRACT(YEAR from pickup_datetime) = 2019;

-- Question 3 
CREATE OR REPLACE TABLE data-eng-zoomcamp-353222.trips_data_all.fhv_tripdata_partitoned_clustered
    PARTITION BY DATE(pickup_datetime)
    CLUSTER BY dispatching_base_num
    AS
    SELECT * EXCEPT (PULocationID, DOLocationID) 
        FROM data-eng-zoomcamp-353222.trips_data_all.external_fhv_tripdata;

-- Question 4 
SELECT COUNT(*) FROM data-eng-zoomcamp-353222.trips_data_all.fhv_tripdata_partitoned_clustered;