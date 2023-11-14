-- Retrieve the database
SELECT *
FROM  online_retail_UCI_DB..online_retail_main

-- Calculate the demand of each product based 
CREATE VIEW DemandCalculation_View AS 
WITH Sales AS (
SELECT	StockCode, UnitPrice,
		SUM(Quantity) AS SoldQuantity
FROM sale_view
GROUP BY StockCode, UnitPrice
),

Cancellation AS (
SELECT	StockCode, UnitPrice,
		SUM(ABS(Quantity)) AS CancelledQuantity
FROM cancellation_view
GROUP BY StockCode, UnitPrice
)

SELECT
	sv.InvoiceNo,
	sv.StockCode,
	sv."Description",
	sv.InvoiceDate, 
	DATEPART(QUARTER, sv.InvoiceDate) AS "Quarter",
	sv.CustomerID, 
	sv.Country,
	sv.UnitPrice,
	sv.total_sales AS Revenue,
	COALESCE(SoldQuantity, 0) AS SoldQuantity,
    COALESCE(CancelledQuantity, 0) AS CancelledQuantity,
    COALESCE(SoldQuantity, 0) - COALESCE(CancelledQuantity, 0) AS Demand
FROM sale_view sv
LEFT JOIN Sales s ON sv.StockCode = s.StockCode AND sv.UnitPrice = s.UnitPrice
LEFT JOIN Cancellation c ON s.StockCode = c.StockCode AND s.UnitPrice = c.UnitPrice
--View Result
SELECT *
FROM DemandCalculation_View


-- Create a view with 6 columns, including StockCode, Demand, Revenue, RevenuePercentile, Quarter
CREATE VIEW InventoryManagement_View1 AS
WITH InventoryManagement_1 AS (
  SELECT
    StockCode,
	UnitPrice,
	Demand,
    Revenue,
    NTILE(100) OVER (ORDER BY Revenue DESC) AS RevenuePercentile, 
	"Quarter",
    SUM(Demand) OVER (PARTITION BY StockCode, "Quarter", UnitPrice) AS Demand_per_Quarter
  FROM DemandCalculation_View
)
SELECT *
FROM InventoryManagement_1
-- View Result
SELECT*
FROM InventoryManagement_View1
/*Question: why do I need RevenuePercentile? 
	Answer: This feature help you to categorize your StockCode into 3 groups, including 
			A (top 20% sales volumn), 
			B (the next 30% sales volumn of product), 
			C (the last 50% sales volumn of product)

	The function 'NTILE' in SQL server is used to divide an ordered result set into a specified number of roughly equal froup of 'tiles'
	In this specific context, the NTILE(100) is used to divide the result set into 100 percentiles based on the descending order of the product
	of Revenue ( = UnitPrice*Quantity). Each row will be assigned a percentile rank, and this information can be used to categorize the data 
	into groups.
*/


-- Create new view with 7 column from the previous view and one new column, which is MeanDemand
CREATE VIEW InventoryManagement_View2 AS
WITH InventoryManagement_2 AS (
  SELECT
    StockCode,
	UnitPrice,
	Revenue,
	RevenuePercentile,
    CASE
      WHEN RevenuePercentile <= 20 THEN 'A'
      WHEN RevenuePercentile <= 50 THEN 'B'
      ELSE 'C'
    END AS ABCCategory,
	Demand,
	"Quarter",
	Demand_per_Quarter, 
	AVG(Demand) OVER (PARTITION BY StockCode) AS MeanDemand
  FROM InventoryManagement_View1
)
SELECT * 
FROM InventoryManagement_2

--View Result
SELECT*
FROM InventoryManagement_View2

-- Create new view with8 column from the previous view and one new column, which is Service Level
CREATE VIEW InventoryManagement_View3 AS
WITH InventoryManagement_3 AS (
  SELECT
	*,
	CASE
    WHEN ABCCategory = 'A' THEN 0.98
    WHEN ABCCategory = 'B' THEN 0.95
    WHEN ABCCategory = 'C' THEN 0.90
	END AS ServiceLevel
	FROM InventoryManagement_View2
)
SELECT * 
FROM InventoryManagement_3

SELECT*
FROM InventoryManagement_View3

