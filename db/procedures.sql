DELIMITER //
/*id_domicilio int primary key auto_increment,
	calle varchar(40),
    num_calle int,
    colonia varchar(30),
    codigo_postal varchar(5),
    telefono varchar(13)*/
DELIMITER //
create procedure insertarDomicilio(
    in in_calle varchar(40),in in_num_calle int, in in_colonia varchar(30),in in_codigo_postal varchar(5),in in_telefono varchar(13),
    out id_domicilio int
	)
begin 
    insert into domicilio(
        calle,num_calle,colonia,codigo_postal,telefono) values(
            in_calle,in_num_calle,in_colonia,in_codigo_postal,in_telefono
        );
    set id_domicilio=select last_insert_id();
/*
	etiqueta: begin
		if ((select id_categoria from categoria where nombre=nomb) is not null) then
			set resultado= -1;# ya existe la categoria/materia
			leave etiqueta;
		end if;
		insert into categoria(nombre,descripcion) values(nomb,descripcion); #creamos la categoria
		
		set resultado=(select id_categoria from categoria where nombre=nomb);
	end etiqueta;*/
end //
DELIMITER ;


/*id_institucion int primary key auto_increment,
    nombre_institucion varchar(100),
    nombre_objetivo_de_presentacion varchar(100),
    cargo_del_objetivo varchar(50),
    
    id_domicilio int,
    
    RFC varchar (13),
    */
DELIMITER //
create procedure insertarInstitucion(
    int datos JSON,
    in nombre varchar(100), in persona_a_cargo varchar(100), in cargo varchar(50),
    in in_id_domicilio int, in in_rfc varchar(13),
    out id_institucion int
	)
begin
set nombre=JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.institucion.nombre'))
set persona_a_cargo=JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.institucion.nombre'))  
set cargo=JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.institucion.nombre'))  
set in_id_domicilio=JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.institucion.nombre'))  
set in_rfc=JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.institucion.nombre'))
  
    insert into institucion
        (nombre_institucion,nombre_objetivo_de_presentacion,cargo_del_objetivo,id_domicilio,RFC) 
        values(
            nombre, persona_a_cargo,cargo, in_id_domicilio, in_rfc
        );
    set id_institucion=select last_insert_id();
end //
DELIMITER ;

/*id_solicitante int primary key auto_increment,
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
    */
create procedure insertarSolicitante(
	in in_apellidoPaterno varchar(30),in in_apellidoMaterno varchar(30),in in_nombres varchar(100),in in_curp char(18),
    in in_num_de_control varchar(14), in in_correo_institucional varchar(50),

    in in_sexo int, in in_id_domicilio int,
    out idSolicitante int
)
begin 
	insert into solicitante(
        apellidoPaterno,apellidoMaterno,nombres,curp,
        num_de_control,correo_institucional,
        id_domicilio,id_sexo
        )
        values(
            in_apellidoPaterno,in_apellidoMaterno,in_nombres,in_curp,
            in_num_de_control,in_correo_institucional,
            in_id_domicilio,in_sexo);
    set idSolicitante=select last_insert_id();
end //
DELIMITER ; 
/*
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
    */
DELIMITER //
create procedure hacerSolicitud(
    IN datos_institucion_json JSON,
    IN datos_solicitante_json JSON,
    IN datos_solicitud_json JSON
    )
begin
    -- SET nombre = JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.solicitante.nombre'));
    -- SET edad = JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.solicitante.edad'));
    -- SET institucion_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_datos_json, '$.institucion.nombre'));

    -- DECLARE id_tipo_solicitud INT DEFAULT 0;
    -- DECLARE id_tipo_sex INT DEFAULT 2;

    -- if(in_tipo_solicitud=="servicio")then
    --     set id_tipo_solicitud=1;
    -- end if;

    -- if(in_sexo=="M")then
    --     -- Male
    --     set id_tipo_sex=1;
    -- end if;

    call insertarInstitucion(datos_institucion_json);
end //
DELIMITER ;