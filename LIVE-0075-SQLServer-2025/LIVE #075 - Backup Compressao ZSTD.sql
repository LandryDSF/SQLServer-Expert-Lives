/**********************************************
 Autor: Landry Duailibe

 LIVE #075 - SQL Server 2025 CTP
**********************************************/
use master
go

BACKUP DATABASE Northwind
TO DISK = N'C:\LIVES\Backup\Northwind.bak'
WITH FORMAT,COMPRESSION

BACKUP DATABASE Northwind
TO DISK = N'C:\LIVES\Backup\Northwind_zstd.bak'
WITH COMPRESSION (ALGORITHM = ZSTD)

/*****************************
 WideWorldImporters Grande - 5GB
******************************/ 
BACKUP DATABASE WideWorldImporters
TO DISK = N'C:\LIVES\Backup\WideWorldImporters.bak'
WITH FORMAT,COMPRESSION,STATS=5
-- Tempo 00:09

BACKUP DATABASE WideWorldImporters
TO DISK = N'C:\LIVES\Backup\WideWorldImporters_zstd.bak'
WITH COMPRESSION (ALGORITHM = ZSTD),STATS=5
-- Tempo 00:06

/*****************************
 AdventureWorks Grande - 5GB
******************************/ 
BACKUP DATABASE AdventureWorksGR
TO DISK = N'C:\LIVES\Backup\AdventureWorksGR.bak'
WITH FORMAT,COMPRESSION,STATS=5
-- Tempo 01:14

BACKUP DATABASE AdventureWorksGR
TO DISK = N'C:\LIVES\Backup\AdventureWorksGR_zstd.bak'
WITH COMPRESSION (ALGORITHM = ZSTD),STATS=5
-- Tempo 01:12

