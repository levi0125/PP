-- drop schema SSPP;
-- create schema SSPP CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
-- use SSPP;
SET NAMES utf8mb4;
################# TABLAS CATALOGO #####################
CREATE TABLE if not exists sexo (
	id_sexo INT AUTO_INCREMENT PRIMARY KEY,
    sexo VARCHAR(9)
);
INSERT INTO sexo VALUES(1,"Masculino"),(2,"Femenino"),(3,"Sin dato");

CREATE TABLE if not exists turno(
	id_turno INT AUTO_INCREMENT PRIMARY KEY,
    turno VARCHAR(10)
);
INSERT INTO turno VALUES(1,"Matutino"),(2,"Vespertino");

CREATE TABLE IF NOT EXISTS tipoSolicitud(
	id_tipo INT PRIMARY KEY,
    tipo VARCHAR(23)
);
INSERT INTO tipoSolicitud VALUES
	(1,"Servicio Social"),
	(2,"Practicas Profesionales");
CREATE TABLE carreras(
    id_carrera INT PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(50)
);
INSERT INTO carreras values
    (1,"ADMINISTRACION DE RECURSOS HUMANOS"),
    (2,"MANTENIMIENTO AUTOMOTRIZ"),
    (3,"PROGRAMACION"),
    (4,"SOPORTE Y MANTENIMIENTO DE EQUIPO DE COMPUTO");
################# FIN DE TABLAS CATALOGO #####################
CREATE TABLE IF NOT EXISTS domicilio(
	id_domicilio INT PRIMARY KEY AUTO_INCREMENT,
	calle VARCHAR(40),
    num_calle INT ,
    colonia VARCHAR(30),
    codigo_postal VARCHAR(5)
    -- telefono VARCHAR(13)
);
CREATE TABLE IF NOT EXISTS solicitante(
	id_solicitante INT PRIMARY KEY AUTO_INCREMENT,
    apellidoPaterno VARCHAR(30),
    apellidoMaterno VARCHAR(30),
    nombres VARCHAR(100),
    id_sexo INT DEFAULT 3,
    
    num_de_control CHAR(14),

    curp VARCHAR(18),
    correo_institucional VARCHAR(50),
    FOREIGN KEY (id_sexo) REFERENCES sexo(id_sexo)
);
CREATE TABLE IF NOT EXISTS institucion (
	id_institucion INT PRIMARY KEY AUTO_INCREMENT,
    nombre_institucion VARCHAR(100),
    representante_legal VARCHAR(100),
    cargo_representante_legal VARCHAR(50),
    
    id_domicilio INT ,
    telefono VARCHAR(13),
    
    RFC VARCHAR (13),

    giro VARCHAR(40),#creo que es la actividad de la empresa/institucion
    
    FOREIGN KEY (id_domicilio) REFERENCES domicilio(id_domicilio)
);

CREATE TABLE IF NOT EXISTS detalles_institucion_para_practicas(
	id_institucion INT ,
    jefe_inmediato VARCHAR(100),
    cargo_jefe_inmediato VARCHAR(60),
    telefono_jefe_inmediato VARCHAR(10),
    FOREIGN KEY (id_institucion)  REFERENCES institucion(id_institucion)
);

CREATE TABLE IF NOT EXISTS solicitud(
	id_solicitud INT PRIMARY KEY AUTO_INCREMENT,
    tipo_solicitud int ,
    
    #Solicitante
    id_solicitante INT ,
    
    id_domicilio_solicitante INT ,
    FOREIGN KEY (id_domicilio_solicitante) REFERENCES domicilio(id_domicilio),
    telefono_solicitante VARCHAR(13),

    edad_solicitante INT ,

    -- carrera VARCHAR(20),
    id_carrera int,
    semestre INT ,
    grupo VARCHAR(3),
    id_turno INT ,
    
    #Institucion donde se hará servicio
    id_institucion INT ,
    fecha_inicio DATE,
    fecha_termino DATE,
    
    #Sobre el servicio
    actividades VARCHAR(150),
    tiene_apoyo_economico BOOLEAN DEFAULT false,
    monto_apoyo_economico DECIMAL DEFAULT 0, 
    -- opcional, si es que le dan apoyo economico
    
    fecha_entrega_solicitud DATE,
    
    estado_solicitud INT DEFAULT 0,
    -- 0 -> pendiente por revision
    -- 1 -> aceptado y revisado
    -- 2 -> rechazado
    -- 3 -> incompleto

    nombre_proyecto VARCHAR(100),
    
    FOREIGN KEY(tipo_solicitud) REFERENCES tipoSolicitud(id_tipo),
    FOREIGN KEY(id_solicitante) REFERENCES solicitante(id_solicitante),
    FOREIGN KEY(id_turno) REFERENCES turno(id_turno),
    FOREIGN KEY(id_institucion) REFERENCES institucion(id_institucion),
    FOREIGN KEY(id_carrera) REFERENCES carreras(id_carrera)
);
