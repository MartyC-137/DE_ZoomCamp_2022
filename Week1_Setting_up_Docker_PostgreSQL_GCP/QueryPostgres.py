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

#query the information schema to determine if any tables exist in our database
query = """
SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';
"""
pd.read_sql(query, con=engine)

query = """select count(*) from yellow_taxi_data;"""
pd.read_sql(query, con=engine)

#How many taxi trips were there on January 15, 2022?
query = """select count(*) from yellow_taxi_data
            where tpep_pickup_datetime between '2022-01-01 00:00:00'
            and '2022-01-01 23:59:59' """
pd.read_sql(query, con=engine)

#Find the largest tip each day
query = """select date(tpep_pickup_datetime) as date
            , max(tip_amount) as max_tip
             from yellow_taxi_data
             where tpep_pickup_datetime <= '2022-01-31 23:59:59'
             group by date
             order by max_tip desc"""
pd.read_sql(query, con=engine).head()

#Most popular destinations from Central Park on January 14?
query = """select 
            z."Zone"
            , count(*) as count
            from yellow_taxi_data as ytd
            join zones as z
                on ytd."DOLocationID"= z."LocationID"
            where tpep_pickup_datetime between '2022-01-14 0:00:00'
            and '2022-01-14 23:59:59'
            and ytd."PULocationID" = 43 
            group by z."Zone" 
            order by count desc"""
pd.read_sql(query, con=engine)

#which location pairs have the highest average price?
query = """select 
            concat(coalesce(puzones."Zone", 'Unknown'),'/', coalesce(dozones."Zone", 'Unknown')) as pickup_dropoff
            , avg(total_amount) as avg_price_ride
            from yellow_taxi_data as taxi
            
            left join zones as puzones
                on taxi."PULocationID" = puzones."LocationID"
                
            left join zones as dozones
                on taxi."DOLocationID" = dozones."LocationID" 
                
            group by pickup_dropoff
            order by avg_price_ride desc;"""
pd.read_sql(query, con=engine)