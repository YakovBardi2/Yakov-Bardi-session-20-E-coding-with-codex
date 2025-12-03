-- Costume store single-table implementation and sample reports using T-SQL

/*
This script creates a single table to track costume sales, loads sample data,
and demonstrates the required reports.
*/

-- Reset for repeatable runs
IF OBJECT_ID(N'dbo.CostumeSales', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.CostumeSales;
END;
GO

CREATE TABLE dbo.CostumeSales
(
    SaleId              INT IDENTITY(1,1) PRIMARY KEY,
    CustomerFirstName   VARCHAR(50) NOT NULL,
    CustomerLastName    VARCHAR(50) NOT NULL,
    CostumeName         VARCHAR(50) NOT NULL,
    Size                CHAR(2) NOT NULL CHECK (Size IN ('XS','S','M','L','XL')),
    Quantity            INT NOT NULL CHECK (Quantity > 0),
    SoldPricePerCostume DECIMAL(6,2) NOT NULL CHECK (SoldPricePerCostume >= 0),
    DateBought          DATE NOT NULL,
    DateSold            DATE NOT NULL,
    -- Derived values based on the required fixed price list
    CostPricePerCostume AS (
        CASE Size
            WHEN 'XS' THEN 15.00
            WHEN 'S'  THEN 17.00
            WHEN 'M'  THEN 20.00
            WHEN 'L'  THEN 22.00
            WHEN 'XL' THEN 25.00
        END
    ) PERSISTED,
    PaidFullPrice AS (
        CASE
            WHEN SoldPricePerCostume = CASE Size
                WHEN 'XS' THEN 20.00
                WHEN 'S'  THEN 22.00
                WHEN 'M'  THEN 25.00
                WHEN 'L'  THEN 27.00
                WHEN 'XL' THEN 30.00
            END
            THEN 1 ELSE 0
        END
    ) PERSISTED,
    TotalCustomerPaid AS (Quantity * SoldPricePerCostume) PERSISTED,
    Profit AS ((Quantity * SoldPricePerCostume) - (Quantity *
        CASE Size
            WHEN 'XS' THEN 15.00
            WHEN 'S'  THEN 17.00
            WHEN 'M'  THEN 20.00
            WHEN 'L'  THEN 22.00
            WHEN 'XL' THEN 25.00
        END)) PERSISTED,
    CONSTRAINT CK_SoldPriceAtLeastCost CHECK (SoldPricePerCostume >=
        CASE Size
            WHEN 'XS' THEN 15.00
            WHEN 'S'  THEN 17.00
            WHEN 'M'  THEN 20.00
            WHEN 'L'  THEN 22.00
            WHEN 'XL' THEN 25.00
        END)
);
GO

INSERT INTO dbo.CostumeSales (CustomerFirstName, CustomerLastName, CostumeName, Size, Quantity, SoldPricePerCostume, DateBought, DateSold)
VALUES
('Chana','Goldberg','Artist','XS',2,20.00,'2020-02-14','2020-04-02'),
('Aliza','Duetch','Fire Man','L',1,22.00,'2021-03-09','2022-01-04'),
('Dovid','Rosen','Zebra','S',1,22.00,'2020-08-23','2020-08-25'),
('Shira','Pent','Colonial Boy','XS',1,20.00,'2021-09-17','2021-12-04'),
('Miriam','Gruen','Princess','M',3,25.00,'2022-07-06','2022-10-19'),
('Shoshana','Victor','Elephant','XL',1,30.00,'2020-11-28','2021-02-02'),
('Mendy','First','Colonial Girl','XS',1,20.00,'2021-05-24','2021-07-17'),
('Yisroel','Horowitz','Police Man','XL',1,30.00,'2022-01-16','2022-01-19'),
('Aliza','Duetch','American Girl Doll','S',2,22.00,'2021-03-12','2021-06-21'),
('Rochel','Rubin','Bumble Bee','S',1,22.00,'2020-09-11','2021-01-02'),
('Bracha','Ganz','Princess','M',4,25.00,'2020-11-03','2021-12-12'),
('Yaakov','Cohen','Princess','XS',1,20.00,'2021-12-04','2022-07-25'),
('Rina','Rosen','Artist','M',1,25.00,'2022-02-18','2022-05-28'),
('Rivkah','Goldberger','Zebra','S',1,22.00,'2022-09-14','2022-12-29');
GO

/*
Report 1: Most popular costume
*/
SELECT TOP (1) WITH TIES
    CostumeName,
    SUM(Quantity) AS TotalUnitsSold
FROM dbo.CostumeSales
GROUP BY CostumeName
ORDER BY TotalUnitsSold DESC;
GO

/*
Report 2: Most popular size
*/
SELECT TOP (1) WITH TIES
    Size,
    SUM(Quantity) AS TotalUnitsSold
FROM dbo.CostumeSales
GROUP BY Size
ORDER BY TotalUnitsSold DESC;
GO

/*
Report 3: Customers with purchases and what they paid
*/
SELECT
    CONCAT(CustomerFirstName, ' ', CustomerLastName, ': ', Quantity, ' - ', CostumeName, ' ($', FORMAT(SoldPricePerCostume, 'N2'), ')') AS CustomerPurchase,
    TotalCustomerPaid
FROM dbo.CostumeSales
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
    CostPricePerCostume,
    Profit
FROM dbo.CostumeSales
ORDER BY SaleId;
GO
