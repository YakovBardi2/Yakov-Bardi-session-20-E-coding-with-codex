-- Costume store database and table setup using T-SQL

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
    SaleId              INT IDENTITY(1,1) PRIMARY KEY,
    CustomerFirstName   VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_CostumeSales_CustomerFirstName_not_blank CHECK (LTRIM(RTRIM(CustomerFirstName)) <> ''),
    CustomerLastName    VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_CostumeSales_CustomerLastName_not_blank CHECK (LTRIM(RTRIM(CustomerLastName)) <> ''),
    CostumeName         VARCHAR(25) NOT NULL,
    CONSTRAINT CHK_CostumeSales_CostumeName_not_blank CHECK (LTRIM(RTRIM(CostumeName)) <> ''),
    Size                CHAR(2) NOT NULL,
    CONSTRAINT CHK_CostumeSales_Size_valid_values CHECK (LTRIM(RTRIM(Size)) IN ('XS','S','M','L','XL')),
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
    -- Net price actually paid per costume after discount
    SoldPricePerCostume AS (StandardPricePerCostume - Discount) PERSISTED,
    DateBought          DATE NOT NULL,
    CONSTRAINT CHK_CostumeSales_DateBought_on_or_after_store_open CHECK (DateBought >= '2020-01-01'),
    DateSold            DATE NOT NULL,
    CONSTRAINT CHK_CostumeSales_DateSold_not_before_purchase CHECK (DateSold >= DateBought),
    CONSTRAINT CHK_CostumeSales_DateSold_not_in_future CHECK (DateSold <= CAST(GETDATE() AS DATE)),
    PaidFullPrice AS (
        CASE
            WHEN Discount = 0 THEN 1 ELSE 0
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
