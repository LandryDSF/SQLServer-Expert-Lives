use HandsOn
go

/**************************
 Cria tabela
***************************/
IF object_id('dbo.Customer') is not null
   DROP TABLE dbo.Customer

SELECT c.CustomerID as CustomerID,Title,FirstName,MiddleName,Lastname,CompanyName,SalesPerson,
EmailAddress,'Rio de Janeiro' as City, dateadd(d,-CustomerID,getdate()) DataCadastro 
INTO dbo.Customer
FROM AdventureWorksLT.SalesLT.Customer c 

SET IDENTITY_INSERT dbo.Customer ON
DECLARE @i int = 1000 

WHILE @i < 280000 BEGIN
	INSERT dbo.Customer (CustomerID,Title,FirstName,MiddleName,Lastname,CompanyName,SalesPerson,EmailAddress,City,DataCadastro)
	SELECT c.CustomerID + @i as CustomerID,Title,FirstName,MiddleName,Lastname,CompanyName,SalesPerson,
	EmailAddress,'Rio de Janeiro' as City, dateadd(d,-CustomerID,getdate()) DataCadastro 
	FROM AdventureWorksLT.SalesLT.Customer c 
	WHERE FirstName not like 'O%' and CustomerID < 1000

	SET @i = @i + 1000
END
SET IDENTITY_INSERT dbo.Customer OFF
go
/***************** Fim cria tabela ***************************/

SELECT * FROM dbo.Customer
SELECT count(*) FROM dbo.Customer -- 122.770 linhas

SELECT distinct City FROM dbo.Customer
-- "Rio de Janeiro" em todas as linhas 

-- Altera valor da coluna "City" para uma linha
UPDATE dbo.Customer SET City = 'São Paulo' WHERE CustomerID = 1

-- Valores na coluna "City"
SELECT City, count(*) as QtdLinhas 
FROM dbo.Customer
GROUP BY City
ORDER BY City
/*
Rio de Janeiro	122769
São Paulo		1
*/

-- Cria índice na coluna "City"
CREATE INDEX ix_Customer_City ON dbo.Customer (City)

-- Habilita estatísticas de IO
set statistics io on
-- Habilitar plano de execução gráfico no menu "Query"

SELECT *
FROM dbo.Customer --with(index(ix_Customer_City))
WHERE City = 'Rio de Janeiro'
/* Table Scan
Table 'Customer'. Scan count 1, logical reads 3442
Total de IO: 3442 x 8kb = 27.536 Kb = 26,89 MB
*/

SELECT *
FROM dbo.Customer
WHERE City = 'São Paulo'
/* Index Seek + Bookmark Lookup
Table 'Customer'. Scan count 1, logical reads 4
*/


SELECT rows as QtdLinhas, data_pages Paginas8k 
FROM sys.partitions p join sys.allocation_units a ON p.hobt_id = a.container_id
WHERE p.[object_id] = object_id('dbo.Customer') and index_id < 2
/*
QtdLinhas	Paginas8k
122770		3442
*/

DBCC SHOW_STATISTICS ('dbo.Customer', ix_Customer_City)
-- https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-show-statistics-transact-sql?view=sql-server-ver16

/*************************************************
 Parameter Sniffing (cheirar): Stored Procedure
**************************************************/
go
CREATE or ALTER PROCEDURE spu_CustomerCity
@City varchar(14)
--WITH RECOMPILE
as  
SELECT * FROM dbo.Customer WHERE City = @City
go

SELECT [name] as Banco, compatibility_level FROM sys.databases WHERE [name] = 'HandsOn'

ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150 -- SQL Server 2019
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 160 -- SQL Server 2022

/***********************************************************
 - Parameter Sniffing: Stored Procedure
************************************************************/
EXEC spu_CustomerCity 'Rio de Janeiro' --with RECOMPILE
-- Plano ideal "Table Scan": Table 'Customer'. Scan count 1, logical reads 3442

EXEC spu_CustomerCity 'São Paulo' -- with RECOMPILE
-- Plano ideal "Index Seek + Bookmark Loopup": Table 'Customer'. Scan count 1, logical reads 4



/***************
 Exclui tabela
****************/
DROP PROCEDURE spu_CustomerCity
DROP TABLE dbo.Customer

