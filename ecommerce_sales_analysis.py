# %%
import pandas as pd 

# %%
df = pd.read_csv("Amazon Sale Report.csv")
df.head()

# %%
df.isnull().sum()

import pandas as pd

#Load and inspect data

df = pd.read_csv("Amazon Sale Report.csv")   #load dataset

print(df.head())   #display first 5 rows

print("Shape: ", df.shape)   #no.of rows and columns

print("\nColumns:")   #column names
print(df.columns)

print("\nData Types:")   #data types
print(df.dtypes)

print("\nData Information:")   #Basic information
df.info()

#Checking missing values

missing_percentage = (df.isnull().sum() / len(df)) * 100

missing_data = pd.DataFrame({"Missing Values": df.isnull().sum(),"Percentage": missing_percentage})
print(missing_data)

#Check duplicates

print("Duplicate rows:", df.duplicated().sum())   #count duplicate rows
print(df[df.duplicated()])   #display duplicate rows

#Check unique values

print("Order Status:")
print(df["Status"].value_counts())

print("\nCategories:")
print(df["Category"].value_counts())

print("\nFulfilment:")
print(df["Fulfilment"].value_counts())

print("\nSales Channel:")
print(df["Sales Channel "].value_counts())

print("\nSize:")
print(df["Size"].value_counts())

#Check numerical columns

print(df[["Qty", "Amount"]].describe())

#Check the date column

print(df["Date"].head())
print(df["Date"].dtype)

#Data cleaning

df.drop(columns=["index", "Unnamed: 22"], inplace=True)   #remove unnecessary columns
print(df.shape)

df.columns = df.columns.str.strip()   #Remove leading/trailing spaces from column names
print(df.columns)

df["Date"] = pd.to_datetime(df["Date"], format="%m-%d-%y")   #Convert Date to datetime
print(df["Date"].dtype)

print(df["Date"].min())
print(df["Date"].max())

print(df[df["Amount"].isnull()]["Status"].value_counts())   #Investigate Amount missing values

print(df.groupby("Status")["Amount"].apply(lambda x: x.isnull().sum()))

print(df["currency"].value_counts(dropna=False))   #Investigate Currency

print(df[df["ship-city"].isnull()])   #Investigate shipping information

print(pd.crosstab(df["Fulfilment"],df["fulfilled-by"],dropna=False))

print(pd.crosstab(df["Status"],df["Courier Status"],dropna=False))

#Check suspicious values

print("Orders with Qty = 0:")
print((df["Qty"] == 0).sum())

print(df[df["Qty"] == 0]["Status"].value_counts())

print("Rows with Amount = 0:")
print((df["Amount"] == 0).sum())

print(df[df["Amount"] == 0]["Status"].value_counts())

#Check categorical inconsistencies

print("Fulfilment:")
print(df["Fulfilment"].unique())

print("\nCategory:")
print(df["Category"].unique())

print("\nB2B:")
print(df["B2B"].value_counts())

print("\nCourier Status:")
print(df["Courier Status"].value_counts(dropna=False))

#Cleaned Dataset

import pandas as pd

df = pd.read_csv("Amazon Sale Report.csv")   #load raw dataset

df.drop(columns=["index","Unnamed: 22"],inplace=True)  #remove unnecessary

df.columns = df.columns.str.strip()   #Clean Date to datetime

df["Date"] = pd.to_datetime(df["Date"], format="%m-%d-%y")   #Convert Date to datetime

df.dropna(subset=["ship-city","ship-state","ship-postal-code","ship-country"],inplace=True)   #Remove rows with missing shipping location

#check final dataset

print("Final Shape:", df.shape)

print("\nMissing values:")
print(df.isnull().sum())

print("\nData types:")
print(df.dtypes)

df["Month"] = df["Date"].dt.month   #month
df["Month_Name"] = df["Date"].dt.month_name()   #month name
df["Year"] = df["Date"].dt.year
df["Day"] = df["Date"].dt.day_name()

df["Promotion_Used"] = df["promotion-ids"].notna()   #promotion used

df.to_csv("cleaned_amazon_sales.csv", index=False)
print("Cleaned Dataset saved successfully!")