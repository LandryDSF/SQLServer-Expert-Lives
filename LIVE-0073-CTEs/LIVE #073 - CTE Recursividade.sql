/*********************************************
 Autor: Landry Duailibe
 
 LIVE #073
 Hands On: CTE e Recursividade
**********************************************/
use Aula
go

/****************************
 Cria Tabela Funcionario
*****************************/
DROP TABLE IF exists Funcionario
go

CREATE TABLE Funcionario (
PK int, 
Nome Varchar(50), 
Cargo int, 
Chefe int, 
Salario decimal(10,2))
go

-- Presidente
INSERT Funcionario VALUES (1,'Fernando',1,NULL,25000.00)
-- Diretor
INSERT Funcionario VALUES (2,'Ana Maria',2,1,15000.00)
INSERT Funcionario VALUES (3,'Paula',2,1,14000.00)
-- Gerente
INSERT Funcionario VALUES (4,'Pedro',3,2,7000.00)
INSERT Funcionario VALUES (5,'Marta',3,2,7000.00)
INSERT Funcionario VALUES (6,'Luana',3,3,6500.00)
INSERT Funcionario VALUES (7,'Erick',3,3,6500.00)
-- Supervisor
INSERT Funcionario VALUES (8,'Fernanda',4,4,3200.00)
INSERT Funcionario VALUES (9,'Marcelo',4,5,3400.00)
INSERT Funcionario VALUES (10,'Joaquim',4,6,3000.00)
INSERT Funcionario VALUES (11,'Manoel',4,7,2900.00)
go
/******************** FIM ********************/



/*******************************
 Cursor
********************************/
SELECT PK, Nome, Chefe FROM Funcionario ORDER BY PK

DECLARE @FuncionarioAtual int = 8
DECLARE @Chefe int

CREATE TABLE #Chefes (
PK INT,
Nome VARCHAR(50),
Cargo INT,
Salario DECIMAL(10,2))

WHILE @FuncionarioAtual is not null
BEGIN
    -- Busca o chefe imediato
    SELECT @Chefe = Chefe
    FROM Funcionario WHERE PK = @FuncionarioAtual

    -- Insere o chefe na tabela de resultados
    IF @Chefe IS NOT NULL
    BEGIN
        INSERT INTO #Chefes (PK, Nome, Cargo, Salario)
        SELECT PK, Nome, Cargo, Salario
        FROM Funcionario WHERE PK = @Chefe
    END

    -- Sobe na hierarquia
    SET @FuncionarioAtual = @Chefe
END

-- Resultado final
SELECT * FROM #Chefes
DROP TABLE #Chefes
go

/*********************
 CTE
**********************/
SELECT PK, Nome, Chefe FROM Funcionario ORDER BY PK

DECLARE @FuncionarioAtual int = 8

;WITH HierarquiaChefes AS (
-- Parte âncora: começa com a Fernanda
SELECT PK,Nome,Cargo,Chefe,Salario,0 AS Nivel
FROM Funcionario WHERE PK = @FuncionarioAtual

UNION ALL

-- Parte recursiva: sobe na hierarquia
SELECT f.PK,f.Nome,f.Cargo,f.Chefe,f.Salario,h.Nivel + 1
FROM Funcionario f
JOIN HierarquiaChefes h ON f.PK = h.Chefe)

-- Pega só os chefes (excluindo Fernanda)
SELECT PK,Nome,Cargo,Salario,Nivel
FROM HierarquiaChefes
WHERE Nivel > 0
ORDER BY Nivel
go


/************************
 Exclui tabela
*************************/
DROP TABLE IF exists Funcionario
go