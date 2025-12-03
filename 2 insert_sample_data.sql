-- Sample data inserts for CostumeStore.dbo.CostumeSales

USE CostumeStore;
GO

-- Clear existing rows to avoid duplicating sample data on re-run
DELETE FROM CostumeStore.dbo.CostumeSales;
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
