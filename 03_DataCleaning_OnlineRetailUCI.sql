/* 

Cleaning Data in SQL Server Queries - Project: Online Retail UCI DB
Author: Huyen Phan

*/

-- Retrieve the database
SELECT *
FROM  online_retail_UCI_DB..online_retail_main


-- 1 Checking duplicate rows
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY InvoiceNo, StockCode, "Description", Quantity, InvoiceDate, UnitPrice, CustomerID, Country ORDER BY (SELECT NULL)) AS RowNum
    FROM online_retail_UCI_DB..online_retail_main
)

SELECT *
FROM CTE
WHERE RowNum > 1
ORDER BY RowNum DESC
-- Result: 5268 duplicate rows, the maximum numbers of repetition is 20, and the minimum is 2.

-----------------------------------------------------------------------------------------

/* [02] Checking MISSING value's dis 
		- NULL
		- '0'
		- empty string 
*/

-- [02].1 NULL Value 

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
-- Result: 1454 NULL cells in Description column and 135.037 NULL cells in CustomerID column and the rest do not contain NULL values. 

-- Checking rows associated with NULL values in CustomerID column
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE CustomerID IS NULL

/* Conclusion of [02].1
There are two columns containing NULL value: "Description" and "CustomerID"
--> Let's explore the meaning of those NULL values
*/

-- [02].2 Checking '0' Value 

SELECT
    SUM(CASE WHEN InvoiceNo = '0' THEN 1 ELSE 0 END) AS InvoiceNo_0_count,
    SUM(CASE WHEN StockCode = '0' THEN 1 ELSE 0 END) AS StockCode_0_count,
    SUM(CASE WHEN "Description" = '0' THEN 1 ELSE 0 END) AS Description_0_count,
    SUM(CASE WHEN Quantity = '0'  THEN 1 ELSE 0 END) AS Quantity_0_count,
    SUM(CASE WHEN UnitPrice = '0' THEN 1 ELSE 0 END) AS UnitPrice_0_count,
    SUM(CASE WHEN CustomerID = '0' THEN 1 ELSE 0 END) AS CustomerID_0_count,
    SUM(CASE WHEN Country = '0' THEN 1 ELSE 0 END) AS Country_0_count
FROM online_retail_UCI_DB..online_retail_main;

/* Conclusion of [02].2
There is only UnitPrice column contain '0' value with 2515 cells
--> Let's explore the meaning of these '0' values of UnitPrice column
*/

