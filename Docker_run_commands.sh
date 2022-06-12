# create docker network 
docker network create pg-network

# run postgresql container 
docker run -it `
  -e POSTGRES_USER="root" `
  -e POSTGRES_PASSWORD="root" `
  -e POSTGRES_DB="ny_taxi" `
  -v ${pwd}/ny_taxi_postgres_data:/var/lib/postgresql/data `
  -p 5432:5432 `
  --network=pg-network `
  --name pg-database `
  postgres:13

# run pgadmin docker container 
docker run -it `
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" `
  -e PGADMIN_DEFAULT_PASSWORD="root" `
  -p 8080:80 `
  --network=pg-network `
  --name pgadmin-2 `
  dpage/pgadmin4

#build image for dataset
docker build -t taxi_load:v001

URL="https://nyc-tlc.s3.amazonaws.com/trip+data/yellow_tripdata_2022-01.parquet"

#run the pipeline in a Docker container
docker run -it `
  --network=pg-network `
  taxi_load:v001 `
    --username=root `
    --password=root `
    --host=pg-database `
    --port=5432 `
    --database=ny_taxi `
    --table_name=yellow_taxi_trips `
    --url=https://nyc-tlc.s3.amazonaws.com/trip+data/yellow_tripdata_2022-01.parquet