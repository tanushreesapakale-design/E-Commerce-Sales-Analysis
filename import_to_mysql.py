import pandas as pd
from sqlalchemy import create_engine, URL, text
from getpass import getpass 

# 1. Read cleaned CSV
csv_path = "cleaned_amazon_sales.csv"
df = pd.read_csv(csv_path)

print("CSV loaded successfully!")
print("Rows:", len(df))
print("Columns:", len(df.columns))

# 2. Convert boolean columns to text
df["B2B"] = df["B2B"].astype(str)
df["Promotion_Used"] = df["Promotion_Used"].astype(str)

# 3. Ask for MySQL password
password = getpass("Enter MySQL tanu09: ")

# 4. Create MySQL connection
url = URL.create(
    "mysql+pymysql",
    username="root",
    password=tanu09,
    host="localhost",
    port=3306,
    database="ecommerce_sales"
)

engine = create_engine(url)

# 5. Clear the partially imported data
with engine.connect() as connection:
    connection.execute(text("TRUNCATE TABLE ecommerce_sales"))
    connection.commit()

print("Old partial data removed.")

# 6. Insert the complete dataset
df.to_sql(
    "ecommerce_sales",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=1000,
    method="multi"
)

print("Data imported successfully!")
print("Total rows imported:", len(df))