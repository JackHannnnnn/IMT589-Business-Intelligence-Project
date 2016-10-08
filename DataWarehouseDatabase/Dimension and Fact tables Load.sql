-----------------------------------DimProduct-----------------------------------

--Empty DimProduct--
ALTER TABLE FactTargetSalesQuantity
 	DROP CONSTRAINT FK_FTSQ_DimProduct;
ALTER TABLE FactSales
 	DROP CONSTRAINT FK_FS_DimProduct;
DELETE DimProduct;

--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimProduct ON;

INSERT INTO dbo.DimProduct
(
DimProductID,
Product,
ProductID,
ProductType,
ProductTypeID,
ProductCategory,
ProductCategoryID,
Color,
Style,
UnitofMeasure,
UnitofMeasureID,
Weight,
Price,
Cost,
WholesalePrice
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
'Unknown',
0,
'Unknown',
0,
'Unknown',
0,
'Unknown',
'Unknown',
0,
0,
0,
0,
0,
0
)

-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimProduct OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimProduct', RESEED, 0);
GO

--Load DimProduct--
INSERT INTO dbo.DimProduct
SELECT p.Product, p.ProductID, pt.ProductType,
pt.ProductTypeID, pc.ProductCategory, pc.ProductCategoryID,
p.Color, p.Style, u.UnitofMeasure, u.UnitofMeasureID,
p.Weight, p.Price, p.Cost, p.WholesalePrice
FROM dbo.StageProduct AS p
INNER JOIN dbo.StageUnitofMeasure AS u
ON p.UnitofMeasureID = u.UnitofMeasureID
INNER JOIN dbo.StageProductType AS pt
ON p.ProductTypeID = pt.ProductTypeID
INNER JOIN dbo.StageProductCategory AS pc
ON pt.ProductCategoryID = pc.ProductCategoryID;
GO

-----------------------------------DimSegment-----------------------------------

--Empty DimSegment--
ALTER TABLE dbo.FactSales
 	DROP CONSTRAINT FK_FS_DimSegment;
DELETE dbo.DimSegment;

--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimSegment ON;

INSERT INTO dbo.DimSegment
(
DimSegmentID,
Segment,
SegmentID,
SubSegment,
SubSegmentID
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
'Unknown',
0,
'Unknown',
0
)
-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimSegment OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimSegment', RESEED, 0);
GO

--Load DimSegment--
INSERT INTO dbo.DimSegment
SELECT s.Segment, s.SegmentID,
ss.SubSegment, ss.SubSegmentID
FROM dbo.StageSegment AS s
INNER JOIN dbo.StageSubSegment AS ss
ON s.SegmentID = ss.SegmentID;
GO


-----------------------------------DimChannel-----------------------------------

--Empty DimChannel--
ALTER TABLE dbo.FactSales
 	DROP CONSTRAINT FK_FS_DimChannel;
ALTER TABLE dbo.FactTargetSalesAmount
 	DROP CONSTRAINT FK_FTSA_DimChannel;
DELETE dbo.DimChannel;

--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimChannel ON;

INSERT INTO dbo.DimChannel
(
DimChannelID,
ChannelCategory,
ChannelCategoryID,
Channel,
ChannelID
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
'Unknown',
0,
'Unknown',
0
)
-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimChannel OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimChannel', RESEED, 0);
GO

--Load DimChannel--
INSERT INTO dbo.DimChannel
SELECT cc.ChannelCategory, cc.ChannelCategoryID,
c.Channel, c.ChannelID
FROM dbo.StageChannel AS c
INNER JOIN dbo.StageChannelCategory AS cc
ON c.ChannelCategoryID = cc.ChannelCategoryID;
GO

-----------------------------------DimGeography-----------------------------------

--Empty DimGeography--
ALTER TABLE dbo.DimCustomer
 	DROP CONSTRAINT FK_DimCustomer;
ALTER TABLE dbo.DimStore
 	DROP CONSTRAINT FK_DimStore;
ALTER TABLE dbo.DimReseller
 	DROP CONSTRAINT FK_DimReseller;