-- [02].3 Checking empty_string ' ' Value 
SELECT
    SUM(CASE WHEN InvoiceNo = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS InvoiceNo_empty_string_count,
    SUM(CASE WHEN StockCode = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS StockCode_empty_string_count,
    SUM(CASE WHEN "Description" = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS Description_empty_string_count,
    SUM(CASE WHEN Quantity = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS Quantity_empty_string_count,
    SUM(CASE WHEN UnitPrice = '0' OR InvoiceNo = ' 'THEN 1 ELSE 0 END) AS UnitPrice_empty_string_count,
    SUM(CASE WHEN CustomerID = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS CustomerID_empty_string_count,
    SUM(CASE WHEN Country = '0' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS Country_empty_string_count
FROM online_retail_UCI_DB..online_retail_main;

/* Conclusion of [02].3
There is only UnitPrice column contain empty_string ' ' value with 2515 cells
Let's explore the meaning of these empty_string ' ' values of UnitPrice column
*/


/* [03] Checking Invalid Data
		- Negative value in "Quantity" column - NEGATIVE QUANTITY / POSITIVE QUANTITY
		- The negative and '0' value in "UnitPrice" column - NEGATIVE UNITPRICE / 0 UNITPRICE
*/

-- [03](a) Checking negative value in Quantity column - NEGATIVE QUANTITY
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 
-- There are 10,587 rows has values < 0 in Quantity column
-- Need to identify the meaning of these rows -> Check with other important columns.

-- [03](b) Checking negative value in Quantity together win C InvoiceNo - NEGATIVE QUANTITY - CANCELLATION
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%'
-- Result: 9,251 rows of cancellation
-- -> can exclude these rows in Sales Dashboard, and include these rows in Cancelation Dashboard

-- [03](c) Checking negative Quantitive, C InvoiceNo and 0 = UnitPrice - NEGATIVE QUANTITY
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%' AND UnitPrice = 0
-- Result: no associated rows

-- [03](d) Checking negative Quantitive, C InvoiceNo and UnitPrice > 0 - NEGATIVE QUANTITY - CANCELLATION 
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%' AND UnitPrice > 0 AND StockCode <> 'B'
-- Result: 9,251 rows (like b)

-- [03](e) Checking negative Quantitive, C InvoiceNo and UnitPrice < 0 - NEGATIVE QUANTITY
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%' AND UnitPrice < 0
-- Result: no associated rows.

-- [03](f) Checking negative value in Quantity together without C InvoiceNo - NEGATIVE QUANTITY - TEST
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' 
/* Result: there are 1336 associated rows. 
It is clearly to see that all these rows have '0' value at associated cells in UnitPrice column; 
and 'NULL' value at associated cells in CustomerID column. 
So the author assumed that all these rows are the result of system test 
-> We can exclude these rows in our Sales Dashboard and Cancellation DashBoard
-> Should we delete them in Sales view
-> Maybe I can group them into a TEST table */

-- [03](g) Checking negative value in Quantity together without C InvoiceNo, UnitPricxce = 0 - NEGATIVE QUANTITY - TEST
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice ='0'
-- Result: same with (f)

-- [03](h) Checking negative value in Quantity together without C InvoiceNo, UnitPricxce > 0 - NEGATIVE QUANTITY 
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice > 0
-- Result: no associated rows.

-- [03](j) Checking negative value in Quantity together without C InvoiceNo, UnitPricxce < 0 - NEGATIVE QUANTITY 
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice < 0
-- Result: no associated rows.

-- [03](k) Checking negative value in Quantity together without C InvoiceNo, UnitPrice = 0, CustomerID = NULL - NEGATIVE QUANTITY - TEST
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice ='0' AND CustomerID IS NULL
-- Result: 1,336 rows (same with f)

-- [03](l) Checking negative value in Quantity together without C InvoiceNo, UnitPrice = 0, CustomerID not null - NEGATIVE QUANTITY
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice ='0' AND CustomerID IS NOT NULL
-- Result: no associated rows

-- [03](m) Checking negative value in Quantity together without C InvoiceNo, UnitPrice > 0, CustomerID not null - NEGATIVE QUANTITY
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice > 0 AND CustomerID IS NOT NULL
-- Result: no associated rows

-- [03](n) Checking negative value in Quantity together without C InvoiceNo, UnitPrice < 0, CustomerID not null - NEGATIVE QUANTITY
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%' AND UnitPrice < 0 AND CustomerID IS NOT NULL
-- Result: no associated rows

-------------------------------------------------------------------------------------------------------------------------------------------
-- [03](o) NEGATIVE UnitPrice
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice < 0
-- It shows only 2 rows with strange InvoiceNo starting with letter 'A', CustomerID is NULL.

-- [03](p) InvoiceNo start with letter A - OUT OF SALE, CANCELLATION, TEST -> VAGUE rows
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE InvoiceNo LIKE 'A%'
-- It reveals 3 strange rows. 
----------------------------------------------------------------------------------------------------------------------------------------------
-- [03](q) UnitPrice = 0 
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0
-- 2510 rows, which views do these row belong to? NOT SALE. BUT TEST OR CANCELLATION?

-- [03](r) UnitPrice = 0, InvoiceNo start with letter C
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0 AND InvoiceNo LIKE 'C%'
-- no associated rows

-- [03](s) UnitPrice = 0 , InvoiceNo not start with letter C 
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%'
-- 2510 rows, same result with q -> NOT SALE AND CANCELLATION. ONLY TEST?

-- [03](t) UnitPrice = 0, InvoiceNo not start with letter C, Quantity > 0, CustomerID IS NULL - TEST view
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0 AND CustomerID IS NULL
-- 1134 rows - TEST view (no real customer since CustomerID is NULL, No revenue since UnitPrice = 0)

-- [03](u) UnitPrice = 0, InvoiceNo not start with letter C, Quantity > 0, CustomerID IS NOT NULL - SALE view
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0 AND CustomerID IS NOT NULL
-- 40 rows - would be promotion item in an invoice with multiple products -> SALE view

---------------------------------------------------------------------------------------
-- Conclusion of SALE VIEW from initial EDA
SELECT * 
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B'
-- Result: 524,877 associated rows.


-- Conclusion of CANCELLATION VIEW from initial EDA
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%'
-- Result 9,251 rows (from b and d)


-- Conclusion of TEST VIEW from initial EDA
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND CustomerID IS NULL
-- Result: 2470 rows ( from f,g,k,t)


-- Conclusion of VAGUE rows from initial EDA
SELECT *
FROM online_retail_UCI_DB..online_retail_main
WHERE InvoiceNo LIKE 'A%'





