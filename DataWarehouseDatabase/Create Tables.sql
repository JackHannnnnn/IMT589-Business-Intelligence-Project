USE jack1206DW;

DROP TABLE FactTargetSalesAmount, FactTargetSalesQuantity, FactSales;
DROP TABLE DimProduct, DimSegment, DimChannel;
DROP TABLE DimStore, DimReseller, DimCustomer, DimGeography;

--Create Dimension Tables--
CREATE TABLE DimProduct (
		DimProductID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimProduct PRIMARY KEY,
		Product NVARCHAR(50) NOT NULL,
		ProductID INT NOT NULL,
		ProductType NVARCHAR(50) NOT NULL,
		ProductTypeID INT NOT NULL,
		ProductCategory NVARCHAR(50) NOT NULL,
		ProductCategoryID INT NOT NULL,
		Color NVARCHAR(50) NULL,
		Style NVARCHAR(50) NULL,
		UnitofMeasure NVARCHAR(50) NOT NULL,
		UnitofMeasureID INT NOT NULL,
		Weight DECIMAL(18,4) NOT NULL,
		Price DECIMAL(18,2) NOT NULL,
		Cost DECIMAL(18,2) NOT NULL,
		WholesalePrice DECIMAL(18,2) NOT NULL
		);

CREATE TABLE DimChannel (
		DimChannelID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimChannel PRIMARY KEY,
		ChannelCategory NVARCHAR(50) NOT NULL,
		ChannelCategoryID INT NOT NULL,
		Channel NVARCHAR(50) NOT NULL,
		ChannelID INT NOT NULL
		);

CREATE TABLE DimSegment (
		DimSegmentID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimSegment PRIMARY KEY,
		Segment NVARCHAR(50) NOT NULL,
		SegmentID INT NOT NULL,
		SubSegment NVARCHAR(50) NOT NULL,
		SubSegmentID INT NOT NULL
		);
--Create DimGeography Table Before DimCustomer, DimStore, DimReseller Tables
CREATE TABLE DimGeography (
		DimGeographyID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimGeography PRIMARY KEY,
		Address NVARCHAR(255) NOT NULL,
		City NVARCHAR(255) NOT NULL,
		StateProvince NVARCHAR(255) NOT NULL,
		Country NVARCHAR(255) NOT NULL,
		PostalCode NVARCHAR(255) NOT NULL
		);

CREATE TABLE DimCustomer (
		DimCustomerID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimCustomer PRIMARY KEY,
		CustomerID UNIQUEIDENTIFIER NOT NULL,
		DimGeographyID INT NOT NULL CONSTRAINT FK_DimCustomer FOREIGN KEY REFERENCES DimGeography (DimGeographyID),
		FirstName NVARCHAR(255) NOT NULL,
		LastName NVARCHAR(255) NOT NULL,
		Gender NVARCHAR(10) NOT NULL,
		EmailAddress NVARCHAR(255) NOT NULL,
		PhoneNumber NVARCHAR(20) NOT NULL
		);

CREATE TABLE DimReseller (
		DimResellerID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimReseller PRIMARY KEY,
		DimGeographyID INT NOT NULL CONSTRAINT FK_DimReseller FOREIGN KEY REFERENCES DimGeography (DimGeographyID),
		ResellerID UNIQUEIDENTIFIER NOT NULL,
		ResellerName NVARCHAR(255) NOT NULL,
		Contact NVARCHAR(255) NOT NULL,
		EmailAddress NVARCHAR(255) NOT NULL,
		PhoneNumber NVARCHAR(20) NOT NULL
		);

CREATE TABLE DimStore (
		DimStoreID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimStore PRIMARY KEY,
		DimGeographyID INT NOT NULL CONSTRAINT FK_DimStore FOREIGN KEY REFERENCES DimGeography (DimGeographyID),
		StoreID INT NOT NULL,
		StoreNumber INT NOT NULL,
		StoreManager NVARCHAR(255) NOT NULL,
		PhoneNumber NVARCHAR(20) NOT NULL
		);

-- Create Fact Tables--
CREATE TABLE FactSales (
		FactSalesID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FactSales PRIMARY KEY,
		DimCustomerID INT NOT NULL CONSTRAINT FK_FS_DimCustomer FOREIGN KEY REFERENCES DimCustomer (DimCustomerID),
		DimStoreID INT NOT NULL CONSTRAINT FK_FS_DimStore FOREIGN KEY REFERENCES DimStore (DimStoreID),
		DimResellerID INT NOT NULL CONSTRAINT FK_FS_DimReseller FOREIGN KEY REFERENCES DimReseller (DimResellerID),
		DimChannelID INT NOT NULL CONSTRAINT FK_FS_DimChannel FOREIGN KEY REFERENCES DimChannel (DimChannelID),
		DimProductID INT NOT NULL CONSTRAINT FK_FS_DimProduct FOREIGN KEY REFERENCES DimProduct (DimProductID),
		DimSegmentID INT NOT NULL CONSTRAINT FK_FS_DimSegment FOREIGN KEY REFERENCES DimSegment (DimSegmentID),
		DimDateID INT NOT NULL CONSTRAINT FK_FS_DimDate FOREIGN KEY REFERENCES DimDate (DimDateID),
		SalesQuantity INT NOT NULL,
		SalesAmount DECIMAL(18,2) NOT NULL
		);

CREATE TABLE FactTargetSalesQuantity (
		FactTargetSalesQuantityID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FTSQ PRIMARY KEY,
		DimProductID INT NOT NULL CONSTRAINT FK_FTSQ_DimProduct FOREIGN KEY REFERENCES DimProduct (DimProductID),
		DimDateID INT NOT NULL CONSTRAINT FK_FTSQ_DimDate FOREIGN KEY REFERENCES DimDate (DimDateID),
		TargetSalesQuantity INT NOT NULL
		);

CREATE TABLE FactTargetSalesAmount (
		FactTargetSalesAmountID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FTSA PRIMARY KEY,
		DimStoreID INT NOT NULL CONSTRAINT FK_FTSA_DimStore FOREIGN KEY REFERENCES DimStore (DimStoreID),
		DimResellerID INT NOT NULL CONSTRAINT FK_FTSA_DimReseller FOREIGN KEY REFERENCES DimReseller (DimResellerID),
		DimChannelID INT NOT NULL CONSTRAINT FK_FTSA_DimChannel FOREIGN KEY REFERENCES DimChannel (DimChannelID),
		DimDateID INT NOT NULL CONSTRAINT FK_FTSA_DimDate FOREIGN KEY REFERENCES DimDate (DimDateID),
		TargetSalesAmount DECIMAL(18,2) NOT NULL
		);

