DELIMITER //
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
    in in_num_de_control varchar(14), in correo_institucional varchar(50),

    in in_sexo int, in in_id_domicilio int,
    out idSolicitante int
)
begin 
	insert into perfil(numerocontrol,correo,telefono,contraseña_encript) values(numControl,instMail,telefono,psw);
    set idPerfil=(select obtener_id_perfil(numControl));
end //
DELIMITER ; 

/*id_domicilio int primary key auto_increment,
	calle varchar(40),
    num_calle int,
    colonia varchar(30),
    codigo_postal varchar(5),
    telefono varchar(13)*/
DELIMITER //
create procedure insertarDomicilio(
	) 
begin 
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
select last_insert_id();

/*id_institucion int primary key auto_increment,
    nombre_institucion varchar(100),
    nombre_objetivo_de_presentacion varchar(100),
    cargo_del_objetivo varchar(50),
    
    id_domicilio int,
    
    RFC varchar (13),*/
DELIMITER //
create procedure insertarInstitucion(
	) 
begin 
end //
DELIMITER ;