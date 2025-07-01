/*********************************************
 Autor: Landry Duailibe
 
 LIVE #073
 Hands On: CTE x Tabela Temporária
**********************************************/
use master
go
CREATE DATABASE LiveDB
go
ALTER DATABASE LiveDB SET RECOVERY simple
go

use LiveDB
go


/*********************************
 Cria Tabelas para Hands On
**********************************/
set nocount on

-- SalesTerritory
DROP TABLE IF exists dbo.SalesTerritory
go
SELECT TerritoryID,[Name],CountryRegionCode,[Group]
INTO dbo.SalesTerritory
FROM AdventureWorks.Sales.SalesTerritory

-- Product
DROP TABLE IF exists dbo.Product
go
SELECT *
INTO dbo.Product
FROM AdventureWorks.Production.Product
go

-- ProductSubcategory
DROP TABLE IF exists dbo.ProductSubcategory
go
SELECT *
INTO dbo.ProductSubcategory
FROM AdventureWorks.Production.ProductSubcategory
go

-- Productcategory
DROP TABLE IF exists dbo.Productcategory
go
SELECT *
INTO dbo.Productcategory
FROM AdventureWorks.Production.Productcategory
go

-- Customer
DROP TABLE IF exists dbo.Customer
go
CREATE TABLE dbo.Customer (
CustomerID int not null CONSTRAINT pk_Customer PRIMARY KEY, 
Title nvarchar(8) null, 
FirstName nvarchar(50) null, 
MiddleName nvarchar(50) null, 
LastName nvarchar(50) null,
[Name] nvarchar(160) null,
TerritoryID int null) 
go

INSERT dbo.Customer (CustomerID, Title, FirstName, MiddleName, LastName, [Name],TerritoryID)
SELECT c.CustomerID, Title, FirstName, MiddleName, LastName, 
FirstName + isnull(' ' + MiddleName,'') + isnull(' ' + LastName,'') as [Name],
c.TerritoryID
FROM AdventureWorks.Sales.Customer c
JOIN AdventureWorks.Person.Person p on p.BusinessEntityID = c.PersonID
go

-- SalesOrderHeader
DROP TABLE IF exists dbo.SalesOrderHeader
go
CREATE TABLE dbo.SalesOrderHeader(
SalesOrderID int NOT NULL identity CONSTRAINT pk_SalesOrderHeader PRIMARY KEY,
OrderDate datetime NOT NULL,
Status tinyint NOT NULL,
OnlineOrderFlag bit NOT NULL,
SalesOrderNumber char(200) NOT NULL,
CustomerID int NOT NULL,
SalesPersonID int NULL,
TerritoryID int NULL,
SubTotal money NOT NULL,
TaxAmt money NOT NULL,
Freight money NOT NULL,
TotalDue money NOT NULL,
Comment nvarchar(128) NULL)
go

-- Alimenta tabela com 31.465.000 linhas
INSERT dbo.SalesOrderHeader (OrderDate, [Status], OnlineOrderFlag, SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID, SubTotal, TaxAmt, Freight, TotalDue, Comment)
SELECT OrderDate, Status, OnlineOrderFlag, 
SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID,  
SubTotal, TaxAmt, Freight, TotalDue, Comment
FROM AdventureWorks.Sales.SalesOrderHeader
go 500

-- Cria índices
CREATE INDEX ix_SalesOrderHeader_CustomerID
ON dbo.SalesOrderHeader (CustomerID)
INCLUDE (OrderDate,TotalDue)

/****************************** Leva 3 min *********************************/

set statistics io on

/*********************************************
 Tabela Temporária
**********************************************/
CREATE TABLE #Vendas (
Customer nvarchar(160),
Ano int,
Mes int,
Ranking int,
TotalVendas decimal(18, 2))

INSERT #Vendas 
SELECT b.Name as Customer, year(a.OrderDate) as Ano, month(a.OrderDate) as Mes,
ROW_NUMBER() OVER (PARTITION BY year(a.OrderDate), month(a.OrderDate) ORDER BY a.TotalDue DESC) as Ranking,
a.TotalDue as TotalVendas
FROM dbo.SalesOrderHeader a
JOIN dbo.Customer b ON b.CustomerID = a.CustomerID
JOIN dbo.SalesTerritory c ON c.TerritoryID = b.TerritoryID

SELECT Ano, Mes, Customer, TotalVendas
FROM #Vendas
WHERE Ranking = 1
--ORDER BY Ano, Mes

DROP TABLE IF exists #Vendas

/* 1 min 31 seg

Table 'SalesOrderHeader'. Scan count 5, logical reads 58945
Table 'Customer'. Scan count 5, logical reads 577
Table 'SalesTerritory'. Scan count 4, logical reads 1

Table '#Vendas_0000000D4D77'. Scan count 5, logical reads 119964

Total de I/O = 179.487 x 8 KB = 1.435.896 KB = 1.402 MB
*/


/************************************
 CTE
*************************************/
;WITH CTE_Venda as (
SELECT b.Name as Customer, year(a.OrderDate) as Ano, month(a.OrderDate) as Mes,
ROW_NUMBER() OVER (PARTITION BY year(a.OrderDate), month(a.OrderDate) ORDER BY a.TotalDue DESC) as Ranking,
a.TotalDue as TotalVendas
FROM dbo.SalesOrderHeader a
JOIN dbo.Customer b ON b.CustomerID = a.CustomerID
JOIN dbo.SalesTerritory c ON c.TerritoryID = b.TerritoryID)

SELECT Ano, Mes, Customer, TotalVendas
FROM CTE_Venda
WHERE Ranking = 1
ORDER BY Ano, Mes
/* 1 min 11 seg

Table 'SalesOrderHeader'. Scan count 5, logical reads 58937
Table 'Customer'. Scan count 5, logical reads 577
Table 'SalesTerritory'. Scan count 2, logical reads 1

Volume de I/O = 59.514 x 8 KB = 476.112 KB = 464 MB
*/

/************************************
 SubQuery
*************************************/
SELECT Ano, Mes, Customer, TotalVendas
FROM (SELECT b.Name as Customer, year(a.OrderDate) as Ano, month(a.OrderDate) as Mes,
ROW_NUMBER() OVER (PARTITION BY year(a.OrderDate), month(a.OrderDate) ORDER BY a.TotalDue DESC) as Ranking,
a.TotalDue as TotalVendas
FROM dbo.SalesOrderHeader a
JOIN dbo.Customer b ON b.CustomerID = a.CustomerID
JOIN dbo.SalesTerritory c ON c.TerritoryID = b.TerritoryID) a
WHERE Ranking = 1
ORDER BY Ano, Mes



/***********************
 Exclui Banco
************************/
use master
go

DROP DATABASE IF exists LiveDB

