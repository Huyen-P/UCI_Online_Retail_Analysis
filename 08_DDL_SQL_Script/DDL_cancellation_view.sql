USE [online_retail_UCI_DB]
GO

/****** Object:  View [dbo].[cancellation_view]    Script Date: 11/15/2023 10:23:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[cancellation_view] AS 
SELECT  *,
		LEFT(DATENAME(Month,InvoiceDate),3) AS Month_3,
		DATENAME(weekday, InvoiceDate) AS dow,
		DATEPART(hour, InvoiceDate) AS "hour", 
		ABS(Quantity)*UnitPrice AS total_cancelled_value
FROM online_retail_UCI_DB..online_retail_main
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%'
GO


