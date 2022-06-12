"""Modified version of the script from the DataClubTalks DE Zoomcamp"""

import os, argparse
import pyarrow.parquet as pq
import pandas as pd
from sqlalchemy import create_engine

def postgres_pipeline(parameters):
    username = parameters.username
    password = parameters.password
    host = parameters.host
    port = parameters.port
    database = parameters.database
    table_name = parameters.table_name
    url = parameters.url
    filename = 'SQL_Ingestion.paraquet'

    #downloads a file from the location we specify
    os.system(f'wget {url} -O {filename}')

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    parquet_table = pq.read_table(filename)
    df = parquet_table.to_pandas()

    df.to_sql(name="yellow_taxi_data", con=engine, if_exists='append', chunksize=100000)

    while True:
        t_start = time()
        df = next(df_iter)

        df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
        df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

        df.to_sql(name = 'yellow_taxi_data', con = engine, if_exists = 'append')
        
        t_end = time()

        print('inserted another chunk, took %.3f seconds' % (t_end - t_start))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest data to Postgres')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the parquet file')

    args = parser.parse_args()

    main(args)