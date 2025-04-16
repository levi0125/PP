-- institucion
    in in_institucion_nombre varchar(100), in in_institucion_persona_a_cargo varchar(100), in in_institucion_cargo varchar(50),
    in in_institucion_id_domicilio int, in in_institucion_rfc varchar(13),
    -- domicilio institucion
    in in_institucion_calle varchar(40),in in_institucion_num_calle int, in in_institucion_colonia varchar(30),in in_institucion_codigo_postal varchar(5),in in_institucion_telefono varchar(13),
    -- solicitante
    in in_apellidoPaterno varchar(30),in in_apellidoMaterno varchar(30),in in_nombres varchar(100),in in_curp char(18),
    in in_num_de_control varchar(14), in in_correo_institucional varchar(50),
    in in_sexo char(1),
    -- domicilio solicitante
    in in_solicitante_calle varchar(40),in in_solicitante_num_calle int, in in_solicitante_colonia varchar(30),in in_solicitante_codigo_postal varchar(5),in in_solicitante_telefono varchar(13),
    -- sobre la solicitud
    in_tipo_solicitud varchar(11),in_id_solicitante int,in_telefono varchar(13),in_carrera varchar(20),in_semestre int,in_grupo varchar(3),in_turno int,in_id_institucion int,in_fecha_inicio date,in_fecha_termino date,in_actividades varchar(150),in_tiene_apoyo_economico boolean,in_monto_apoyo_economico decimal,in_fecha_entrega_solicitud date,in_estado_solicitud int	