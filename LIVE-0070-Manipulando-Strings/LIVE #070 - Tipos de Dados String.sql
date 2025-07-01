/*********************************************
 Autor: Landry Duailibe
 
 Hands On: Tipos de Dados Strings
**********************************************/
use Aula 
go

DROP TABLE IF exists dbo.TesteTiposString
go
CREATE TABLE dbo.TesteTiposString (
TextoChar char(20),
TextoVarchar varchar(20),
TextoNChar nchar(20),
TextoNVarchar nvarchar(20),
TextoText text,
TextoNText ntext)
go

INSERT dbo.TesteTiposString
VALUES (
 'Jo�o    ',               -- CHAR
 'Jo�o    ',               -- VARCHAR
N'Jo�o    ',              -- NCHAR
N'Jo�o    ',              -- NVARCHAR
 'Jo�o    ',               -- TEXT
N'Jo�o    '               -- NTEXT
)
go

SELECT 
TextoChar, 
TextoVarchar, 
TextoNChar, 
TextoNVarchar,
TextoText, 
TextoNText
FROM TesteTiposString

-- Isso d� erro com TEXT e NTEXT
SELECT datalength(TextoChar) as [Char], datalength(TextoVarchar) as [Varchar],
datalength(TextoNChar) as [NChar], datalength(TextoNVarchar) as [NVarchar] ,
datalength(TextoText) as [Text], datalength(TextoNText) as [NText] 
FROM TesteTiposString


