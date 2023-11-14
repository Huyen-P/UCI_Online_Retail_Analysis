**1 - Project Objective**
<details><summary>Details</summary>
<p>
  
The author will play as a data analyst role, who will process the dataset from start to end to 
provide valuable Power BI dashboard serving for strategic purpose of the business.
propose the most appropriated strategies/ recommendations to boost the company growth.

</p>
</details> 

**2 - Data Wrangling**
<details><summary>Details</summary>
<p>
  
At this stage, an analysis of a transactional dataset from a non-retail UK company called UCI, conducted using SQL queries, revealed that 96.86% of the rows contained sales data (524,917 rows), 1.71% of the rows contained cancellation data (9,251 rows), 0.97% of the rows were duplicates (5,268 rows), 0.46% of the rows were test cases (2,470 rows), and 3 rows contained vague values labeled "Adjust bad debt." The data was collected from December 1, 2010 to December 9, 2011. 

![image](https://github.com/Huyen-P/UCI_Online_Retail_Analysis/assets/72473316/1ea9192a-7ac9-4f40-aec9-e7da49715d52)
Figure 1 - HomePage Dashboard, which summarize the result from data cleaning process

To categorize the whole data set into 5 groups including sales, cancellation, dupplicated, test case and vague rows, the DA went through the following steps:
- Review the raw dataset from Excel format to get more farmiliar with the dataset and take note any points of the weirdness, such as data type issue, missing data, empty cells, contaminated data, invalid data. This step can be done by using Filter  and Comment functions on Excel.
- Set the right data type for each column from Excel.
- Import the data excel file to SQL after finishing the Excel review and set up stage.
- Conduct an exploratory data analysis (EDA) in SQL based on the key notes beforehands at the Excel review stage.
- Conclude and group the main categories of the dataset: sale_view and cancellation_view, which are excluded duplicated rows, test case rows and vague rows.
- Decide next steps to process for each data category.
The initial data cleaning SQL script and steps can foud here (link).
Since the initial result from this EDA stage indicate that the dataset mainly involve to sale and cancelled rows, the DA can shape the main research and sub research questions of this project in relation to inventory management and sale/ marketing promotions in the next part.

</p>
</details> 

**3 - Conclusion**
<details><summary>Details</summary>
<p>
In conclusion, this project centered on the analysis of a retail dataset with the objective of providing valuable insights through Power BI dashboards to strategically support the growth of a non-store UK company, UCI. The data wrangling process involved a meticulous review of the dataset, SQL analysis, and categorization into 5 data groups including sales, cancellations, duplicates, test cases, and vague rows. The main research question focused on identifying beneficial business strategies for UCI's growth in the coming year, with sub-questions addressing inventory management and sales optimization.
The descriptive data analysis delved into inventory management and sales performance, utilizing features such as Demand, MeanDemand, Revenue, and others. Power BI dashboards, including Inventory Management and Sale Performance, were constructed to visualize insights derived from the analysis. The discussion highlighted the importance of considering both sale and cancellation data for precise evaluation, exemplified by the distinction between demand and sold revenue or quantity for specific StockCodes.
The descriptive data analysis delved into inventory management and sales performance, utilizing features such as Demand, MeanDemand, Revenue, and others. Power BI dashboards, including Inventory Management and Sale Performance, were constructed to visualize insights derived from the analysis. The discussion highlighted the importance of considering both sales and cancellation data for precise evaluation, as exemplified by the distinction between demand and sold revenue or quantity for the highest-demand product with StockCode "84879" (ASSORTED COLOR BIRD ORNAMENT) during the period from December 1, 2010, to December 9, 2011. However, the provided dashboards can be used to analyze relevant insights for any products in the dataset, depending on the specific requirements of the business.
Despite the comprehensive analysis, the project acknowledged limitations related to inconsistent UnitPrices for products with the same StockCode in the dataset. To address these challenges, a call for a robust data improvement process was emphasized, involving meticulous cleaning, standardization, validation, and thorough documentation to ensure data integrity, boost decision-making confidence, enhance model reliability, and improve overall operational efficiency.
In essence, this project not only provided actionable recommendations for UCI's growth strategies but also underscored the critical importance of maintaining a clean and standardized dataset for reliable and effective data-driven decision-making in the business context.
</p>
</details> 

**4 - Inventory Management Dashboard**

![image](https://github.com/Huyen-P/UCI_Online_Retail_Analysis/assets/72473316/6d1e7d55-d757-4a75-a4ac-f6754f53d91e)

**5 - Sale Performance Dashboard**

![image](https://github.com/Huyen-P/UCI_Online_Retail_Analysis/assets/72473316/ff64ec62-3dcf-4b22-add3-5131a7a912ed)


