-- KPI Cards (Totals)
-- Q1. Total Sales
SELECT SUM(SalesAmount) AS TotalSales
FROM factsales;

-- Q2. Total Profit
SELECT SUM(SalesAmount - TotalProductCost) AS TotalProfit
FROM factsales;

-- Q3. Total Orders
SELECT COUNT(Order_Number) AS TotalOrders
FROM factsales;

-- Q4. Total Production Cost
SELECT SUM(TotalProductCost) AS TotalProductionCost
FROM factsales;

-- Q5. Total Freight Charges
SELECT SUM(Freight) AS TotalFreightCharges
FROM factsales;

-- Time-Series Analysis (Year / Quarter / Month / Day)
-- Q6. Year-wise Sales
SELECT d.CalendarYear as Year, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimdate d ON s.OrderDateKey = d.DateKey
GROUP BY Year
ORDER BY Year;

-- Q7. Month-wise Sales
SELECT d.EnglishMonthName as Month, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimdate d ON s.OrderDateKey = d.DateKey
GROUP BY Month, d.MonthNumberOfYear
ORDER BY d.MonthNumberOfYear;

-- Q8. Quarter-wise Sales
SELECT d.CalendarQuarter as Quarter, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimdate d ON s.OrderDateKey = d.DateKey
GROUP BY Quarter
ORDER BY Quarter;

-- Q9. Day-wise Sales for a Selected Month & Year
SELECT d.DayNumberOfMonth as Day, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimdate d ON s.OrderDateKey = d.DateKey
WHERE d.CalendarYear = 2013 AND d.MonthNumberOfYear = 6
GROUP BY Day
ORDER BY Day;

-- Product Hierarchy (Category / Subcategory / Product)
-- Q10. Sales by Product Category
SELECT p.EnglishProductCategoryName as ProductCategory, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimproducts p ON s.ProductKey = p.ProductKey
GROUP BY ProductCategory
ORDER BY Sales DESC;

-- Q11. Sales by Product Subcategory
SELECT p.EnglishProductSubcategoryName as ProductSubCategory, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimproducts p ON s.ProductKey = p.ProductKey
GROUP BY ProductSubCategory
ORDER BY Sales DESC;

-- Q12. Top 10 Products by Sales
SELECT p.EnglishProductName as Product, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimproducts p ON s.ProductKey = p.ProductKey
GROUP BY Product
ORDER BY Sales DESC
LIMIT 10;

-- Q13. Profit by Product Category
SELECT p.EnglishProductCategoryName as ProductCategory,
       SUM(profit) AS Profit
FROM factsales s
JOIN dimproducts p ON s.ProductKey = p.ProductKey
GROUP BY ProductCategory
ORDER BY Profit DESC;

-- Geography (Region / Country)
-- Q14. Region-wise Sales
SELECT r.SalesTerritoryRegion as Region, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimsalesterritory r on s.SalesTerritoryKey=r.SalesTerritoryKey
GROUP BY Region
ORDER BY Sales DESC;

-- Q15. Country-wise Sales
SELECT c.SalesTerritoryCountry as Country, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimsalesterritory c on s.SalesTerritoryKey=c.SalesTerritoryKey
GROUP BY Country
ORDER BY Sales DESC;

-- Slicer-Based Filtering (Dashboard Filters)
-- Q16. Sales by Year & Country
SELECT d.CalendarYear as Year,t.SalesTerritoryCountry as Country,sum(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimsalesterritory t on s.SalesTerritoryKey=t.SalesTerritoryKey
JOIN dimdate d on s.OrderDateKey=d.DateKey 
WHERE d.CalendarYear = 2013
AND t.SalesTerritoryCountry = 'United States';

-- Q17. Month-wise Sales for a Selected Year & Category
SELECT d.EnglishMonthName as Month, SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimdate d ON s.OrderDateKey = d.DateKey
JOIN dimproducts p ON s.ProductKey = p.ProductKey
WHERE d.CalendarYear = 2013
AND p.EnglishProductCategoryName = 'Bikes'
GROUP BY Month, d.MonthNumberOfYear
ORDER BY d.MonthNumberOfYear;

-- Ranking / Top-N / Contribution
-- Q18. Rank Categories by Sales
SELECT RANK() OVER (ORDER BY SUM(s.SalesAmount) DESC) AS SalesRank,
	   p.EnglishProductCategoryName as ProductCategory,
       SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimproducts p ON s.ProductKey = p.ProductKey
GROUP BY ProductCategory
ORDER BY SalesRank;

-- Q19. Ranking SubCategories by Sales
SELECT RANK() OVER (ORDER BY SUM(s.SalesAmount) DESC) AS SalesRank,
	   p.EnglishProductSubcategoryName as ProductSubCategory,
       SUM(s.SalesAmount) AS Sales
FROM factsales s
JOIN dimproducts p ON s.ProductKey = p.ProductKey
GROUP BY ProductSubCategory
ORDER BY SalesRank;

-- Q20. Region Contribution to Total Sales (percentage)
WITH RegionSales AS (
    SELECT t.SalesTerritoryRegion as Region, SUM(s.SalesAmount) AS Sales
    FROM factsales s
    JOIN dimsalesterritory t on s.SalesTerritoryKey=t.SalesTerritoryKey
    GROUP BY Region
)
SELECT Region, Sales,
       100.0 * Sales / SUM(Sales) OVER() AS PercentContribution
FROM RegionSales
ORDER BY Sales DESC;