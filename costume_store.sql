-- Costume store single-table implementation and sample reports using T-SQL

/*
This script creates a database and single table to track costume sales, loads sample data,
and demonstrates the required reports.
*/

-- Ensure the dedicated database exists and is selected
IF DB_ID(N'CostumeStore') IS NULL
BEGIN
    CREATE DATABASE CostumeStore;
END;
GO

USE CostumeStore;
GO

-- Reset for repeatable runs
IF OBJECT_ID(N'CostumeStore.dbo.CostumeSales', N'U') IS NOT NULL
BEGIN
    DROP TABLE CostumeStore.dbo.CostumeSales;
END;
GO

CREATE TABLE CostumeStore.dbo.CostumeSales
(
    SaleId              SMALLINT IDENTITY(1,1) PRIMARY KEY,
    CustomerFirstName   VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_CostumeSales_CustomerFirstName_not_blank CHECK (LTRIM(RTRIM(CustomerFirstName)) <> ''),
    CustomerLastName    VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_CostumeSales_CustomerLastName_not_blank CHECK (LTRIM(RTRIM(CustomerLastName)) <> ''),
    CostumeName         VARCHAR(25) NOT NULL,
    CONSTRAINT CHK_CostumeSales_CostumeName_not_blank CHECK (LTRIM(RTRIM(CostumeName)) <> ''),
    Size                CHAR(2) NOT NULL,
    CONSTRAINT CHK_CostumeSales_Size_not_blank CHECK (LTRIM(RTRIM(Size)) <> ''),
    CONSTRAINT CHK_CostumeSales_Size_valid_values CHECK (Size IN ('XS','S','M','L','XL')),
    Quantity            SMALLINT NOT NULL,
    CONSTRAINT CHK_CostumeSales_Quantity_greater_than_zero CHECK (Quantity > 0),
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
    StandardPricePerCostume AS (
        CASE Size
            WHEN 'XS' THEN 20.00
            WHEN 'S'  THEN 22.00
            WHEN 'M'  THEN 25.00
            WHEN 'L'  THEN 27.00
            WHEN 'XL' THEN 30.00
        END
    ) PERSISTED,
    Discount            DECIMAL(5,2) NOT NULL,
    CONSTRAINT DF_CostumeSales_Discount_default_zero DEFAULT 0.00,
    CONSTRAINT CHK_CostumeSales_Discount_non_negative CHECK (Discount >= 0),
    CONSTRAINT CHK_CostumeSales_Discount_not_exceed_profit_margin CHECK (Discount <= (StandardPricePerCostume - CostPricePerCostume)),
    SoldPricePerCostume AS (StandardPricePerCostume - Discount) PERSISTED,
    DateBought          DATE NOT NULL,
    CONSTRAINT CHK_CostumeSales_DateBought_on_or_after_store_open CHECK (DateBought >= '2020-01-01'),
    DateSold            DATE NOT NULL,
    CONSTRAINT CHK_CostumeSales_DateSold_not_before_purchase CHECK (DateSold >= DateBought),
    CONSTRAINT CHK_CostumeSales_DateSold_not_in_future CHECK (DateSold <= CAST(GETDATE() AS DATE)),
    NetSoldPrice AS (SoldPricePerCostume) PERSISTED,
    PaidFullPrice AS (
        CASE
            WHEN Discount = 0 AND SoldPricePerCostume = StandardPricePerCostume
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
    CONSTRAINT CHK_CostumeSales_SoldPrice_at_least_cost_price CHECK (SoldPricePerCostume >= CostPricePerCostume)
);
GO

INSERT INTO CostumeStore.dbo.CostumeSales (CustomerFirstName, CustomerLastName, CostumeName, Size, Quantity, Discount, DateBought, DateSold)
VALUES
('Chana','Goldberg','Artist','XS',2,0.00,'2020-02-14','2020-04-02'),
('Aliza','Duetch','Fire Man','L',1,0.00,'2021-03-09','2022-01-04'),
('Dovid','Rosen','Zebra','S',1,0.00,'2020-08-23','2020-08-25'),
('Shira','Pent','Colonial Boy','XS',1,0.00,'2021-09-17','2021-12-04'),
('Miriam','Gruen','Princess','M',3,0.00,'2022-07-06','2022-10-19'),
('Shoshana','Victor','Elephant','XL',1,0.00,'2020-11-28','2021-02-02'),
('Mendy','First','Colonial Girl','XS',1,0.00,'2021-05-24','2021-07-17'),
('Yisroel','Horowitz','Police Man','XL',1,0.00,'2022-01-16','2022-01-19'),
('Aliza','Duetch','American Girl Doll','S',2,0.00,'2021-03-12','2021-06-21'),
('Rochel','Rubin','Bumble Bee','S',1,0.00,'2020-09-11','2021-01-02'),
('Bracha','Ganz','Princess','M',4,0.00,'2020-11-03','2021-12-12'),
('Yaakov','Cohen','Princess','XS',1,0.00,'2021-12-04','2022-07-25'),
('Rina','Rosen','Artist','M',1,0.00,'2022-02-18','2022-05-28'),
('Rivkah','Goldberger','Zebra','S',1,0.00,'2022-09-14','2022-12-29');
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
    CONCAT(CustomerFirstName, ' ', CustomerLastName, ': ', Quantity, ' - ', CostumeName, ' ($', FORMAT(NetSoldPrice, 'N2'), ')') AS CustomerPurchase,
    TotalCustomerPaid
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
    NetSoldPrice,
    CostPricePerCostume,
    Profit
FROM CostumeStore.dbo.CostumeSales
ORDER BY SaleId;
GO
