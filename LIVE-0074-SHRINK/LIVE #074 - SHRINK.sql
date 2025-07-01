/*********************************************
 Autor: Landry Duailibe
 
 LIVE #074
 Hands On: SHRINK
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

use HansOnDB
go

DROP TABLE IF exists dbo.Vendas
go
CREATE TABLE dbo.Vendas (
SalesOrderID int NOT NULL,
SalesOrderDetailID int NOT NULL,
CarrierTrackingNumber nvarchar(25) NULL,
OrderQty smallint NOT NULL,
ProductID int NOT NULL,
SpecialOfferID int NOT NULL,
UnitPrice money NOT NULL,
UnitPriceDiscount money NOT NULL,
LineTotal  AS (isnull((UnitPrice*((1.0)-UnitPriceDiscount))*OrderQty,(0.0))),
rowguid uniqueidentifier ROWGUIDCOL  NOT NULL,
ModifiedDate datetime NOT NULL)
go

INSERT dbo.Vendas
(SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate 
FROM AdventureWorks.Sales.SalesOrderDetail
go 10
/********************* Fim Prepara ************************/

SELECT count(*) FROM dbo.Vendas
-- 1213170

-- Exclui metade das linhas
DELETE FROM dbo.Vendas
WHERE SalesOrderDetailID % 2 = 0

SELECT
--fg.name AS [Filegroup Name],
mf.name AS [Logical File Name],
mf.physical_name AS [Physical File Name],
CONVERT(decimal(10,2), mf.size / 128.0) AS [Space Reserved (MB)],
CONVERT(decimal(10,2), FILEPROPERTY(mf.name, 'SpaceUsed') / 128.0) AS [Space Used (MB)]
FROM sys.master_files mf
LEFT JOIN sys.filegroups fg ON mf.data_space_id = fg.data_space_id
WHERE mf.database_id = DB_ID()
/*
Logical File Name	Physical File Name				Space Reserved (MB)	Space Used (MB)
HansOnDB			C:\MSSQL_Data\HansOnDB.mdf		136.00				100.00
HansOnDB_log		C:\MSSQL_Data\HansOnDB_log.ldf	392.00				100.77
*/

DBCC SHRINKDATABASE (HansOnDB)
GO


/*****************8
 Exclui Banco
*******************/
use master
go

ALTER DATABASE HansOnDB SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
go
DROP DATABASE HansOnDB
go