DELETE DimGeography;

--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimGeography ON;

INSERT INTO dbo.DimGeography
(
DimGeographyID,
Address,
City,
StateProvince,
Country,
PostalCode
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown'
)
-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimGeography OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimGeography', RESEED, 0);
GO

--Load DimGeography--
INSERT INTO dbo.DimGeography
SELECT Address, City, StateProvince, Country, PostalCode FROM dbo.StageCustomer
UNION 
SELECT Address, City, StateProvince, Country, PostalCode FROM dbo.StageReseller
UNION
SELECT Address, City, StateProvince, Country, PostalCode FROM dbo.StageStore;
GO

-----------------------------------DimCustomer-----------------------------------

--Empty DimCustomer--
ALTER TABLE dbo.FactSales
 	DROP CONSTRAINT FK_FS_DimCustomer;
DELETE dbo.DimCustomer;

--Add constraint back--
ALTER TABLE dbo.DimCustomer
 	ADD CONSTRAINT FK_DimCustomer FOREIGN KEY (DimGeographyID) REFERENCES DimGeography (DimGeographyID);
  
--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimCustomer ON;

INSERT INTO dbo.DimCustomer
(
DimCustomerID,
CustomerID,
DimGeographyID,
FirstName,
LastName,
Gender,
EmailAddress,
PhoneNumber
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
NEWID(),
-1,
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown'
)
-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimCustomer OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimCustomer', RESEED, 0);
GO

--Load DimCustomer--
INSERT INTO dbo.DimCustomer
SELECT c.CustomerID, g.DimGeographyID, c.FirstName, c.LastName, c.Gender, c.EmailAddress, c.PhoneNumber
FROM dbo.StageCustomer AS c
INNER JOIN dbo.DimGeography AS g
ON c.Address = g.Address AND c.City = g.City AND c.StateProvince = g.StateProvince AND c.Country = g.Country 
AND c.PostalCode = g.PostalCode
GO

-----------------------------------DimStore-----------------------------------

--Empty DimStore--
ALTER TABLE dbo.FactSales
 	DROP CONSTRAINT FK_FS_DimStore;
ALTER TABLE dbo.FactTargetSalesAmount
 	DROP CONSTRAINT FK_FTSA_DimStore;
DELETE dbo.DimStore;

--Add constraint back--
ALTER TABLE dbo.DimStore
 	ADD CONSTRAINT FK_DimStore FOREIGN KEY (DimGeographyID) REFERENCES DimGeography (DimGeographyID);
  
--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimStore ON;

INSERT INTO dbo.DimStore
(
DimStoreID,
DimGeographyID,
StoreID,
StoreNumber,
StoreManager,
PhoneNumber
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
-1,
0,
0,
'Unknown',
'Unknown'
)
-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimStore OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimStore', RESEED, 0);
GO

--Load DimStore--
INSERT INTO dbo.DimStore
SELECT g.DimGeographyID, s.StoreID, s.StoreNumber,
s.StoreManager, s.PhoneNumber
FROM dbo.StageStore AS s
INNER JOIN dbo.DimGeography AS g
ON s.Address = g.Address AND s.City = g.City AND s.StateProvince = g.StateProvince AND s.Country = g.Country 
AND s.PostalCode = g.PostalCode
GO

-----------------------------------DimReseller-----------------------------------

--Empty DimReseller--
ALTER TABLE dbo.FactSales
 	DROP CONSTRAINT FK_FS_DimReseller;
ALTER TABLE dbo.FactTargetSalesAmount
 	DROP CONSTRAINT FK_FTSA_DimReseller;
DELETE dbo.DimReseller;

--Add constraint back--
ALTER TABLE dbo.DimReseller
 	ADD CONSTRAINT FK_DimReseller FOREIGN KEY (DimGeographyID) REFERENCES DimGeography (DimGeographyID);
  
--Load an unknown member record--
SET IDENTITY_INSERT dbo.DimReseller ON;

