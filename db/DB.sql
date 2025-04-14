/*create database SSPP;
use SSPP;
*/
################# TABLAS CATALOGO #####################
create table sexo(
	id_sexo int auto_increment primary key,
    sexo char(1)
);
insert into sexo values(1,"H"),(2,"M");

create table turno(
	id_turno int auto_increment primary key,
    turno char(1)
);
insert into turno values(1,"M"),(2,"V");

create table if not exists tipoSolicitud(
	id_tipo int primary key,
    tipo varchar(23)
);
insert into tipoSolicitud values
	(1,"Servicio Social"),
	(2,"Practicas Profesionales");
create table if not exists estadoSolicitud(
	id_estado int primary key,
    estado varchar(20)
);
insert into estadoSolicitud values
	(1,"FINALIZADO"),
    (2,"PENDIENTE");

################# FIN DE TABLAS CATALOGO #####################
create table if not exists domicilio(
	id_domicilio int primary key auto_increment,
	calle varchar(40),
    num_calle int,
    colonia varchar(30),
    codigo_postal varchar(5),
    telefono varchar(13)
);
create table if not exists solicitante(
	id_solicitante int primary key auto_increment,
    apellidoPaterno varchar(30) ,
    apellidoMaterno varchar(30),
    nombres varchar(100),
    curp char(18),
    id_sexo int,
    id_domicilio int,
    
    num_de_control char(14),
    correo_institucional varchar(50),

    foreign key (id_sexo) references sexo(id_sexo),
    foreign key (id_domicilio) references domicilio(id_domicilio)
);
create table if not exists institucion (
	id_institucion int primary key auto_increment,
    nombre_institucion varchar(100),
    nombre_objetivo_de_presentacion varchar(100),
    cargo_del_objetivo varchar(50),
    
    id_domicilio int,
    
    RFC varchar (13),
    
    foreign key (id_domicilio) references domicilio(id_domicilio)
);
create table if not exists detalles_institucion_para_practicas(
	id_institucion int,
	giro varchar(40),#creo que es la actividad de la empresa/institucion
    nombre_representante_legal varchar(100),
    cargo_representante varchar(60),
    
    telefono_jefe_inmediato varchar(10),
    foreign key (id_institucion)  references institucion(id_institucion)
);
delimiter//
def 

create  table if not exists solicitud(
	id_solicitud int primary key auto_increment,
    tipo_solicitud int,
    #Solicitante
    id_solicitante int,
    telefono varchar(13),
    carrera varchar(20),    
    semestre int,
    grupo varchar(3),
    turno int,
    
    #Institucion donde se hará servicio
    id_institucion int,
    fecha_inicio date,
    fecha_termino date,
    
    #Sobre el servicio
    actividades varchar(150),
    tiene_apoyo_economico boolean,
    monto_apoyo_economico decimal,
    
    fecha_entrega_solicitud date,
    
    estado_solicitud int,
    
    foreign key (tipo_solicitud) references tipoSolicitud(id_tipo),
    foreign key(id_solicitante) references solicitante(id_solicitante),
    foreign key(turno) references turno(id_turno),
    foreign key(id_institucion) references institucion(id_institucion)
);

create table if not exists solicitud_tiene_nombre(
	id_solicitud int primary key,
    nombre varchar(100),
    
    foreign key (id_solicitud) references solicitud(id_solicitud)
);