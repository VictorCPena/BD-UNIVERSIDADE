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

-- Trigger para impedir a remoção de disciplinas que possuem matrículas associadas

CREATE OR REPLACE FUNCTION impedir_remocao_disciplina()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM matriculas WHERE disciplina_id = OLD.id) THEN
    RAISE EXCEPTION 'Este departamento possui cursos associados e não pode ser removido.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger para impedir a remoção de departamentos com cursos associados

CREATE OR REPLACE FUNCTION impedir_remocao_departamento()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM cursos WHERE departamento_id = OLD.id) THEN
    RAISE EXCEPTION 'Este departamento possui cursos associados e não pode ser removido.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER departamento_com_cursos
BEFORE DELETE ON departamentos
FOR EACH ROW
EXECUTE FUNCTION impedir_remocao_departamento();

-- Trigger para limitar o número de turmas atribuídas a um professor

CREATE OR REPLACE FUNCTION limitar_numero_turmas_professor()
RETURNS TRIGGER AS $$
DECLARE
  numero_turmas INTEGER;
  limite_turmas INTEGER := 5; -- limite de 5 turmas por professor
BEGIN
  SELECT COUNT(*) INTO numero_turmas FROM turmas WHERE professor_id = NEW.professor_id;
  IF numero_turmas >= limite_turmas THEN
    RAISE EXCEPTION'O professor já está atribuído a % turmas, que é o limite máximo permitido.', numero_turmas;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_limite_turmas_professor
BEFORE INSERT ON turmas
FOR EACH ROW
EXECUTE FUNCTION limitar_numero_turmas_professor();


-- Inserindo Dados

INSERT INTO departamentos (id, nome, sigla)
VALUES (1, 'Departamento de Ciência da Computação', 'DCC'),
       (2, 'Departamento de Engenharia Elétrica', 'DEE'),
       (3, 'Departamento de Matemática', 'DM'),
	   (4, 'Departamento de Física', 'DF'),
       (5, 'Departamento de Biologia', 'DB'),
       (6, 'Departamento de Psicologia', 'DP');


INSERT INTO professores (id, nome, email, departamento_id)
VALUES (1, 'João da Silva', 'joao.silva@dcc.ufmg.br', 1),
       (2, 'Maria das Dores', 'maria.dores@dee.ufmg.br', 2),
       (3, 'José Pereira', 'jose.pereira@dm.ufmg.br', 3),
	   (4, 'Paulo Roberto', 'paulo.roberto@df.ufmg.br', 4),
       (5, 'Ana Paula', 'ana.paula@db.ufmg.br', 5),
       (6, 'Maria Clara', 'maria.clara@dp.ufmg.br', 6);



INSERT INTO cursos (id, nome, departamento_id)
VALUES (1, 'Bacharelado em Ciência da Computação', 1),
       (2, 'Bacharelado em Engenharia Elétrica', 2),
       (3, 'Licenciatura em Matemática', 3),
	   (4, 'Licenciatura em Física', 4),
       (5, 'Bacharelado em Biologia', 5),
       (6, 'Bacharelado em Psicologia', 6);


INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (1, 'Introdução à Programação', 'DCC101', 4, 1),
       (2, 'Circuitos Elétricos', 'DEE201', 4, 2),
       (3, 'Cálculo I', 'DM101', 4, 3),
	   (4, 'Física Quântica', 'DF101', 4, 4),
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
VALUES (1, 1, 1, 'Manhã', 'B203'),
       (2, 2, 2, 'Tarde', 'C101'),
       (3, 3, 3, 'Noite', 'D301'),
	   (4, 4, 4, 'Manhã', 'A101'),
       (5, 5, 5, 'Tarde', 'B102'),
       (6, 6, 6, 'Noite', 'C201');

