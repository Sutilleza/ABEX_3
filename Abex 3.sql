CREATE TABLE Cargo (
 descricao_cargo varchar(20),
 cod_cargo number(4) PRIMARY KEY
);
CREATE TABLE Camera (
 numero_camera number(2) PRIMARY KEY,
 local_camera varchar(50)
);
CREATE TABLE Acao (
 descricao_acao varchar(50)
);
CREATE TABLE Pessoa (
 nome_pessoa varchar(50),
 cpf varchar(11) PRIMARY KEY,
 fk_Cargo_cod_cargo number(4)
);
CREATE TABLE Planta (
 especie varchar(50),
 nome_planta varchar(50),
 nome_cientifico varchar(50),
 cuidados varchar(50),
 grupo varchar(50),
 cod_planta number(2) PRIMARY KEY
);
CREATE TABLE Mapa (
 area varchar(50),
 icone varchar(50),
 fk_Pessoa_cpf varchar(11),
 fk_Planta_cod_planta number(2)
);
CREATE TABLE limitarAcao (
 fk_Cargo_cod_cargo number(4)
);
CREATE TABLE acoesPlanta (
 fk_Planta_cod_planta number(2),
 fk_Pessoa_cpf varchar(11)
);
CREATE TABLE visualizarCamera (
 fk_Pessoa_cpf varchar(11),
 fk_Camera_numero_camera number(2)
);
ALTER TABLE Pessoa ADD CONSTRAINT FK_Pessoa_2
    FOREIGN KEY (fk_Cargo_cod_cargo)
    REFERENCES Cargo (cod_cargo)
    ON DELETE CASCADE;
ALTER TABLE Mapa ADD CONSTRAINT FK_Mapa_1
    FOREIGN KEY (fk_Pessoa_cpf)
    REFERENCES Pessoa (cpf)
    ON DELETE CASCADE;
ALTER TABLE Mapa ADD CONSTRAINT FK_Mapa_2
    FOREIGN KEY (fk_Planta_cod_planta)
    REFERENCES Planta (cod_planta)
    ON DELETE CASCADE;
ALTER TABLE limitarAcao ADD CONSTRAINT FK_limitarAcao_1
    FOREIGN KEY (fk_Cargo_cod_cargo)
    REFERENCES Cargo (cod_cargo)
    ON DELETE RESTRICT;

ALTER TABLE acoesPlanta ADD CONSTRAINT FK_acoesPlanta_1
    FOREIGN KEY (fk_Planta_cod_planta)
    REFERENCES Planta (cod_planta)
    ON DELETE SET NULL;
ALTER TABLE acoesPlanta ADD CONSTRAINT FK_acoesPlanta_2
    FOREIGN KEY (fk_Pessoa_cpf)
    REFERENCES Pessoa (cpf)
    ON DELETE SET NULL;
ALTER TABLE visualizarCamera ADD CONSTRAINT FK_visualizarCamera_1
    FOREIGN KEY (fk_Pessoa_cpf)
    REFERENCES Pessoa (cpf)
    ON DELETE SET NULL;
ALTER TABLE visualizarCamera ADD CONSTRAINT FK_visualizarCamera_2
    FOREIGN KEY (fk_Camera_numero_camera)
    REFERENCES Camera (numero_camera)
    ON DELETE SET NULL;

CREATE OR REPLACE TRIGGER trg_update_cargo
AFTER UPDATE OF cod_cargo ON Cargo
FOR EACH ROW
BEGIN
    UPDATE Pessoa
    SET fk_Cargo_cod_cargo = :NEW.cod_cargo
    WHERE fk_Cargo_cod_cargo = :OLD.cod_cargo;
END;

CREATE OR REPLACE TRIGGER trg_update_pessoa_mapa
AFTER UPDATE OF cpf ON Pessoa
FOR EACH ROW
BEGIN
    UPDATE Mapa
    SET fk_Pessoa_cpf = :NEW.cpf
    WHERE fk_Pessoa_cpf = :OLD.cpf;
END;
CREATE OR REPLACE TRIGGER trg_update_planta_mapa
AFTER UPDATE OF cod_planta ON Planta
FOR EACH ROW
BEGIN
    UPDATE Mapa
    SET fk_Planta_cod_planta = :NEW.cod_planta
    WHERE fk_Planta_cod_planta = :OLD.cod_planta;
END;

CREATE OR REPLACE TRIGGER trg_update_pessoa_acoesplanta
AFTER UPDATE OF cpf ON Pessoa
FOR EACH ROW
BEGIN
    UPDATE acoesPlanta
    SET fk_Pessoa_cpf = :NEW.cpf
    WHERE fk_Pessoa_cpf = :OLD.cpf;
END;

CREATE OR REPLACE TRIGGER trg_update_planta_acoesplanta
AFTER UPDATE OF cod_planta ON Planta
FOR EACH ROW
BEGIN
    UPDATE acoesPlanta
    SET fk_Planta_cod_planta = :NEW.cod_planta
    WHERE fk_Planta_cod_planta = :OLD.cod_planta;
END;

CREATE OR REPLACE TRIGGER trg_update_pessoa_visualizarcamera
AFTER UPDATE OF cpf ON Pessoa
FOR EACH ROW
BEGIN
    UPDATE visualizarCamera
    SET fk_Pessoa_cpf = :NEW.cpf
    WHERE fk_Pessoa_cpf = :OLD.cpf;
