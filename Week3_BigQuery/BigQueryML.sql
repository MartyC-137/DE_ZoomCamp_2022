-- SQL query for ML table
select 
passenger_count
, trip_distance
, PULocationID
, DOLocationID
, payment_type
, fare_amount
, tolls_amount
, tip_amount 
from `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_partitoned` 
where fare_amount != 0;

-- create ML table 
create or replace table `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_ml` (
`passenger_count` integer,
`trip_distance` float64,
`PULocationID` string,
`DOLocationID` string,
`payment_type` string,
`fare_amount` float64,
`tolls_amount` float64,
`tip_amount` float64
)
as
(
  select 
cast(passenger_count as integer)
, trip_distance
, cast(PULocationID as string)
, cast(DOLocationID as string)
, cast(payment_type as string)
, fare_amount
, tolls_amount
, tip_amount 
from `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_partitoned` 
where fare_amount != 0
);

-- create ML model
create or replace model `data-eng-zoomcamp-353222.trips_data_all.tip_model`
options
(model_type = 'linear_reg',
input_label_cols = ['tip_amount'],
data_split_method = 'auto_split') as
select *
from `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_ml`
where tip_amount is not null;

-- check features
select * from ML.FEATURE_INFO(MODEL `data-eng-zoomcamp-353222.trips_data_all.tip_model`);

-- evaluate the model
select *
from ML.EVALUATE(model `data-eng-zoomcamp-353222.trips_data_all.tip_model`,
(
  select * 
  from `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_ml`
  where tip_amount is not null
));

-- predict and explain
select * 
from ML.EXPLAIN_PREDICT(model `data-eng-zoomcamp-353222.trips_data_all.tip_model`,
(
  select * 
  from `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_ml`
  where tip_amount is not null
), struct(3 as top_k_features));

-- Hyperparameter tuning
create or replace model `data-eng-zoomcamp-353222.trips_data_all.tip_hyperparam_model`
options 
(model_type = 'linear_reg',
input_label_cols = ['tip_amount'],
data_split_method = 'auto_split',
num_trials = 5,
max_parallel_trials = 2,
l1_reg=hparam_range(0, 20),
l2_reg=hparam_candidates([0, 0.1, 1, 10]))
as
select * 
from `data-eng-zoomcamp-353222.trips_data_all.yellow_tripdata_ml`
where tip_amount is not null;