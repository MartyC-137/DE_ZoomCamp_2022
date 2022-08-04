# Extract a machine learning model from Google Cloud storage, 
# load the data to a docker image and post the results to your
# localhost Tensorflow API
# -------------------------------

# authenticate to your Google Cloud login
gcloud auth login

# check which project you are using 
gcloud config get-value project
gcloud config set project data-eng-zoomcamp-353222

# create a new bucket for the ML model
gsutil mb -p data-eng-zoomcamp-353222 -l northamerica-northeast1 gs://taxi_ml_testing

# Extract model to bucket
bq --project_id data-eng-zoomcamp-353222 extract -m trips_data_all.tip_model gs://taxi_ml_testing/tip_model

# create a temp directory and copy the model into it from the bucket
mkdir /tmp/model
gsutil cp -r gs://taxi_ml_testing/tip_model /tmp/model
mkdir -p serving_dir/tip_model/1

# pull docker Tensorflow image
docker pull emacski/tensorflow-serving:latest 

# this starts the container but doesnt work
docker run -t --rm -p 8500:8500 `
-v `pwd`/serving_dir/tip_model:/models/tip_model `
-e MODEL_NAME=tip_model emacski/tensorflow-serving &

[[ -d `pwd`/serving_dir/tip_model ]] && echo "This directory exists!"


docker run -t --rm -p 8500:8500 -v `
/Users/martinpalkovic/Documents/repos/DE_ZoomCamp/Week3_BigQuery/serving_dir/tip_model,`
-e MODEL_NAME=tip_model emacski/tensorflow-serving &

# From StackOverflow
docker run -p 8500:8500 --mount type=bind,source=`pwd`/serving_dir/tip_model,target=/models/tip_model -e MODEL_NAME=tip_model -t emacski/tensorflow-serving 


# this doesnt work at all
docker run -p 8500:8500 --network="host" --mount type=bind,source=./Week3_BigQuery/serving_dir/tip_model,target=/models/tip_model -e MODEL_NAME=tip_model -t tensorflow/serving &

# pulled from Slack - doesntt work
docker run -p 8501:8501 --mount type=bind,source=pwd/serving_dir/tip_model,target=/models/tip_model -e MODEL_NAME=tip_model --platform linux/amd64 -t emacski/tensorflow-serving &

# check status with a GET request
curl 'http://localhost:8500/v1/models/tip_model'

curl -d '{"instances": [{"passenger_count":1, "trip_distance":12.2, "PULocationID":"193", "DOLocationID":"264", "payment_type":"2","fare_amount":20.4,"tolls_amount":0.0}]}' -X POST http://localhost:8500/v1/models/tip_model:predict