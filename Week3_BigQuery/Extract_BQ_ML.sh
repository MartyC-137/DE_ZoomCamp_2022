# steps
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
docker pull emacski/tensorflow-serving
docker run -p 8501:8501 --mount type=bind,source=pwd/serving_dir/tip_model,target= /models/tip_model -e MODEL_NAME=tip_model -t emacski/tensorflow-serving &
curl -d '{"instances": [{"passenger_count":1, "trip_distance":12.2, "PULocationID":"193", "DOLocationID":"264", "payment_type":"2","fare_amount":20.4,"tolls_amount":0.0}]}' -X POST http://localhost:8501/v1/models/tip_model:predict