-- Inspecting Data
SELECT* FROM sales_data_sample;

-- changing ORDERDATE column into datetime type
UPDATE sales_data_sample SET ORDERDATE = STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i');



-- Checking Unique Values
SELECT DISTINCT STATUS FROM sales_data_sample; -- 6 status. Can be plotted
SELECT DISTINCT YEAR_ID FROM sales_data_sample; -- 2003, 2004, 2005
SELECT DISTINCT PRODUCTLINE FROM sales_data_sample; -- Can be plotted
SELECT DISTINCT COUNTRY FROM sales_data_sample; -- Can be plotted
SELECT DISTINCT TERRITORY FROM sales_data_sample; -- 4 territories. can be plotted
SELECT DISTINCT DEALSIZE FROM sales_data_sample; -- 3 sizes. can be plotted

-- Analysis
-- Grouping sales by product
SELECT PRODUCTLINE, SUM(SALES) AS REVENUE
FROM sales_data_sample  GROUP BY PRODUCTLINE
ORDER BY SUM(SALES) DESC;

-- Grouping sales by year
SELECT YEAR_ID, SUM(SALES) AS REVENUE
FROM sales_data_sample  GROUP BY YEAR_ID
ORDER BY SUM(SALES) DESC;
-- 2005 has the lowest sales. Checking the reason
SELECT DISTINCT MONTH_ID FROM sales_data_sample WHERE YEAR_ID = 2005; 

-- Grouping sales by dealsize
SELECT DEALSIZE, SUM(SALES) AS REVENUE
FROM sales_data_sample  GROUP BY DEALSIZE
ORDER BY SUM(SALES) DESC;

-- Best month for sales in a specific year and earning at that month
SELECT MONTH_ID, SUM(SALES) AS REVENUE, COUNT(ORDERNUMBER)
FROM sales_data_sample WHERE YEAR_ID = 2004 -- Change year to see other years
GROUP BY MONTH_ID ORDER BY SUM(SALES) DESC;
-- Data of 2005 is not complete. No need to check as it can give wrong reflection

-- November is the best month. Let's look more closely
SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) AS REVENUE, COUNT(ORDERNUMBER)
FROM sales_data_sample WHERE YEAR_ID = 2003 AND MONTH_ID = 11 -- Change year to see other years
GROUP BY  PRODUCTLINE  ORDER BY SUM(SALES) DESC;

-- RFM analysis to find the best customer

-- Creating a derived table with CTE query
CREATE TABLE temp_rfm AS (
  WITH rfm AS (
    SELECT  
      CUSTOMERNAME,
      SUM(SALES) AS Monetry_Value,
      AVG(SALES) AS Avg_Monetry_Value,
      COUNT(ORDERNUMBER) AS Frequency,
      MAX(ORDERDATE) AS Last_Order_Date,
      (SELECT MAX(ORDERDATE) FROM sales_data_sample) AS Max_order_date,
      DATEDIFF((SELECT MAX(ORDERDATE) FROM sales_data_sample), MAX(ORDERDATE)) AS Recency
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
  ),
  rfm_calc AS (
    SELECT 
      r.*,
      NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_Recency,
      NTILE(4) OVER (ORDER BY Frequency) AS rfm_Frequency,
      NTILE(4) OVER (ORDER BY Monetry_Value) AS rfm_Monetry_Value
    FROM rfm r
  )
  SELECT 
    c.*, 
    rfm_Recency + rfm_Frequency + rfm_Monetry_Value AS rfm_value,
    CONCAT(CAST(rfm_Recency AS CHAR), CAST(rfm_Frequency AS CHAR), CAST(rfm_Monetry_Value AS CHAR)) AS rfm_string
  FROM rfm_calc c
);
SELECT CUSTOMERNAME, rfm_Recency, rfm_Frequency, rfm_Monetry_Value, rfm_string,
CASE
	    WHEN rfm_string IN (444, 443, 434, 344) THEN 'Loyal Customers'
        WHEN rfm_string IN (433, 423, 332) THEN 'Engaged Customers'
        WHEN rfm_string IN (322,312,221) THEN 'Moderate Customers'
        WHEN rfm_string IN (211, 212, 123, 132) THEN 'Potential Customers'
        WHEN rfm_string IN (111, 112, 121, 114, 141) THEN 'Churn Risk Customers'
       END AS rfm_segment
FROM
    temp_rfm ;
    
-- Products that are sold together
SELECT DISTINCT ORDERNUMBER, SUBSTRING( GROUP_CONCAT( p.PRODUCTCODE), 1) AS Order_ids
FROM sales_data_sample p
WHERE p.ORDERNUMBER IN (
    SELECT ORDERNUMBER
    FROM (
        SELECT ORDERNUMBER, COUNT(*) AS rn
        FROM sales_data_sample
        WHERE STATUS = 'Shipped'
        GROUP BY ORDERNUMBER
    ) m
    WHERE rn = 2 -- change the number to see more number of products bought together
)  GROUP BY ORDERNUMBER;

-- city with the highest number of sales in a specific country
SELECT CITY, SUM(SALES) AS Revenue
FROM sales_data_sample
WHERE COUNTRY = 'UK' 
GROUP BY CITY
ORDER BY SUM(SALES) DESC;

-- What is the best product in a specific country?
SELECT DISTINCT COUNTRY, YEAR_ID, PRODUCTLINE, SUM(SALES) Revenue
FROM sales_data_sample
WHERE COUNTRY = 'USA'
GROUP BY COUNTRY, YEAR_ID, PRODUCTLINE
ORDER BY SUM(SALES) DESC;


				
                







 













        




