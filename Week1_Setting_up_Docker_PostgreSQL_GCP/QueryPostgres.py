import pandas as pd
import pyarrow.parquet as pq
from sqlalchemy import create_engine

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
engine.connect()

#Run this block to test your PostgreSQL connection
# query = """
# SELECT 1 as number;
# """

# pd.read_sql(query, con=engine)

"""since the above query returned 0 records, 
we need to download the parquet file from the NYC.gov
webpage. 
https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page """


trips = pq.read_table(r'/Users/martinpalkovic/Documents/DE_ZoomCamp/Week1_Setting_up_Docker_PostgreSQL_GCP/yellow_tripdata_2022-01.parquet')
df = trips.to_pandas()
# df = df.sample(n = 1000)

df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

#print SQL DDL for the dataframe
print(pd.io.sql.get_schema(df, 'yellow_taxi_data'))

#bulk insert 
# %time df.to_sql(name='yellow_taxi_data', con=engine, if_exists='replace', chunksize=100000)

#insert w/ time stats per chunk size
while True:
    t_start = time()
    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.to_sql(name = 'yellow_taxi_data', con = engine, if_exists = 'append')
    
    t_end = time()

    print('inserted another chunk, took %.3f seconds' % (t_end - t_start))