INSERT INTO dbo.DimReseller
(
DimResellerID,
DimGeographyID,
ResellerID,
ResellerName,
Contact,
EmailAddress,
PhoneNumber
)
VALUES
(
-1, -- I use -1 as an ID for my unknown members so I always know what they are
-1,
NEWID(),
'Unknown',
'Unknown',
'Unknown',
'Unknown'
)
-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.DimReseller OFF;
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.DimReseller', RESEED, 0);
GO

--Load DimReseller--
INSERT INTO dbo.DimReseller
SELECT g.DimGeographyID, r.ResellerID, r.ResellerName,  r.Contact, r.EmailAddress, r.PhoneNumber
FROM dbo.StageReseller AS r
INNER JOIN dbo.DimGeography AS g
ON r.Address = g.Address AND r.City = g.City AND r.StateProvince = g.StateProvince AND r.Country = g.Country 
AND r.PostalCode = g.PostalCode
GO

-----------------------------------FactSales-----------------------------------

--Empty FactSales--
DELETE dbo.FactSales;

--Add constraints back--
ALTER TABLE dbo.FactSales ADD
CONSTRAINT FK_FS_DimCustomer FOREIGN KEY (DimCustomerID) REFERENCES dbo.DimCustomer (DimCustomerID),
CONSTRAINT FK_FS_DimStore FOREIGN KEY (DimStoreID) REFERENCES dbo.DimStore (DimStoreID),
CONSTRAINT FK_FS_DimReseller FOREIGN KEY (DimResellerID) REFERENCES DimReseller (DimResellerID),
CONSTRAINT FK_FS_DimChannel FOREIGN KEY (DimChannelID) REFERENCES DimChannel (DimChannelID),
CONSTRAINT FK_FS_DimProduct FOREIGN KEY (DimProductID) REFERENCES DimProduct (DimProductID),
CONSTRAINT FK_FS_DimSegment FOREIGN KEY (DimSegmentID) REFERENCES DimSegment (DimSegmentID);

--Reseed an identity column--
DBCC CHECKIDENT('dbo.FactSales', RESEED, 0);
GO

--Load FactSales--
INSERT INTO dbo.FactSales

SELECT 
ISNULL(dcu.DimCustomerID, -1),
ISNULL(dst.DimStoreID, -1),
ISNULL(dr.DimResellerID, -1),
dch.DimChannelID,
dp.DimProductID,
CASE
          WHEN sh.CustomerID IS NULL AND sh.StoreID IS NOT NULL THEN dse_st.DimSegmentID
          WHEN sh.CustomerID IS NOT NULL AND sh.StoreID IS NULL THEN dse_cu.DimSegmentID
          ELSE -1
END,
dd.DimDateID,
sd.SalesQuantity,
sd.SalesAmount

FROM dbo.StageSalesDetail as sd
LEFT JOIN dbo.StageSalesHeader AS sh
 ON sd.SalesHeaderID = sh.SalesHeaderID
LEFT JOIN dbo.DimCustomer AS dcu
 ON sh.CustomerID = dcu.CustomerID
LEFT JOIN dbo.DimStore AS dst
 ON sh.StoreID = dst.StoreID
LEFT JOIN dbo.DimReseller AS dr
 ON sh.ResellerID = dr.ResellerID
LEFT JOIN dbo.DimChannel AS dch
 ON sh.ChannelID = dch.ChannelID
LEFT JOIN dbo.DimProduct AS dp
 ON sd.ProductID = dp.ProductID
LEFT JOIN dbo.StageCustomer AS cu
 ON sh.CustomerID = cu.CustomerID
LEFT JOIN dbo.DimSegment AS dse_cu
 ON cu.SubSegmentID = dse_cu.SubSegmentID
LEFT JOIN dbo.StageStore AS st
 ON sh.StoreID = st.StoreID
LEFT JOIN dbo.DimSegment AS dse_st
 ON st.SubSegmentID = dse_st.SubSegmentID
LEFT JOIN dbo.DimDate AS dd
 ON sh.Date = dd.FullDate

-----------------------------------FactTargetSalesQuantity-----------------------------------

