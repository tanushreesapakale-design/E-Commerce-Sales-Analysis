from sqlalchemy import create_engine

engine = create_engine(
    "mysql+pymysql://root:tanu09@localhost:3306/ecommerce_sales"
)

with engine.connect() as connection:
    print("MySQL connection successful!") 