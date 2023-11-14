/*EDA - Raw DB*/

-- Retrieve the database
SELECT *
FROM  online_retail_UCI_DB..online_retail_main


-- 01 -- Add one empty column name row_state into online_retail_raw table
ALTER TABLE online_retail_UCI_DB..online_retail_raw
ADD row_state NVARCHAR (50)


-- 02 - Create raw view (for HomePage Dashboard - Data source Overview)
CREATE VIEW raw_view_w_RowNum AS
SELECT *, 
		LEFT(DATENAME(Month,InvoiceDate),3) AS Month_3,
		DATENAME(weekday, InvoiceDate) AS dow,
		DATEPART(hour, InvoiceDate) AS "hour", 
		Quantity*UnitPrice AS total_values,
		ROW_NUMBER() OVER (PARTITION BY InvoiceNo, StockCode, "Description", Quantity, InvoiceDate, UnitPrice, CustomerID, Country ORDER BY (SELECT NULL)) AS RowNum
FROM online_retail_UCI_DB..online_retail_raw

SELECT *
INTO new_table
FROM raw_view_w_RowNum

UPDATE new_table
SET row_state = 'duplicated rows'
WHERE RowNum > 1

SELECT *
FROM new_table
WHERE row_state IS NULL

UPDATE new_table
SET row_state = 'sale rows'
WHERE	RowNum =1 AND 
		(Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B')
		OR (UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND InvoiceNo NOT LIKE 'A%' 
		AND "Description" IS NOT NULL AND Quantity > 0 AND CustomerID IS NOT NULL)

UPDATE new_table
SET row_state = 'cancellation rows'
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%' AND RowNum = 1

UPDATE new_table
SET row_state = 'test rows'
WHERE UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND CustomerID IS NULL AND RowNum = 1

UPDATE new_table
SET row_state = 'vague rows'
WHERE InvoiceNo LIKE 'A%'

CREATE VIEW raw_view AS 
SELECT *
FROM new_table


SELECT	ROUND(100*COUNT(CASE WHEN "row_state" = 'sale rows' THEN  "row_state" END)/COUNT( "row_state"),3) AS "Sale rows %",
		ROUND(100*COUNT(CASE WHEN "row_state" = 'cancellation rows' THEN  "row_state" END)/COUNT( "row_state"),3) AS "Cancellations rows %",
		ROUND(100*COUNT(CASE WHEN "row_state" = 'duplicated rows' THEN  "row_state" END)/COUNT( "row_state"),3) AS "Duplicated rows %",
		ROUND(100*COUNT(CASE WHEN "row_state" = 'test rows' THEN  "row_state" END)/COUNT( "row_state"),3) AS "Test rows %",
		ROUND(100*COUNT(CASE WHEN "row_state" = 'vague rows' THEN  "row_state" END)/COUNT( "row_state"),3) AS "Vague rows %"
FROM new_table

SELECT row_state, COUNT(row_state) AS "count"
FROM raw_view
GROUP BY row_state

-- 03 - Create Test_view
CREATE VIEW test_view AS
SELECT *, 
		LEFT(DATENAME(Month,InvoiceDate),3) AS Month_3,
		DATENAME(weekday, InvoiceDate) AS dow,
		DATEPART(hour, InvoiceDate) AS "hour", 
		Quantity*UnitPrice AS total_values
FROM online_retail_UCI_DB..online_retail_main
WHERE UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND CustomerID IS NULL



-- 04 - Create sale view
CREATE VIEW sale_view AS
SELECT	* , 
		LEFT(DATENAME(Month,InvoiceDate),3) AS Month_3,
		DATENAME(weekday, InvoiceDate) AS dow,
		DATEPART(hour, InvoiceDate) AS "hour", 
		Quantity*UnitPrice AS total_sales
FROM online_retail_UCI_DB..online_retail_main
WHERE (Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B')
	  OR (UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND InvoiceNo NOT LIKE 'A%' 
		  AND "Description" IS NOT NULL AND Quantity > 0 AND CustomerID IS NOT NULL)

-- Result: 524,877 associated rows. / 524,917
/* The charateristic of each column in sale_analysis view:
InvoiceNo: starting without letter C and A, nvarchar
StockCode: not NULL, nvarchar
Description: Product Name, nvarchar
Quantity: positive value, int
InvoiceDate: not NULL, datetime
UnitPrice: positive value
CustomerID: nvarchar, contains NULL and not NULL values
Country: nvarchar */


-- 05 - Create cancellation view
CREATE VIEW cancellation_view AS 
SELECT  *,
		LEFT(DATENAME(Month,InvoiceDate),3) AS Month_3,
		DATENAME(weekday, InvoiceDate) AS dow,
		DATEPART(hour, InvoiceDate) AS "hour", 
		ABS(Quantity)*UnitPrice AS total_cancelled_value
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%'\

SELECT *
FROM 
-- Result: 9,251 associated rows.
/* The charateristic of each column in sale_analysis view:
InvoiceNo: only starting with letter C, nvarchar
StockCode: not NULL, nvarchar
Description: Product Name, nvarchar
Quantity: negative value, int
InvoiceDate: not NULL, datetime
UnitPrice: positive value
CustomerID: nvarchar, contains NULL and not NULL values
Country: nvarchar */




                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              