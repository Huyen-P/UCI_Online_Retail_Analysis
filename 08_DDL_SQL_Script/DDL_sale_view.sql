USE [online_retail_UCI_DB]
GO

/****** Object:  View [dbo].[sale_view]    Script Date: 11/15/2023 10:21:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[sale_view] AS
SELECT	* , 
		LEFT(DATENAME(Month,InvoiceDate),3) AS Month_3,
		DATENAME(weekday, InvoiceDate) AS dow,
		DATEPART(hour, InvoiceDate) AS "hour", 
		Quantity*UnitPrice AS total_sales
FROM online_retail_UCI_DB..online_retail_main
WHERE (Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B')
	  OR (UnitPrice = 0 AND InvoiceNo NOT LIKE 'C%' AND InvoiceNo NOT LIKE 'A%' 
		  AND "Description" IS NOT NULL AND Quantity > 0 AND CustomerID IS NOT NULL)
GO


