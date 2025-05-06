DELIMITER //

CREATE FUNCTION nullificar(dato varchar(100))
RETURNS varchar(100)
DETERMINISTIC -- o NO DETERMINISTIC si puede variar el resultado
BEGIN
    if(dato="null") then
		return null;
    end if;
    return dato;
END //
DELIMITER ;


DELIMITER //
create procedure insertarDomicilio(
    in datos_domicilio JSON,
    out out_id_domicilio int
	)
begin
	select datos_domicilio as 'JSON del domicilio';

    set @in_calle = JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.Calle'));
    set @in_num_calle = JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.Num'));
    set @in_colonia = JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.Colonia'));
    set @in_codigo_postal = JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.CP'));   
    
	select @in_calle,@in_num_calle,@in_colonia,@in_codigo_postal;
    
	etiqueta: begin
		select (select id_domicilio from domicilio where 
            calle=@in_calle and num_calle=@in_num_calle and colonia=@in_colonia and codigo_postal=@in_codigo_postal);
        set out_id_domicilio=(select id_domicilio from domicilio where 
            calle=@in_calle and num_calle=@in_num_calle and colonia=@in_colonia and codigo_postal=@in_codigo_postal);
		select 'averiguando del domicilio 2';
        if(out_id_domicilio is not null) then
            # ya existe el domicilio
            leave etiqueta;
            select 'ya existe el dom';
        end if;

		insert into domicilio(
        calle,num_calle,colonia,codigo_postal) values(
            @in_calle,@in_num_calle,@in_colonia,@in_codigo_postal
        );
        
        set out_id_domicilio=(select last_insert_id());

	end etiqueta;
end //
DELIMITER ;

DELIMITER //
create procedure insertarInstitucion(
    in datos_inst JSON,
    in para_practicas tinyint,
    out out_id_institucion int
	)
begin
	select datos_inst as 'JSON institucion';
    set @in_nombre=JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Institucion'));
    set @in_rep_legal=JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Persona_objetivo'));
    set @in_cargo=JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Cargo'));
    
    set @in_rfc=JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.RFC'));
    set @in_telefono = JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Telefono'));
    
    set @domicilio=JSON_EXTRACT(datos_inst, '$.domicilio');
    set @id_dom = 0;
	select @in_nombre, @in_rep_legal, @in_cargo, @id_dom , @in_rfc,@in_telefono;
    # call insertarDomicilio(@in_calle,@in_num_calle,@in_colonia,@in_codigo_postal,@in_telefono,@id_dom);

    etiqueta: begin
        set out_id_institucion= (select id_institucion from institucion where rfc=@in_rfc);

        if(out_id_institucion is null) then     
			call insertarDomicilio (@domicilio, @id_dom);
            insert into institucion
                (nombre_institucion,representante_legal,cargo_representante_legal,
                    id_domicilio,RFC,telefono) 
                values(
                    @in_nombre, @in_rep_legal, @in_cargo, @id_dom , @in_rfc,@in_telefono
                );
            set out_id_institucion=(select last_insert_id());
        end if;

        if(para_practicas) then
            set @in_giro =JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.otros_detalles.Giro'));
            set @in_jefe_inmediato =JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.otros_detalles.Jefe_inmediato'));
            set @in_tel =JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.otros_detalles.Tel_j_i'));
            set @in_cargo =JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.otros_detalles.Cargo_j_i'));
        
            update institucion set giro=@in_giro where id_institucion=@out_id_institucion;

            insert into detalles_institucion_para_practicas 
                (jefe_inmediato,cargo_jefe_inmediato,telefono_jefe_inmediato, id_institucion) 
            values (
                @in_jefe_inmediato,@in_cargo,@in_telefono, out_id_institucion
            );

        end if; 
    end etiqueta;
end //
DELIMITER ;

