/* 

Cleaning Data in SQL Server Queries - Project: Online Retail UCI DB
Author: Huyen Phan

*/

-- Retrieve the database
SELECT *
FROM  online_retail_UCI_DB..online_retail_main


/* [01] Checking MISSING value's dis 
		- NULL
		- '0'
		- empty string 
*/


-- [01].1 Checking NULL Value 

--Counting NULL value in each column
SELECT
    SUM(CASE WHEN InvoiceNo IS NULL THEN 1 ELSE 0 END) AS InvoiceNo_null_count,
    SUM(CASE WHEN StockCode IS NULL THEN 1 ELSE 0 END) AS StockCode_null_count,
    SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS Description_null_count,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Quantity_null_count,
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS InvoiceDate_null_count,
    SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS UnitPrice_null_count,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS CustomerID_null_count,
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS Country_null_count
FROM online_retail_UCI_DB..online_retail_main;
-- Result: 0


/* Conclusion of [01].1
There are two columns containing NULL value: "Description" and "CustomerID"
--> Let's explore the meaning of those NULL values
*/

-- [01].2 Checking '0' Value 

SELECT
    SUM(CASE WHEN InvoiceNo = '0' THEN 1 ELSE 0 END) AS InvoiceNo_0_count,
    SUM(CASE WHEN StockCode = '0' THEN 1 ELSE 0 END) AS StockCode_0_count,
    SUM(CASE WHEN "Description" = '0' THEN 1 ELSE 0 END) AS Description_0_count,
    SUM(CASE WHEN Quantity = '0'  THEN 1 ELSE 0 END) AS Quantity_0_count,
    SUM(CASE WHEN UnitPrice = '0' THEN 1 ELSE 0 END) AS UnitPrice_0_count,
    SUM(CASE WHEN CustomerID = '0' THEN 1 ELSE 0 END) AS CustomerID_0_count,
    SUM(CASE WHEN Country = '0' THEN 1 ELSE 0 END) AS Country_0_count
FROM online_retail_UCI_DB..online_retail_main;

/* Conclusion of [01].2
There is only UnitPrice column contain '0' value with 2515 cells
--> Let's explore the meaning of these '0' values of UnitPrice column
*/

-- [01].3 Checking empty_string ' ' Value 
SELECT
    SUM(CASE WHEN InvoiceNo = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS InvoiceNo_empty_string_count,
    SUM(CASE WHEN StockCode = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS StockCode_empty_string_count,
    SUM(CASE WHEN "Description" = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS Description_empty_string_count,
    SUM(CASE WHEN Quantity = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS Quantity_empty_string_count,
    SUM(CASE WHEN UnitPrice = '0' OR InvoiceNo = ' 'THEN 1 ELSE 0 END) AS UnitPrice_empty_string_count,
    SUM(CASE WHEN CustomerID = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS CustomerID_empty_string_count,
    SUM(CASE WHEN Country = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS Country_empty_string_count
FROM online_retail_UCI_DB..online_retail_main;

/* Conclusion of [01].3
There is only UnitPrice column contain empty_string ' ' value with 2515 cells
Let's explore the meaning of these empty_string ' ' values of UnitPrice column
*/


/* [02] Checking OUTLIERS
		- 
		- 
*/

/* [03] Checking Contaminated data
		- Negative value in "Quantity" column
		- 
*/

/* [04] Checking Inconsistent Data
		- Checking the patterns of "Description" column.
		- Lets try to visualize them?
		- Then think of ways to standardize the inconsistent data 
*/


/* [05] Checking Invalid Data
		- Negative value in "Quantity" column
		- 
*/

/* [06] Checking Duplicate Data
		- Negative value in "Quantity" column
		- 
*/

/* [07] Checking Data Type Issues
		- Negative value in "Quantity" column
		- 
*/

SELECT * 
FROM online_retail_main
WHERE InvoiceNo NOT LIKE 'C%' AND Quantity < 0 
-- note: result shows that UnitPrice = 0 in those cases => maybe just test case


SELECT * 
FROM online_retail_main
WHERE InvoiceNo LIKE 'C%' AND Quantity < 0 
-- 01- which stockcode is canceled the most?


-- 02 - Looking the overview of cancelation invoice

SELECT *,	COUNT(*) OVER (PARTITION BY CustomerID) AS CustomerCountGroup, 
			COUNT(*) OVER (PARTITION BY InvoiceNo) AS InvoiceCountGroup, 
			COUNT(*) OVER (PARTITION BY Country) AS CountryCountGroup
FROM online_retail_main
WHERE InvoiceNo LIKE 'C%'
ORDER BY Quantity DESC, CustomerCountGroup DESC, InvoiceCountGroup DESC, CountryCountGroup DESC


-- Seperated the main table into smaller tables including: cancelation and issued_invoice