END;

CREATE OR REPLACE TRIGGER trg_update_camera_visualizarcamera
AFTER UPDATE OF numero_camera ON Camera
FOR EACH ROW
BEGIN
    UPDATE visualizarCamera
    SET fk_Camera_numero_camera = :NEW.numero_camera
    WHERE fk_Camera_numero_camera = :OLD.numero_camera;
END;

-- Mostra os cargos
SELECT * FROM Cargo;

-- Para ver informações das pessoas e o cargo associado a cada uma.
SELECT Pessoa.nome_pessoa, Pessoa.cpf, Cargo.descricao_cargo 
FROM Pessoa 
JOIN Cargo ON Pessoa.fk_Cargo_cod_cargo = Cargo.cod_cargo;

-- Para ver as plantas e pessoas associadas a cada área no mapa.
SELECT Mapa.area, Mapa.icone, Pessoa.nome_pessoa, Planta.nome_planta 
FROM Mapa
LEFT JOIN Pessoa ON Mapa.fk_Pessoa_cpf = Pessoa.cpf
LEFT JOIN Planta ON Mapa.fk_Planta_cod_planta = Planta.cod_planta;

-- Exibe cada pessoa e as câmeras que ela pode visualizar.
SELECT Pessoa.nome_pessoa, Camera.local_camera 
FROM visualizarCamera
JOIN Pessoa ON visualizarCamera.fk_Pessoa_cpf = Pessoa.cpf
JOIN Camera ON visualizarCamera.fk_Camera_numero_camera = Camera.numero_camera;

import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

def create_tables():
    cursor.execute('''CREATE TABLE IF NOT EXISTS Cargo (
        descricao_cargo TEXT,
        cod_cargo INTEGER PRIMARY KEY
    )''')
    
    cursor.execute('''CREATE TABLE IF NOT EXISTS Pessoa (
        nome_pessoa TEXT,
        cpf TEXT PRIMARY KEY,
        fk_Cargo_cod_cargo INTEGER,
        FOREIGN KEY (fk_Cargo_cod_cargo) REFERENCES Cargo (cod_cargo) ON DELETE CASCADE
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Planta (
        especie TEXT,
        nome_planta TEXT,
        nome_cientifico TEXT,
        cuidados TEXT,
        grupo TEXT,
        cod_planta INTEGER PRIMARY KEY
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Mapa (
        area TEXT,
        icone TEXT,
        fk_Pessoa_cpf TEXT,
        fk_Planta_cod_planta INTEGER,
        FOREIGN KEY (fk_Pessoa_cpf) REFERENCES Pessoa (cpf) ON DELETE CASCADE,
        FOREIGN KEY (fk_Planta_cod_planta) REFERENCES Planta (cod_planta) ON DELETE CASCADE
    )''')
    conn.commit()

def create_cargo(descricao, codigo):
    cursor.execute("INSERT INTO Cargo (descricao_cargo, cod_cargo) VALUES (?, ?)", (descricao, codigo))
    conn.commit()

def create_pessoa(nome, cpf, fk_cod_cargo):
    cursor.execute("INSERT INTO Pessoa (nome_pessoa, cpf, fk_Cargo_cod_cargo) VALUES (?, ?, ?)", (nome, cpf, fk_cod_cargo))
    conn.commit()

def create_planta(especie, nome, nome_cientifico, cuidados, grupo, codigo):
    cursor.execute("INSERT INTO Planta (especie, nome_planta, nome_cientifico, cuidados, grupo, cod_planta) VALUES (?, ?, ?, ?, ?, ?)", (especie, nome, nome_cientifico, cuidados, grupo, codigo))
    conn.commit()

def read_cargos():
    cursor.execute("SELECT * FROM Cargo")
    return cursor.fetchall()

def read_pessoas():
    cursor.execute("SELECT * FROM Pessoa")
    return cursor.fetchall()

def read_plantas():
    cursor.execute("SELECT * FROM Planta")
    return cursor.fetchall()

def update_cargo(cod_cargo, nova_descricao):
    cursor.execute("UPDATE Cargo SET descricao_cargo = ? WHERE cod_cargo = ?", (nova_descricao, cod_cargo))
    conn.commit()

def update_pessoa(cpf, novo_nome):
    cursor.execute("UPDATE Pessoa SET nome_pessoa = ? WHERE cpf = ?", (novo_nome, cpf))
    conn.commit()

def delete_cargo(cod_cargo):
    cursor.execute("DELETE FROM Cargo WHERE cod_cargo = ?", (cod_cargo,))
    conn.commit()

def delete_pessoa(cpf):
    cursor.execute("DELETE FROM Pessoa WHERE cpf = ?", (cpf,))
    conn.commit()

create_tables()

create_cargo("Gerente", 1)
create_pessoa("João Silva", "12345678901", 1)
create_planta("Flor", "Orquídea", "Orchidaceae", "Regar 1x por semana", "Tropical", 1)

print("Cargos:", read_cargos())
print("Pessoas:", read_pessoas())
print("Plantas:", read_plantas())

update_cargo(1, "Gerente Geral")
update_pessoa("12345678901", "João da Silva")

delete_cargo(1)
delete_pessoa("12345678901")

conn.close()