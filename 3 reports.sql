-- Reporting queries for CostumeStore.dbo.CostumeSales

USE CostumeStore;
GO

/*
Report 1: Most popular costume
*/
SELECT TOP (1) WITH TIES
    C.CostumeName,
    SUM(C.Quantity) AS TotalUnitsSold
FROM CostumeStore.dbo.CostumeSales AS C
GROUP BY C.CostumeName
ORDER BY TotalUnitsSold DESC;
GO

/*
Report 2: Most popular size
*/
SELECT TOP (1) WITH TIES
    C.Size,
    SUM(C.Quantity) AS TotalUnitsSold
FROM CostumeStore.dbo.CostumeSales AS C
GROUP BY C.Size
ORDER BY TotalUnitsSold DESC;
GO

/*
Report 3: Customers with purchases and what they paid
*/
SELECT
    CONCAT(
        C.CustomerFirstName,
        ' ',
        C.CustomerLastName,
        ': ',
        C.Quantity,
        ' - ',
        C.CostumeName,
        ' ($',
        FORMAT(C.TotalCustomerPaid, 'N2'),
        ')'
    ) AS CustomerPurchase
FROM CostumeStore.dbo.CostumeSales AS C
ORDER BY C.CustomerLastName, C.CustomerFirstName, C.DateSold;
GO

/*
Report 4: Profit per sale
*/
SELECT
    C.SaleId,
    CONCAT(C.CustomerFirstName, ' ', C.CustomerLastName) AS CustomerName,
    C.CostumeName,
    C.Size,
    C.Quantity,
    C.SoldPricePerCostume,
    C.Discount,
    C.CostPricePerCostume,
    C.Profit
FROM CostumeStore.dbo.CostumeSales AS C
ORDER BY C.SaleId;
GO
