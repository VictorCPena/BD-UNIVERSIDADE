CREATE TABLE departamentos (
  id INT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  sigla VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE professores (
  id INT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  email VARCHAR(50) UNIQUE NOT NULL,
  departamento_id INT NOT NULL,
  FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

CREATE TABLE cursos (
  id INT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  departamento_id INT NOT NULL,
  FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

CREATE TABLE disciplinas (
  id INT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  creditos INT NOT NULL,
  curso_id INT NOT NULL,
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

CREATE TABLE alunos (
  id INT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  email VARCHAR(50) UNIQUE NOT NULL,
  curso_id INT NOT NULL,
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

CREATE TABLE matriculas (
  id INT PRIMARY KEY,
  aluno_id INT NOT NULL,
  disciplina_id INT NOT NULL,
  nota INT CHECK (nota >= 1 AND nota <= 10),
  FOREIGN KEY (aluno_id) REFERENCES alunos(id),
  FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id)
);

CREATE TABLE turmas (
  id INT PRIMARY KEY,
  disciplina_id INT NOT NULL,
  professor_id INT NOT NULL,
  turno VARCHAR(10) NOT NULL,
  sala VARCHAR(10) NOT NULL,
  FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id),
  FOREIGN KEY (professor_id) REFERENCES professores(id)
);

-- Trigger para impedir a remo��o de disciplinas que possuem matr�culas associadas

CREATE OR ALTER TRIGGER impedir_remocao_disciplina
ON disciplinas
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM matriculas WHERE disciplina_id IN (SELECT id FROM DELETED))
    BEGIN
        RAISERROR('Esta disciplina possui matr�culas associadas e n�o pode ser removida.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM disciplinas WHERE id IN (SELECT id FROM DELETED);
    END
END;
GO

-- Trigger para impedir a remo��o de departamentos com cursos associados

CREATE OR ALTER TRIGGER impedir_remocao_departamento
ON departamentos
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM cursos WHERE departamento_id IN (SELECT id FROM DELETED))
    BEGIN
        RAISERROR('Este departamento possui cursos associados e n�o pode ser removido.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM departamentos WHERE id IN (SELECT id FROM DELETED);
    END
END;
GO

-- Trigger para limitar o n�mero de turmas atribu�das a um professor

CREATE OR ALTER TRIGGER limitar_numero_turmas_professor
ON turmas
AFTER INSERT
AS
BEGIN
    DECLARE @professor_id INT;
    DECLARE @numero_turmas INT;
    DECLARE @limite_turmas INT = 5; -- limite de 5 turmas por professor
    
    SELECT @professor_id = professor_id FROM INSERTED;
    SELECT @numero_turmas = COUNT(*) FROM turmas WHERE professor_id = @professor_id;
    
    IF @numero_turmas > @limite_turmas
    BEGIN
        RAISERROR('O professor j� est� atribu�do a %d turmas, que � o limite m�ximo permitido.', 16, 1, @numero_turmas);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- Inserindo Dados

INSERT INTO departamentos (id, nome, sigla)
VALUES (1, 'Departamento de Ci�ncia da Computa��o', 'DCC'),
       (2, 'Departamento de Engenharia El�trica', 'DEE'),
       (3, 'Departamento de Matem�tica', 'DM'),
	   (4, 'Departamento de F�sica', 'DF'),
       (5, 'Departamento de Biologia', 'DB'),
       (6, 'Departamento de Psicologia', 'DP');


INSERT INTO professores (id, nome, email, departamento_id)
VALUES (1, 'Jo�o da Silva', 'joao.silva@dcc.ufmg.br', 1),
       (2, 'Maria das Dores', 'maria.dores@dee.ufmg.br', 2),
       (3, 'Jos� Pereira', 'jose.pereira@dm.ufmg.br', 3),
	   (4, 'Paulo Roberto', 'paulo.roberto@df.ufmg.br', 4),
       (5, 'Ana Paula', 'ana.paula@db.ufmg.br', 5),
       (6, 'Maria Clara', 'maria.clara@dp.ufmg.br', 6);



INSERT INTO cursos (id, nome, departamento_id)
VALUES (1, 'Bacharelado em Ci�ncia da Computa��o', 1),
       (2, 'Bacharelado em Engenharia El�trica', 2),
       (3, 'Licenciatura em Matem�tica', 3),
	   (4, 'Licenciatura em F�sica', 4),
       (5, 'Bacharelado em Biologia', 5),
       (6, 'Bacharelado em Psicologia', 6);


INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (1, 'Introdu��o � Programa��o', 'DCC101', 4, 1),
       (2, 'Circuitos El�tricos', 'DEE201', 4, 2),
       (3, 'C�lculo I', 'DM101', 4, 3),
	   (4, 'F�sica Qu�ntica', 'DF101', 4, 4),
       (5, 'Biologia Molecular', 'DB201', 4, 5),
       (6, 'Psicologia Social', 'DP301', 4, 6);


INSERT INTO alunos (id, nome, email, curso_id)
VALUES (1, 'Ana Souza', 'ana.souza@dcc.ufc.br', 1),
       (2, 'Pedro Santos', 'pedro.santos@dee.ufc.br', 2),
       (3, 'Mariana Oliveira', 'mariana.oliveira@dm.ufc.br', 3),
	   (4, 'Lucas Silva', 'lucas.silva@df.ufc.br', 4),
       (5, 'Julia Santos', 'julia.santos@db.ufc.br', 5),
       (6, 'Fernanda Oliveira', 'fernanda.oliveira@dp.ufc.br', 6);


INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (1, 1, 1, 8),
       (2, 2, 2, 7),
       (3, 3, 3, 9),
	   (4, 4, 4, 7),
       (5, 5, 5, 9),
       (6, 6, 6, 8);


INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (1, 1, 1, 'Manh�', 'B203'),
       (2, 2, 2, 'Tarde', 'C101'),
       (3, 3, 3, 'Noite', 'D301'),
	   (4, 4, 4, 'Manh�', 'A101'),
       (5, 5, 5, 'Tarde', 'B102'),
       (6, 6, 6, 'Noite', 'C201');