-- Create new view with 2 columns, including StockCode and StdDevDemand

CREATE VIEW InventoryManagement_StdDevDemand_View AS
WITH MeanDemandCalculation AS (
  SELECT
    StockCode,
	MeanDemand
  FROM InventoryManagement_View3 
  GROUP BY StockCode, MeanDemand
),
Differences AS (
  SELECT
    V.StockCode,
    V.Demand,
    M.MeanDemand
  FROM InventoryManagement_View3  V
  JOIN MeanDemandCalculation M ON V.StockCode = M.StockCode
),
SquaredDifferences AS (
  SELECT
    StockCode,
    POWER(Demand - MeanDemand, 2) AS SquaredDifference
  FROM Differences
),
VarianceCalculation AS (
  SELECT
    StockCode,
    SUM(SquaredDifference) / COUNT(SquaredDifference) AS Variance
  FROM SquaredDifferences
  GROUP BY StockCode
),
StdDeviationCalculation AS (
  SELECT
    StockCode,
    SQRT(Variance) AS StdDevDemand
  FROM VarianceCalculation
)

-- Select the results
SELECT *
FROM StdDeviationCalculation;

SELECT *
FROM InventoryManagement_StdDevDemand_View


-- Create new view that combine StdDevDemand column to the previous view
CREATE VIEW InventoryManagement_View4 AS 
SELECT 
	V3.StockCode,
	V3.Demand,
	V3.Revenue,
	V3.RevenuePercentile,
	V3.ABCCategory,
	V3."Quarter",
	V3.Demand_per_Quarter,
	V3.MeanDemand,
	V3.ServiceLevel,
	S.StdDevDemand
FROM InventoryManagement_View3 AS V3
LEFT JOIN InventoryManagement_StdDevDemand_View AS S ON V3.StockCode=S.StockCode

SELECT *
FROM InventoryManagement_View4

-- Create new view with all column from previous view and 1 new column which is Zscore 
CREATE VIEW InventoryManagement_View5 AS
WITH ZScoreCalculation AS (
  SELECT
    *,
    CASE
    WHEN StdDevDemand = 0 THEN NULL -- Handle divide by zero
    ELSE (Demand - MeanDemand) / StdDevDemand
    END AS ZScore
  FROM InventoryManagement_View4
)
-- Select the results
SELECT *
FROM ZScoreCalculation;

SELECT *
FROM InventoryManagement_View5

-- Create new view with all column from previous view and 1 new column which is SafetyStock
CREATE VIEW InventoryManagement_View6 AS 
WITH SafetyStockCalculation AS (
  SELECT
    *,
	CASE
      WHEN ServiceLevel = 0 OR StdDevDemand = 0 THEN NULL -- Handle divide by zero
      ELSE ServiceLevel * StdDevDemand
    END AS SafetyStock
  FROM InventoryManagement_View5
)
-- Select the results
SELECT *
FROM SafetyStockCalculation;

CREATE VIEW InventoryManagement_View7 AS 
WITH ReorderPointCalculation AS (
  SELECT
    *,
	CASE
      WHEN ServiceLevel = 0 OR StdDevDemand = 0 THEN NULL -- Handle divide by zero
      ELSE (ServiceLevel * StdDevDemand) + MeanDemand
    END AS ReorderPoint
  FROM InventoryManagement_View6
)
-- Select the results
SELECT *
FROM ReorderPointCalculation;

SELECT *
FROM InventoryManagement_FinalView


CREATE VIEW InventoryManagementAnalysis_FinalView AS 
WITH ReorderCalculation AS (
  SELECT
	*,
    CASE
      WHEN Demand_per_Quarter = 0 THEN NULL -- Handle divide by zero
      ELSE ReorderPoint / Demand_per_Quarter 
	END AS ReorderQuantity,
    CASE
      WHEN Demand_per_Quarter = 0 THEN NULL -- Handle divide by zero
      ELSE CEILING(1 / (ReorderPoint / Demand_per_Quarter))
    END AS ReorderFrequency

  FROM InventoryManagement_View10
)

-- Select the results
SELECT *
FROM ReorderCalculation;

SELECT * 
FROM InventoryManagementAnalysis_FinalView