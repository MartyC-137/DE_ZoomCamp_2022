# docker run command 
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