/*********************************************
 Autor: Landry Duailibe
 
 LIVE #072
 Hands On: Consultas remotas
**********************************************/
use master
go

/*****************************
 Habilita consultas Ad hoc
******************************/
EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE

/********************
 OPENROWSET
*********************/
SELECT *
FROM OPENROWSET('SQLNCLI11', 
'Server=SRVSQL2019;Trusted_Connection=yes;',
'SELECT * FROM AdventureWorks.Sales.SalesOrderHeader')

/********************
 OPENDATASOURCE
*********************/
SELECT * FROM 
OPENDATASOURCE('SQLNCLI11','Data Source=SRVSQL2019;Integrated Security=SSPI').AdventureWorks.Sales.SalesOrderHeader

/************************
 JOIN com Tabela local
*************************/

-- OPENROWSET
SELECT b.Name as Territory, sum(a.TotalDue) as ValTotal
FROM OPENROWSET('SQLNCLI11', 
'Server=SRVSQL2019;Trusted_Connection=yes;',
'SELECT * FROM AdventureWorks.Sales.SalesOrderHeader') a
JOIN AdventureWorks.Sales.SalesTerritory b on b.TerritoryID = a.TerritoryID
GROUP BY b.Name
ORDER BY b.Name

-- OPENDATASOURCE
SELECT b.Name as Territory, sum(a.TotalDue) as ValTotal FROM 
OPENDATASOURCE('SQLNCLI11','Data Source=SRVSQL2019;Integrated Security=SSPI').AdventureWorks.Sales.SalesOrderHeader a
JOIN AdventureWorks.Sales.SalesTerritory b on b.TerritoryID = a.TerritoryID
GROUP BY b.Name
ORDER BY b.Name

