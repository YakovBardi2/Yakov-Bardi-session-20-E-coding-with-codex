-- Reporting queries for CostumeStore.dbo.CostumeSales

USE CostumeStore;
GO

/*
Report 1: Most popular costume
*/
SELECT TOP (1) WITH TIES
    CostumeName,
    SUM(Quantity) AS TotalUnitsSold
FROM CostumeStore.dbo.CostumeSales
GROUP BY CostumeName
ORDER BY TotalUnitsSold DESC;
GO

/*
Report 2: Most popular size
*/
SELECT TOP (1) WITH TIES
    Size,
    SUM(Quantity) AS TotalUnitsSold
FROM CostumeStore.dbo.CostumeSales
GROUP BY Size
ORDER BY TotalUnitsSold DESC;
GO

/*
Report 3: Customers with purchases and what they paid
*/
SELECT
    CONCAT(
        CustomerFirstName,
        ' ',
        CustomerLastName,
        ': ',
        Quantity,
        ' - ',
        CostumeName,
        ' ($',
        FORMAT(TotalCustomerPaid, 'N2'),
        ')'
    ) AS CustomerPurchase
FROM CostumeStore.dbo.CostumeSales
ORDER BY CustomerLastName, CustomerFirstName, DateSold;
GO

/*
Report 4: Profit per sale
*/
SELECT
    SaleId,
    CONCAT(CustomerFirstName, ' ', CustomerLastName) AS CustomerName,
    CostumeName,
    Size,
    Quantity,
    SoldPricePerCostume,
    Discount,
    CostPricePerCostume,
    Profit
FROM CostumeStore.dbo.CostumeSales
ORDER BY SaleId;
GO
