/*********************************************
 Autor: Landry Duailibe
 
 Hands On: Fun��es String cen�rios avan�ados
**********************************************/
use Aula
go

/*************************************************
 Concatenar linhas em uma �nica string
 - STUFF() com FOR XML PATH
**************************************************/

-- Tabela de exemplo
DROP TABLE IF exists dbo.Clientes
go
CREATE TABLE dbo.Clientes (Nome varchar(50))
go
INSERT Clientes VALUES ('Ana'), ('Carlos'), ('Fernanda'), ('Marcos')
go

-- Concatenar nomes separados por v�rgula
SELECT * FROM dbo.Clientes

SELECT stuff((SELECT ', ' + Nome FROM Clientes FOR XML PATH(''), 
TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as ListaClientes

-- A partir do SQL Server 2017
SELECT string_agg(Nome, ', ') as ListaClientes FROM Clientes


/*************************************************
 Extra��o do Dom�nio de e-mails
 - CHARINDEX() e SUBSTRING()
**************************************************/
SELECT Email,
substring(Email, charindex('@', Email) + 1, len(Email)) as Dominio
FROM Pessoas

/*************************************************
 Mascaramento de dados, �til para LGPD.
 - REPLICATE(), LEN() e LTRIM()
**************************************************/
SELECT NomeCompleto,
LEFT(ltrim(NomeCompleto), 1) + replicate('*', len(ltrim(NomeCompleto)) - 1) AS NomeCompleto_Mascarado
FROM Pessoas

/*************************************************
 Limpeza de Dados com Caracteres Ocultos
 - Tabula��o (CHAR(9))
 - Control (13) 
 - Line Feed (10)
**************************************************/

INSERT Pessoas VALUES
(6, 'Carla '+ char(9) +'Marques' , 'ana.paula@exemplo.com', 'PROD-001-AB'), -- Tabula��o
(7, 'Luana Salles'+ char(13) + char(10), 'ana.paula@exemplo.com', 'PROD-001-AB') -- Control + Line Feed
go

SELECT NomeCompleto, 
len(NomeCompleto) as Tamanho_Caracteres,
datalength(NomeCompleto) as Tamanho_Bytes,
replace(
replace(
replace(NomeCompleto, char(9), ''),  -- Remove TAB
char(13), ''), -- Remove Control
char(10), '')  -- Remove Line Feed
FROM Pessoas