DELIMITER //
create procedure insertarSolicitante(
    in datos_solicitante JSON,
    out out_id_solicitante int,
    out id_domicilio int
)
begin
	select datos_solicitante as 'JSON solicitante';
    set @in_num_de_control = JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.No_Control'));
    
    etiqueta: begin
        set out_id_solicitante = (select id_solicitante from solicitante where num_de_control=@in_num_de_control);
        call insertarDomicilio( JSON_EXTRACT(datos_solicitante,"$.domicilio") , id_domicilio);
        if(out_id_solicitante is not null) then 
            # ya existe solicitante
            leave etiqueta;
        end if;
        
        set @in_apellidoPaterno = JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,"$.datos.Apellido_paterno"));
        set @in_apellidoMaterno = JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,"$.datos.Apellido_materno"));
        set @in_nombres = JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,"$.datos.Nombres"));
        set @in_sexo = JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,"$.datos.Sexo"));
        set @in_id_sexo = 1;

        set @in_curp = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,"$.datos.Curp")));
        set @in_correo = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,"$.datos.Correo_Institucional")));
		
        
        if(@in_sexo = "F") then 
            # es mujer
            set @in_id_sexo=2;
        else if (@in_sexo is null ) then 
            set @in_id_sexo=3;
        end if;
		end if;
        
        insert into solicitante(
            apellidoPaterno,apellidoMaterno,nombres,
            num_de_control,id_sexo,

            curp,correo_institucional
            )
            values(
                @in_apellidoPaterno,@in_apellidoMaterno,@in_nombres,
                @in_num_de_control,@in_id_sexo,
                
                @in_curp,@in_correo
            );
        set out_id_solicitante=(select last_insert_id());
        
    end etiqueta;
end //
DELIMITER ;

DELIMITER //
create procedure hacerSolicitud(
    in datos JSON,
    in in_tipo_solicitud varchar(23),
    out out_id_solicitud int
    )
begin
	set @datos_solicitante_json = JSON_EXTRACT(datos,'$.solicitante');
    set @id_tipo_s =null,out_id_solicitud=null;
    etiqueta: begin
        set @id_tipo_s= (select id_tipo from tipoSolicitud where tipo=in_tipo_solicitud);

        call insertarSolicitante(@datos_solicitante_json,@out_id_solicitante,@id_dom_solicitante);
        set out_id_solicitud= (select id_solicitud from solicitud where 
            id_solicitante=@out_id_solicitante and tipo_solicitud=@id_tipo_s);

        if(out_id_solicitud is not null) then
            # ya habia hecho una solicitud del mismo tipo
            leave etiqueta;
        end if;

        -- ("Curp","Edad","Sexo","Correo_Institucional")

		set @datos_institucion_json = JSON_EXTRACT(datos,'$.institucion');
		call insertarInstitucion(@datos_institucion_json,@id_tipo_s-1,@out_id_institucion);
		
		set @in_carrera = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Carrera"));
		set @in_semestre = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Semestre"));
		set @in_grupo = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Grupo"));
		set @in_turno = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Turno"));
		set @in_telefono = JSON_UNQUOTE(JSON_EXTRACT(@datos_solicitante_json,"$.datos.Telefono"));
		set @in_inicio = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Inicio"));
		set @in_termino = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Termino"));
		set @in_actividades = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Actividades"));
		set @in_apoyo = JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Recibe_apoyo"));
		set @in_monto = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Monto")));    
		select 'marca';
		set @id_turno= (select id_turno from turno where turno=@in_turno);
		set @tiene_apoyo=0;
		set @in_nom_proy = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,"$.solicitud.datos.Nombre_proyecto")));
		set @in_edad = nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_solicitante_json,"$.datos.Edad")));
		select 'antes del apoyo';
		if(@in_apoyo="SI") then 
			set @tiene_apoyo=1;
		end if;
		select 'finales';
		select @out_id_solicitante,@id_tipo_s,@id_dom_solicitante, @in_telefono, @in_carrera, @in_semestre, @in_grupo,
			@id_turno, @id_institucion, @in_inicio, @in_termino, @in_actividades, @tiene_apoyo,
			@in_monto, NOW(), 0,@in_nom_proy,@in_edad;
		insert into solicitud(
			id_solicitante,tipo_solicitud,id_domicilio_solicitante,telefono_solicitante,id_carrera,semestre,grupo,id_turno,
			id_institucion,fecha_inicio,fecha_termino,actividades,tiene_apoyo_economico,
			monto_apoyo_economico,fecha_entrega_solicitud,estado_solicitud,

			nombre_proyecto,edad_solicitante
		) values(
			@out_id_solicitante,@id_tipo_s,@id_dom_solicitante, @in_telefono, (select id_carrera from carreras where nombre=@in_carrera), @in_semestre, @in_grupo,
			@id_turno, @out_id_institucion, @in_inicio, @in_termino, @in_actividades, @tiene_apoyo,
			@in_monto, NOW(), 0,

			@in_nom_proy,@in_edad
		);
		set out_id_solicitud=(select last_insert_id());
    end etiqueta;
end //
DELIMITER ;