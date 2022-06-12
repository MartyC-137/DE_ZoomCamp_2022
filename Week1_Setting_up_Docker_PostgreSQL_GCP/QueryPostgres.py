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

%time df.to_sql(name='yellow_taxi_data', con=engine, if_exists='replace', chunksize=100000)