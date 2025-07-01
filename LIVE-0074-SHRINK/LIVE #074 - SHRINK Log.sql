/*********************************************
 Autor: Landry Duailibe
 
 LIVE #074
 Hands On: SHRINK do Arquivo de Log
**********************************************/
use master
go

/**************************
 Cria Banco HandsOn
***************************/
DROP DATABASE IF exists HandsOn
go
CREATE DATABASE HandsOn 

-- Altera Recovery Model
ALTER DATABASE HandsOn SET RECOVERY FULL
go

use HandsOn
go

--  Cria tabela 
DROP TABLE IF exists HandsOn.dbo.Cliente
go
CREATE TABLE HandsOn.dbo.Cliente ( 
Cliente_ID int not null identity CONSTRAINT pk_Cliente PRIMARY KEY,
Nome char(1200) not null,
Renda bigint null)
go

-- Backup FULL
BACKUP DATABASE HandsOn TO DISK = 'C:\_LIVE\Backup\HandsOn_Full.bak' WITH format, compression

/*******************************************
 Mostrar os Logs Virtuais e porção ativa
********************************************/
-- DBCC LOGINFO não documentado
DBCC LOGINFO ('HandsOn') 

-- Nova visão a partir do SQL Server 2016
SELECT * FROM sys.dm_db_log_info(db_id('HandsOn'))
/*
https://learn.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-log-info-transact-sql?view=sql-server-ver16

vlf_active (0 livre / 1 ativo)
vlf_status (0 livre / 1 inicializado mas sem uso / 2 em uso)
*/

-- Verifica Status do Log Reuse
SELECT name as Banco, log_reuse_wait_desc 
FROM sys.databases WHERE name = 'HandsOn'

-- Tamanho do arquivo de Log
SELECT db.[name] as Banco, mf.[name] Arquivo, (mf.size * 8) / 1024 as Tamanho_MB
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
WHERE mf.[type] = 1 and db.[name] = 'HandsOn'


/***********************************
 Carrega linhas na tabela
************************************/
set nocount on

INSERT HandsOn.dbo.Cliente (Nome,Renda) VALUES
('Bla Bla Bla...',12345),
('Bla Bla Bla...',12345),
('Bla Bla Bla...',12345),
('Bla Bla Bla...',12345),
('Bla Bla Bla...',12345)
go 50000


/**************************
 Análise Arquivo de Log
***************************/
SELECT * FROM sys.dm_db_log_info(db_id('HandsOn'))

-- Verifica Status do Log Reuse
SELECT name as Banco, log_reuse_wait_desc 
FROM sys.databases WHERE name = 'HandsOn'

-- Tamanho do arquivo de Log
SELECT db.[name] as Banco, mf.[name] Arquivo, (mf.size * 8) / 1024 as Tamanho_MB
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
WHERE mf.[type] = 1 and db.[name] = 'HandsOn'

-- Backup Log
BACKUP LOG HandsOn TO DISK = 'C:\_LIVE\Backup\HandsOn_01.trn' WITH NOINIT, COMPRESSION

use HandsOn
go
-- 1) Primeiro SHRINK
DBCC SHRINKFILE ('HandsOn_log',20)

-- 2) Backup Log
BACKUP LOG HandsOn TO DISK = 'C:\_LIVE\Backup\HandsOn_02.trn' WITH NOINIT, COMPRESSION

-- 3) Segundo SHRINK
DBCC SHRINKFILE ('HandsOn_log',20)

/*********************
 Remove o Banco
**********************/
use master
go
ALTER DATABASE HandsOn SET READ_ONLY WITH ROLLBACK IMMEDIATE
go
DROP DATABASE HandsOn
go
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = 'HandsOn'

