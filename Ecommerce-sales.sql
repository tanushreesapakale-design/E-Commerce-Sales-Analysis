CREATE DATABASE ecommerce_sales;
USE ecommerce_sales;

SHOW WARNINGS LIMIT 10;

CREATE TABLE ecommerce_sales (
    `Order ID` VARCHAR(50),
    `Date` DATE,
    `Status` VARCHAR(100),
    `Fulfilment` VARCHAR(50),
    `Sales Channel` VARCHAR(50),
    `ship-service-level` VARCHAR(50),
    `Style` VARCHAR(50),
    `SKU` VARCHAR(100),
    `Category` VARCHAR(50),
    `Size` VARCHAR(20),
    `ASIN` VARCHAR(50),
    `Courier Status` VARCHAR(50),
    `Qty` INT,
    `currency` VARCHAR(10),
    `Amount` DECIMAL(10,2),
    `ship-city` VARCHAR(100),
    `ship-state` VARCHAR(100),
    `ship-postal-code` VARCHAR(20),
    `ship-country` VARCHAR(50),
    `promotion-ids` TEXT,
    `B2B` BOOLEAN,
    `fulfilled-by` VARCHAR(50),
    `Month` INT,
    `Month_Name` VARCHAR(20),
    `Year` INT,
    `Day` VARCHAR(20),
    `Promotion_Used` BOOLEAN,
    `Status_Group` VARCHAR(30)
);

SHOW TABLES;

ALTER TABLE ecommerce_sales
MODIFY COLUMN `Amount` DECIMAL(10,2) NULL;

SELECT COUNT(*) AS total_records
FROM ecommerce_sales;

DESCRIBE ecommerce_sales;

SELECT 
    SUM(`Amount`) AS total_recorded_sales,
    AVG(`Amount`) AS average_amount
FROM ecommerce_sales;

#overall business summary
SELECT
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(`Amount`) AS total_recorded_sales,
    AVG(`Amount`) AS average_record_amount,
    SUM(`Qty`) AS total_quantity
FROM ecommerce_sales;

#sales by category
SELECT
    `Category`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales,
    AVG(`Amount`) AS average_amount
FROM ecommerce_sales
GROUP BY `Category`
ORDER BY total_sales DESC;

#monthly sales
SELECT
    `Year`,
    `Month`,
    `Month_Name`,
    SUM(`Amount`) AS total_sales,
    SUM(`Qty`) AS total_quantity
FROM ecommerce_sales
GROUP BY `Year`, `Month`, `Month_Name`
ORDER BY `Year`, `Month`;

#top 10 states by recorded sales
SELECT
    `ship-state`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales
FROM ecommerce_sales
GROUP BY `ship-state`
ORDER BY total_sales DESC
LIMIT 10;

#fulfilment analysis
SELECT
    `Fulfilment`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales,
    AVG(`Amount`) AS average_amount
FROM ecommerce_sales
GROUP BY `Fulfilment`
ORDER BY total_sales DESC;

#order status analysis
SELECT
    `Status_Group`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales
FROM ecommerce_sales
GROUP BY `Status_Group`
ORDER BY total_records DESC;

#cancellation rate at order level
SELECT
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN `Status_Group` = 'Cancelled'
        THEN `Order ID`
    END) AS cancelled_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN `Status_Group` = 'Cancelled'
            THEN `Order ID`
        END) * 100.0
        / COUNT(DISTINCT `Order ID`),
        2
    ) AS cancellation_rate_percent
FROM ecommerce_sales;

#promotion analysis
SELECT
    `Promotion_Used`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales,
    AVG(`Amount`) AS average_amount
FROM ecommerce_sales
GROUP BY `Promotion_Used`
ORDER BY total_sales DESC;

#b2b vs non-b2b
SELECT
    `B2B`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales,
    AVG(`Amount`) AS average_amount
