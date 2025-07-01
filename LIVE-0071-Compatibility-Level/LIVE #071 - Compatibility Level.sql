/*********************************************
 Autor: Landry Duailibe
 
 LIVE #071
 Hands On: Compatibility Level
**********************************************/
use master
go

CREATE DATABASE HandsOn
go


SELECT name as Banco,collation_name as Collation,
CASE compatibility_level
WHEN 80 THEN 'SQL2000'
WHEN 90 THEN 'SQL2005'
WHEN 100 THEN 'SQL2008' 
WHEN 110 THEN 'SQL2012'
WHEN 120 THEN 'SQL2014' 
WHEN 130 THEN 'SQL2016'
WHEN 140 THEN 'SQL2017'
WHEN 150 THEN 'SQL2019'
WHEN 160 THEN 'SQL2022'
ELSE ltrim(str(compatibility_level)) END as VersaoSQL,
recovery_model_desc as RecoveryModel,
page_verify_option_desc as PageVerify,
case when is_auto_shrink_on = 1 then 'ON' else 'OFF' end as Auto_Shrink,
case when is_auto_close_on = 1 then 'ON' else 'OFF' end as Auto_Close

FROM master.sys.databases
WHERE database_id > 4
ORDER BY Banco

-- Altera Compatibilidade
ALTER DATABASE HandsOn SET COMPATIBILITY_LEVEL = 100 -- SQL Server 2008
ALTER DATABASE HandsOn SET COMPATIBILITY_LEVEL = 160 -- SQL Server 2022

SELECT [name] as Banco, compatibility_level FROM sys.databases WHERE [name] = 'HandsOn'

-- Build
SELECT @@VERSION

/*
Microsoft SQL Server 2022 (RTM-CU18) (KB5050771) - 16.0.4185.3 (X64)   Feb 28 2025 18:24:49   
Copyright (C) 2022 Microsoft Corporation  Developer Edition (64-bit) on 
Windows Server 2022 Standard 10.0 <X64> (Build 20348: ) (Hypervisor) 
*/