--Empty FactTargetSalesQuantity--
DELETE dbo.FactTargetSalesQuantity;

--Add constraints back--
ALTER TABLE dbo.FactTargetSalesQuantity 
 ADD CONSTRAINT FK_FTSQ_DimProduct FOREIGN KEY (DimProductID) REFERENCES dbo.DimProduct (DimProductID);

--Reseed an identity column--
DBCC CHECKIDENT('dbo.FactTargetSalesQuantity', RESEED, 0);
GO

--Load FactTargetSalesQuantity--
INSERT INTO dbo.FactTargetSalesQuantity
SELECT dp.DimProductID, dd.DimDateID, 
CASE
        WHEN CAST(td2.Year AS INT) % 4 = 0 AND CAST(td2.Year AS INT) % 100 != 0 OR CAST(td2.Year AS INT) % 400 = 0 THEN td2.SalesQuantityTarget/366 
        ELSE td2.SalesQuantityTarget/365
END
FROM dbo.StageTargetData2 AS td2
LEFT JOIN dbo.DimProduct AS dp
 ON td2.ProductID =  dp.ProductID
LEFT JOIN dbo.DimDate AS dd
 ON td2.Year = dd.CalendarYear

-----------------------------------FactTargetSalesAmount-----------------------------------

--Empty FactTargetSalesAmount--  
DELETE dbo.FactTargetSalesAmount;

--Add constraints back--
ALTER TABLE dbo.FactTargetSalesAmount ADD
CONSTRAINT FK_FTSA_DimStore FOREIGN KEY (DimStoreID) REFERENCES dbo.DimStore (DimStoreID),
CONSTRAINT FK_FTSA_DimReseller FOREIGN KEY (DimResellerID) REFERENCES DimReseller (DimResellerID),
CONSTRAINT FK_FTSA_DimChannel FOREIGN KEY (DimChannelID) REFERENCES DimChannel (DimChannelID);
GO
 
--Handling abnormal values--
UPDATE dbo.StageTargetData1
SET TargetName = 'On-line'
WHERE TargetName = 'Online Sales';

UPDATE dbo.StageTargetData1
SET TargetName = 'Mississipi Distributors'
WHERE TargetName = 'Mississippi Distributors';
GO

--Reseed an identity column--
DBCC CHECKIDENT('dbo.FactTargetSalesAmount', RESEED, 0);
GO

--Load FactTargetSalesAmount--
INSERT INTO dbo.FactTargetSalesAmount
SELECT 
ISNULL(dst.DimStoreID, -1),
ISNULL(dr.DimResellerID, -1),
ISNULL(dc.DimChannelID, -1),
dd.DimDateID,
CASE
        WHEN CAST(td1.Year AS INT) % 4 = 0 AND CAST(td1.Year AS INT) % 100 != 0 OR CAST(td1.Year AS INT) % 400 = 0 THEN td1.TargetSalesAmount/366 
        ELSE td1.TargetSalesAmount /365
END
FROM dbo.StageTargetData1 AS td1
LEFT JOIN dbo.DimStore AS dst
ON SUBSTRING(td1.TargetName, 14, 16) = CAST(dst.StoreNumber AS NVARCHAR)
LEFT JOIN dbo.DimReseller AS dr
ON td1.TargetName = dr.ResellerName
LEFT JOIN dbo.DimChannel AS dc
ON td1.TargetName = dc.Channel
LEFT JOIN dbo.DimDate AS dd
ON td1.Year = dd.CalendarYear;
GO  

UPDATE dbo.FactTargetSalesAmount
 	SET DimChannelID = 1
 	WHERE DimStoreID IN (2, 3, 5 ,6);

UPDATE dbo.FactTargetSalesAmount
 	SET DimChannelID = 3
 	WHERE DimStoreID IN (1, 4);

UPDATE dbo.FactTargetSalesAmount
 	SET DimChannelID = 5
 	WHERE DimResellerID = 1;

UPDATE dbo.FactTargetSalesAmount
	SET DimChannelID = 4
 	WHERE DimResellerID = 2;
 