FROM ecommerce_sales
GROUP BY `B2B`
ORDER BY total_sales DESC;

#top 10 products/SKUs
SELECT
    `SKU`,
    `Category`,
    COUNT(*) AS total_records,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales
FROM ecommerce_sales
GROUP BY `SKU`, `Category`
ORDER BY total_sales DESC
LIMIT 10;

#monthly sales ranking
SELECT
    `Year`,
    `Month`,
    `Month_Name`,
    SUM(`Amount`) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(`Amount`) DESC
    ) AS sales_rank
FROM ecommerce_sales
GROUP BY `Year`, `Month`, `Month_Name`
ORDER BY sales_rank;

#top 10 states by quantity
SELECT
    `ship-state`,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales
FROM ecommerce_sales
GROUP BY `ship-state`
ORDER BY total_quantity DESC
LIMIT 10;

#top 10 sales dates
SELECT
    `Date`,
    SUM(`Qty`) AS total_quantity,
    SUM(`Amount`) AS total_sales
FROM ecommerce_sales
GROUP BY `Date`
ORDER BY total_sales DESC
LIMIT 10;

#Monthly Running Total
SELECT
    `Year`,
    `Month`,
    `Month_Name`,
    SUM(`Amount`) AS monthly_sales,
    SUM(SUM(`Amount`)) OVER (
        ORDER BY `Year`, `Month`
    ) AS running_total_sales
FROM ecommerce_sales
GROUP BY `Year`, `Month`, `Month_Name`
ORDER BY `Year`, `Month`;

#monthly sales growth %
WITH monthly_sales AS (
    SELECT
        `Year`,
        `Month`,
        `Month_Name`,
        SUM(`Amount`) AS monthly_sales
    FROM ecommerce_sales
    GROUP BY `Year`, `Month`, `Month_Name`
)

SELECT
    `Year`,
    `Month`,
    `Month_Name`,
    monthly_sales,
    LAG(monthly_sales) OVER (
        ORDER BY `Year`, `Month`
    ) AS previous_month_sales,
    ROUND(
        (monthly_sales - LAG(monthly_sales) OVER (
            ORDER BY `Year`, `Month`
        )) * 100.0
        / LAG(monthly_sales) OVER (
            ORDER BY `Year`, `Month`
        ),
        2
    ) AS growth_percent
FROM monthly_sales
ORDER BY `Year`, `Month`;

#Rank SKUs Within Each Category
WITH sku_sales AS (
    SELECT
        `Category`,
        `SKU`,
        SUM(`Qty`) AS total_quantity,
        SUM(`Amount`) AS total_sales
    FROM ecommerce_sales
    GROUP BY `Category`, `SKU`
),

ranked_skus AS (
    SELECT
        `Category`,
        `SKU`,
        total_quantity,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY `Category`
            ORDER BY total_sales DESC
        ) AS category_rank
    FROM sku_sales
)

SELECT
    `Category`,
    `SKU`,
    total_quantity,
    total_sales,
    category_rank
FROM ranked_skus
WHERE category_rank <= 3
ORDER BY `Category`, category_rank;

#State Contribution to Total Sales
WITH state_sales AS (
    SELECT
        `ship-state`,
        SUM(`Amount`) AS total_sales
    FROM ecommerce_sales
    GROUP BY `ship-state`
)

SELECT
    `ship-state`,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS sales_contribution_percent
FROM state_sales
ORDER BY total_sales DESC
LIMIT 10;

#final business analysis query
WITH fulfilment_sales AS (
    SELECT
        `Fulfilment`,
        COUNT(*) AS total_records,
        SUM(`Qty`) AS total_quantity,
        SUM(`Amount`) AS total_sales
    FROM ecommerce_sales
    GROUP BY `Fulfilment`
)

SELECT
    `Fulfilment`,
    total_records,
    total_quantity,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS sales_contribution_percent
FROM fulfilment_sales
ORDER BY total_sales DESC;