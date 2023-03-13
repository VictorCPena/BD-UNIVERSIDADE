CREATE TABLE departamentos (
  id NUMBER PRIMARY KEY,
  nome VARCHAR2(50) NOT NULL,
  sigla VARCHAR2(10) UNIQUE NOT NULL
);

CREATE TABLE professores (
  id NUMBER PRIMARY KEY,
  nome VARCHAR2(50) NOT NULL,
  email VARCHAR2(50) UNIQUE NOT NULL,
  departamento_id NUMBER NOT NULL,
  CONSTRAINT fk_prof_dept_id FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

CREATE TABLE cursos (
  id NUMBER PRIMARY KEY,
  nome VARCHAR2(50) NOT NULL,
  departamento_id NUMBER NOT NULL,
  CONSTRAINT fk_curso_dept_id FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

CREATE TABLE disciplinas (
  id NUMBER PRIMARY KEY,
  nome VARCHAR2(50) NOT NULL,
  codigo VARCHAR2(50) UNIQUE NOT NULL,
  creditos NUMBER NOT NULL,
  curso_id NUMBER NOT NULL,
  CONSTRAINT fk_disc_curso_id FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

CREATE TABLE alunos (
  id NUMBER PRIMARY KEY,
  nome VARCHAR2(50) NOT NULL,
  email VARCHAR2(50) UNIQUE NOT NULL,
  curso_id NUMBER NOT NULL,
  CONSTRAINT fk_aluno_curso_id FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

CREATE TABLE matriculas (
  id NUMBER PRIMARY KEY,
  aluno_id NUMBER NOT NULL,
  disciplina_id NUMBER NOT NULL,
  nota NUMBER CHECK (nota >= 1 AND nota <= 10),
  CONSTRAINT fk_matr_aluno_id FOREIGN KEY (aluno_id) REFERENCES alunos(id),
  CONSTRAINT fk_matr_disc_id FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id)
);

CREATE TABLE turmas (
  id NUMBER PRIMARY KEY,
  disciplina_id NUMBER NOT NULL,
  professor_id NUMBER NOT NULL,
  turno VARCHAR2(10) NOT NULL,
  sala VARCHAR2(10) NOT NULL,
  CONSTRAINT fk_turma_disc_id FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id),
  CONSTRAINT fk_turma_prof_id FOREIGN KEY (professor_id) REFERENCES professores(id)
);

-- Trigger para impedir a remoção de disciplinas que possuem matrículas associadas

CREATE OR REPLACE TRIGGER impedir_remocao_disciplina
BEFORE DELETE ON disciplinas
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM matriculas WHERE disciplina_id = :OLD.id;
  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Esta disciplina possui matrículas associadas e não pode ser removida.');
  END IF;
END;
/

-- Trigger para impedir a remoção de departamentos com cursos associados

CREATE OR REPLACE TRIGGER impedir_remocao_departamento
BEFORE DELETE ON departamentos
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM cursos WHERE departamento_id = :OLD.id;
  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Este departamento possui cursos associados e não pode ser removido.');
  END IF;
END;
/

-- Trigger para limitar o número de turmas atribuídas a um professor

CREATE OR REPLACE TRIGGER limitar_numero_turmas_professor
BEFORE INSERT ON turmas
FOR EACH ROW
DECLARE
  numero_turmas NUMBER;
  limite_turmas NUMBER := 5; -- limite de 5 turmas por professor
BEGIN
  SELECT COUNT(*) INTO numero_turmas FROM turmas WHERE professor_id = :NEW.professor_id;
  IF numero_turmas >= limite_turmas THEN
    RAISE_APPLICATION_ERROR(-20001, 'O professor já está atribuído a ' || numero_turmas || ' turmas, que é o limite máximo permitido.');
  END IF;
END;
/

-- Inserindo Dados

INSERT INTO departamentos (id, nome, sigla)
VALUES (1, 'Departamento de Ciência da Computação', 'DCC');
INSERT INTO departamentos (id, nome, sigla)
VALUES (2, 'Departamento de Engenharia Elétrica', 'DEE');
INSERT INTO departamentos (id, nome, sigla)
VALUES (3, 'Departamento de Matemática', 'DM');
INSERT INTO departamentos (id, nome, sigla)
VALUES (4, 'Departamento de Física', 'DF');
INSERT INTO departamentos (id, nome, sigla)
VALUES (5, 'Departamento de Biologia', 'DB');
INSERT INTO departamentos (id, nome, sigla)
VALUES (6, 'Departamento de Psicologia', 'DP');


INSERT INTO professores (id, nome, email, departamento_id)
VALUES (1, 'João da Silva', 'joao.silva@dcc.ufmg.br', 1);
INSERT INTO professores (id, nome, email, departamento_id)
VALUES (2, 'Maria das Dores', 'maria.dores@dee.ufmg.br', 2);
INSERT INTO professores (id, nome, email, departamento_id)
VALUES (3, 'José Pereira', 'jose.pereira@dm.ufmg.br', 3);
INSERT INTO professores (id, nome, email, departamento_id)
VALUES (4, 'Paulo Roberto', 'paulo.roberto@df.ufmg.br', 4);
INSERT INTO professores (id, nome, email, departamento_id)
VALUES (5, 'Ana Paula', 'ana.paula@db.ufmg.br', 5);
INSERT INTO professores (id, nome, email, departamento_id)
VALUES (6, 'Maria Clara', 'maria.clara@dp.ufmg.br', 6);



INSERT INTO cursos (id, nome, departamento_id)
VALUES (1, 'Bacharelado em Ciência da Computação', 1);
INSERT INTO cursos (id, nome, departamento_id)
VALUES (2, 'Bacharelado em Engenharia Elétrica', 2);
INSERT INTO cursos (id, nome, departamento_id)
VALUES (3, 'Licenciatura em Matemática', 3);
INSERT INTO cursos (id, nome, departamento_id)
VALUES (4, 'Licenciatura em Física', 4);
INSERT INTO cursos (id, nome, departamento_id)
VALUES (5, 'Bacharelado em Biologia', 5);
INSERT INTO cursos (id, nome, departamento_id)
VALUES (6, 'Bacharelado em Psicologia', 6);


INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (1, 'Introdução à Programação', 'DCC101', 4, 1);
INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (2, 'Circuitos Elétricos', 'DEE201', 4, 2);
INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (3, 'Cálculo I', 'DM101', 4, 3);
INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (4, 'Física Quântica', 'DF101', 4, 4);
INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES  (5, 'Biologia Molecular', 'DB201', 4, 5);
INSERT INTO disciplinas (id, nome, codigo, creditos, curso_id)
VALUES (6, 'Psicologia Social', 'DP301', 4, 6);


INSERT INTO alunos (id, nome, email, curso_id)
VALUES (1, 'Ana Souza', 'ana.souza@dcc.ufc.br', 1);
INSERT INTO alunos (id, nome, email, curso_id)
VALUES (2, 'Pedro Santos', 'pedro.santos@dee.ufc.br', 2);
INSERT INTO alunos (id, nome, email, curso_id)
VALUES (3, 'Mariana Oliveira', 'mariana.oliveira@dm.ufc.br', 3);
INSERT INTO alunos (id, nome, email, curso_id)
VALUES (4, 'Lucas Silva', 'lucas.silva@df.ufc.br', 4);
INSERT INTO alunos (id, nome, email, curso_id)
VALUES (5, 'Julia Santos', 'julia.santos@db.ufc.br', 5);
INSERT INTO alunos (id, nome, email, curso_id)
VALUES (6, 'Fernanda Oliveira', 'fernanda.oliveira@dp.ufc.br', 6);


INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (1, 1, 1, 8);
INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (2, 2, 2, 7);
INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (3, 3, 3, 9);
INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (4, 4, 4, 7);
INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (5, 5, 5, 9);
INSERT INTO matriculas (id, aluno_id, disciplina_id, nota)
VALUES (6, 6, 6, 8);


INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (1, 1, 1, 'Manhã', 'B203');
INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (2, 2, 2, 'Tarde', 'C101');
INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (3, 3, 3, 'Noite', 'D301');
INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (4, 4, 4, 'Manhã', 'A101');
INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (5, 5, 5, 'Tarde', 'B102');
INSERT INTO turmas (id, disciplina_id, professor_id, turno, sala)
VALUES (6, 6, 6, 'Noite', 'C201');
