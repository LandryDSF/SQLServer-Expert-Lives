/*********************************************
 Autor: Landry Duailibe
 
 Hands On: Funções que manipulam Strings
**********************************************/
use Aula 
go


DROP TABLE IF exists dbo.Pessoas
go
CREATE TABLE dbo.Pessoas (
Pessoas_ID int not null CONSTRAINT pk_Pessoas PRIMARY KEY,
NomeCompleto varchar(100),
Email varchar(100),
CodigoProduto varchar(20))
go

INSERT Pessoas VALUES
(1, 'Ana Paula Mendes', 'ana.paula@exemplo.com', 'PROD-001-AB'),
(2, 'Carlos Silva', 'carlos@empresa.org', 'PROD-002-CD'),
(3, '  Fernanda Rocha  ', 'fernanda_rocha@teste.net', 'PROD-003-EF'),
(4, 'Paulo Almeira', 'paulo_a-xpto.com', 'PROD-004-AC'),
(5, 'erick vieira', 'erick-v@b2b-com', 'PROD-005-EV')

-- len() e datalength()
SELECT NomeCompleto,
len(NomeCompleto) as TamanhoLEN,
datalength(NomeCompleto) as TamanhoBytes
FROM dbo.Pessoas

/*****************************************************
 left() e right() aparecem em "cinza" pois são funções 
 built-in mas não são palavras reservadas.

 Palavras reservadas como SELECT, FROM e algumas
 funções aparecem em "rosa".
******************************************************/
SELECT CodigoProduto,
left(CodigoProduto, 4) as Prefixo,
right(CodigoProduto, 2) as Sufixo,
substring(CodigoProduto,6,3) as Meio
FROM dbo.Pessoas

-- charindex
SELECT Email,
charindex('@', Email) as [Posicao_@]
FROM dbo.Pessoas

-- patindex
SELECT Email,
patindex('%@%.%', Email) as EmailValido
FROM dbo.Pessoas

-- replace() e replicate(), 
SELECT NomeCompleto,
replace(NomeCompleto, 'a', '*') as NomeAlterado,
NomeCompleto + replicate('-',5) as TracosNoFinal
FROM dbo.Pessoas

-- stuff()
SELECT CodigoProduto,
stuff(CodigoProduto, 6,3,'123') as NomeAlterado
FROM dbo.Pessoas

-- ltrim(), rtrim() e trim()
SELECT NomeCompleto,
ltrim(NomeCompleto) as SemEspaco_Esq,
rtrim(NomeCompleto) as SemEspaco_Dir,
trim(NomeCompleto) as SemEspaco_DirEsq, -- A partir do SQL Server 2017
ltrim(rtrim(NomeCompleto)) as SemEspaco_DirEsq_Old -- Antes do SQL Server 2017
FROM dbo.Pessoas

-- upper() e lower()
SELECT 
NomeCompleto,
upper(NomeCompleto) as NomeMaiusculo,
lower(NomeCompleto) as NomeMinusculo
FROM dbo.Pessoas

/********************************************************
 Nativamente, o SQL Server não possui uma função pronta
 para colocar a primeira letra de cada palavra em
 maiúsculo, mas podemos criar uma função para isso.
*********************************************************/
go
CREATE or ALTER FUNCTION dbo.Capitalizar(@texto VARCHAR(4000))
RETURNS VARCHAR(4000)
as
BEGIN
    DECLARE @saida VARCHAR(4000) = LOWER(@texto)
    DECLARE @pos INT = 1

    WHILE @pos <= LEN(@saida)
    BEGIN
        IF @pos = 1 OR SUBSTRING(@saida, @pos - 1, 1) = ' '
            SET @saida = STUFF(@saida, @pos, 1, UPPER(SUBSTRING(@saida, @pos, 1)))
        SET @pos += 1
    END

    RETURN @saida
END
go

SELECT NomeCompleto, dbo.Capitalizar(NomeCompleto) as Capitalizar
FROM dbo.Pessoas
