/*********************************************
 Autor: Landry Duailibe
 
 LIVE #074
 Hands On: SHRINK e Fragmentação
**********************************************/
use master
go

/*****************************************
 Cria Banco e Tabela com volume de dados
******************************************/
DROP DATABASE IF exists HansOnDB
go
CREATE DATABASE HansOnDB
go
ALTER DATABASE HansOnDB SET RECOVERY simple
go

use HansOnDB
go

/******************* Prepara ambiente **********************/
-- Vendas
DROP TABLE IF exists dbo.Vendas
go
CREATE TABLE dbo.Vendas (
SalesOrderID int identity NOT NULL CONSTRAINT pk_Vendas PRIMARY KEY,
RevisionNumber tinyint NOT NULL,
OrderDate datetime NOT NULL,
DueDate datetime NOT NULL,
ShipDate datetime NULL,
Status tinyint NOT NULL,
SalesOrderNumber  AS (isnull(N'SO'+CONVERT(nvarchar(23),SalesOrderID),N'*** ERROR ***')),
CustomerID int NOT NULL,
SalesPersonID int NULL,
TerritoryID int NULL,
BillToAddressID int NOT NULL,
ShipToAddressID int NOT NULL,
ShipMethodID int NOT NULL,
CreditCardID int NULL,
CreditCardApprovalCode varchar(1000) NULL,
CurrencyRateID int NULL,
SubTotal money NOT NULL,
TaxAmt money NOT NULL,
Freight money NOT NULL,
TotalDue  AS (isnull((SubTotal+TaxAmt)+Freight,(0))),
Comment nvarchar(128) NULL,
rowguid uniqueidentifier ROWGUIDCOL  NOT NULL,
ModifiedDate datetime NOT NULL)
go

-- Vendas_Itens
DROP TABLE IF exists dbo.Vendas_Itens
go
CREATE TABLE dbo.Vendas_Itens (
Vendas_ID int not null identity CONSTRAINT pk_Vendas_Itens PRIMARY KEY,
SalesOrderID int NOT NULL,
SalesOrderDetailID int NOT NULL,
CarrierTrackingNumber varchar(1000) NULL,
OrderQty smallint NOT NULL,
ProductID int NOT NULL,
SpecialOfferID int NOT NULL,
UnitPrice money NOT NULL,
UnitPriceDiscount money NOT NULL,
LineTotal  AS (isnull((UnitPrice*((1.0)-UnitPriceDiscount))*OrderQty,(0.0))),
rowguid uniqueidentifier ROWGUIDCOL  NOT NULL,
ModifiedDate datetime NOT NULL)
go

-- Insert
INSERT dbo.Vendas
(RevisionNumber, OrderDate, DueDate, ShipDate, [Status], CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate)
SELECT RevisionNumber, OrderDate, DueDate, ShipDate, [Status], CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode + replicate('A',500), CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate
FROM AdventureWorks.Sales.SalesOrderHeader

INSERT dbo.Vendas_Itens
(SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber + replicate('A',500), OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate 
FROM AdventureWorks.Sales.SalesOrderDetail
go 60
/********************* Fim Prepara ************************/


SELECT count(*) FROM dbo.Vendas -- 1.887.900
SELECT count(*) FROM dbo.Vendas_Itens -- 7.279.020

-- Quantidade de Linhas e Data Pages
SELECT o.name as Tabela, rows as QtdLinhas, 
data_pages as Paginas8k,
(data_pages * 8) / 1024 as Tamanho_MB 
FROM sys.partitions p 
JOIN sys.allocation_units a ON p.hobt_id = a.container_id
JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.name in ('Vendas','Vendas_Itens') 
and index_id < 2
/*
Tabela			QtdLinhas	Paginas8k	Tamanho_MB
Vendas			1887900		151681		1185
Vendas_Itens	7279020		313471		2448
*/
/*******************************************
 sys.dm_db_index_physical_stats
 - Analisa Fragmentação
 - index_level: zero = nível folha

 https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql?view=sql-server-ver17
********************************************/
SELECT
OBJECT_NAME(ips.object_id) AS Tabela,
i.name AS Indice,
index_level as Nivel_Indice,
ips.index_type_desc,
ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('dbo.Vendas'), NULL, NULL, 'DETAILED') AS ips
JOIN sys.indexes AS i   ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE index_level = 0

UNION ALL

SELECT
OBJECT_NAME(ips.object_id) AS Tabela,
i.name AS Indice,
index_level as Nivel_Indice,
ips.index_type_desc,
ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('dbo.Vendas_Itens'), NULL, NULL, 'DETAILED') AS ips
JOIN sys.indexes AS i   ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE index_level = 0
/*
Tabela			Indice			Nivel_Indice	index_type_desc		avg_fragmentation_in_percent
Vendas			pk_Vendas		0				CLUSTERED INDEX		0.0125262887243623
Vendas_Itens	pk_Vendas_Itens	0				CLUSTERED INDEX		0.0220116055392684
*/

/*******************************
 Atividade gera fragmentação
********************************/
UPDATE dbo.Vendas SET CreditCardApprovalCode = CreditCardApprovalCode + replicate('A',100)
WHERE SalesOrderID >= 1000000 and SalesOrderID < 2000000

UPDATE dbo.Vendas_Itens SET CarrierTrackingNumber = CarrierTrackingNumber + replicate('A',100)
WHERE Vendas_ID >= 3000000 and Vendas_ID < 4000000
go

DELETE top(100000) FROM dbo.Vendas
WHERE 1=1
--and SalesOrderID % 2 = 0 
and SalesOrderID >= 0 and SalesOrderID < 500000

DELETE top(200000) FROM dbo.Vendas_Itens
WHERE 1=1
--and Vendas_ID % 2 = 0
and Vendas_ID >= 1000000 and Vendas_ID < 2000000

INSERT dbo.Vendas
(RevisionNumber, OrderDate, DueDate, ShipDate, [Status], CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate)
SELECT RevisionNumber, OrderDate, DueDate, ShipDate, [Status], CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate
FROM AdventureWorks.Sales.SalesOrderHeader

INSERT dbo.Vendas_Itens
(SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate 
FROM AdventureWorks.Sales.SalesOrderDetail
go 5
/*
Tabela			Indice			Nivel_Indice	index_type_desc		avg_fragmentation_in_percent
Vendas			pk_Vendas		0				CLUSTERED INDEX		76.3512894446091
Vendas_Itens	pk_Vendas_Itens	0				CLUSTERED INDEX		24.2953954077985
*/

-- Executa SHRINK gerando fragmentação
DBCC SHRINKFILE (HansOnDB,1)
/*
Tabela			Indice			Nivel_Indice	index_type_desc		avg_fragmentation_in_percent
Vendas			pk_Vendas		0				CLUSTERED INDEX		77.2157697593576
Vendas_Itens	pk_Vendas_Itens	0				CLUSTERED INDEX		25.3946770621857
*/


ALTER INDEX pk_Vendas ON dbo.Vendas REBUILD
ALTER INDEX pk_Vendas_Itens ON dbo.Vendas_Itens REBUILD
/*
Tabela			Indice			Nivel_Indice	index_type_desc		avg_fragmentation_in_percent
Vendas			pk_Vendas		0				CLUSTERED INDEX		0.01
Vendas_Itens	pk_Vendas_Itens	0				CLUSTERED INDEX		0.01
*/

/******************
 Exclui Banco
*******************/
use master
go

ALTER DATABASE HansOnDB SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
go
DROP DATABASE HansOnDB
go