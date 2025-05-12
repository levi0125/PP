DELIMITER //
create procedure insertarDomicilio(
    in datos_domicilio JSON,
    out out_id_domicilio int
	)
begin
    set @in_calle = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.Calle')));
    set @in_num_calle = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.Num')));
    set @in_colonia = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.Colonia')));
    set @in_codigo_postal = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_domicilio, '$.CP')));
    
	etiqueta: begin
		select (select id_domicilio from domicilio where 
            calle=@in_calle and num_calle=@in_num_calle and colonia=@in_colonia and codigo_postal=@in_codigo_postal);
        set out_id_domicilio=(select id_domicilio from domicilio where 
            calle=@in_calle and num_calle=@in_num_calle and colonia=@in_colonia and codigo_postal=@in_codigo_postal);
        if(out_id_domicilio is not null) then
            # ya existe el domicilio
            select 'ya existe el dom';
            leave etiqueta;
        end if;

		insert into domicilio(
        calle,num_calle,colonia,codigo_postal) values(
            @in_calle,@in_num_calle,@in_colonia,@in_codigo_postal
        );
        select 'domicilio insertado';
        set out_id_domicilio=(select last_insert_id());

	end etiqueta;
end //
DELIMITER ;

DELIMITER //
create procedure insertarInstitucion(
    in datos_inst JSON,
    out out_id_institucion int
	)
begin
	select datos_inst as 'JSON institucion';
    set @in_nombre=nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Institucion')));
    set @in_rep_legal=nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Persona_objetivo')));
    set @in_cargo=nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Cargo')));
    
    set @in_rfc=nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.RFC')));
    set @in_telefono = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_inst, '$.datos.Telefono')));
    
    set @domicilio=JSON_EXTRACT(datos_inst, '$.domicilio');
    set @id_dom = 0;
	select @in_nombre, @in_rep_legal, @in_cargo, @id_dom , @in_rfc,@in_telefono;

    etiqueta: begin
		call insertarDomicilio (@domicilio, @id_dom);
        
        select id_institucion,(nombre_institucion=@in_nombre and representante_legal=@in_rep_legal and cargo_representante_legal= @in_cargo
            and id_domicilio=@id_dom and telefono=@in_telefono)
            into out_id_institucion, @concuerdan_datos from institucion where rfc=@in_rfc order by id_institucion desc LIMIT 1;

        if(out_id_institucion is null or not @concuerdan_datos) then     
            -- no existe la institucion
            -- parece ser la misma, pero con diferentes datos
            insert into institucion
                (nombre_institucion,representante_legal,cargo_representante_legal,
                    id_domicilio,RFC,telefono) 
                values(
                    @in_nombre, @in_rep_legal, @in_cargo, @id_dom , @in_rfc,@in_telefono
                );
            set out_id_institucion=(select last_insert_id());
        end if;
    end etiqueta;
end //
DELIMITER ;

DELIMITER //
create procedure insertarSolicitante(
    in datos_solicitante JSON,
    out out_id_solicitante int,
    out out_id_domicilio int
)
begin
    select JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.No_Control'));
    set @in_num_de_control = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.No_Control')));

    etiqueta: begin
        set out_id_solicitante = (select id_solicitante from solicitante where num_de_control=@in_num_de_control);
        call insertarDomicilio( JSON_EXTRACT(datos_solicitante,'$.domicilio') , out_id_domicilio);
        
        set @in_curp = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.Curp')));
        set @in_correo = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.Correo_Institucional')));
        set @in_id_sexo=(select id_sexo from sexo where sexo= nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.Sexo'))) );
        
        if(out_id_solicitante is not null) then 
            select 'ya existe solicitante';
            if(@in_curp is not null and @in_correo is not null and @in_id_sexo is not null) then
				select out_id_solicitante as 'hay que actualizar al solic ';
                update solicitante set curp=@in_curp, correo_institucional=@in_correo, id_sexo=@in_id_sexo where id_solicitante=out_id_solicitante;
            end if;
            leave etiqueta;
        end if;
        
        set @in_apellido_paterno = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.Apellido_paterno')));
        set @in_apellido_materno = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.Apellido_materno')));
        set @in_nombres = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos_solicitante,'$.datos.Nombres')));
        /*
        apellido_paterno VARCHAR(30),
    apellido_materno VARCHAR(30),
    nombres VARCHAR(100),
    id_sexo INT DEFAULT 3,
    
    num_de_control CHAR(14),

    curp VARCHAR(18),
    correo_institucional VARCHAR(50),*/
        insert into solicitante(
            apellido_paterno,apellido_materno,nombres,
            num_de_control)
            values(
                @in_apellido_paterno,@in_apellido_materno,@in_nombres,
                @in_num_de_control);
        set out_id_solicitante=(select last_insert_id());
        if(@in_curp is not null and @in_correo is not null and @in_id_sexo is not null) then
			update solicitante set curp=@in_curp, correo_institucional=@in_correo, id_sexo=@in_id_sexo where id_solicitante=out_id_solicitante;
        end if;
    end etiqueta;
end //
-- DELIMITER ;
drop procedure hacerSolicitud;
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
            select 'ya habias hecho una solicitud';
            set out_id_solicitud=-1;
            leave etiqueta;
        end if;

        -- ('Curp','Edad','Sexo','Correo_Institucional')

		set @datos_institucion_json = JSON_EXTRACT(datos,'$.institucion');
        
		call insertarInstitucion(@datos_institucion_json,@out_id_institucion);        
		
		set @in_carrera = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Carrera')));
		set @in_semestre = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Semestre')));
		set @in_grupo = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Grupo')));
		-- set @in_turno = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Turno'));
		set @in_telefono = nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_solicitante_json,'$.datos.Telefono')));
		set @in_inicio = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Inicio')));
		set @in_termino = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Termino')));
		set @in_actividades = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Actividades')));
		set @in_apoyo = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Recibe_apoyo')));
		set @in_monto = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Monto')));
        set @in_fecha_entrega= nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Fecha_entrega')));

		set @id_turno= (select id_turno from turno where turno=(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Turno'))) );
		set @in_nom_proy = nullificar(JSON_UNQUOTE(JSON_EXTRACT(datos,'$.solicitud.datos.Nombre_proyecto')));
		set @in_edad = nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_solicitante_json,'$.datos.Edad')));
		
        set @tiene_apoyo=0;

		if(@in_apoyo='SI') then 
			set @tiene_apoyo=1;
		end if;

		select @out_id_solicitante,@id_tipo_s,@id_dom_solicitante, @in_telefono, @in_carrera, @in_semestre, @in_grupo,
			@id_turno, @id_institucion, @in_inicio, @in_termino, @in_actividades, @tiene_apoyo,
			@in_monto, @in_fecha_entrega, @in_nom_proy,@in_edad;
		insert into solicitud(
			id_solicitante,tipo_solicitud,id_domicilio_solicitante,telefono_solicitante,id_carrera,semestre,grupo,id_turno,
			id_institucion,fecha_inicio,fecha_termino,actividades,tiene_apoyo_economico,
			monto_apoyo_economico,fecha_entrega_solicitud,fecha_registro,estado_solicitud,

			nombre_proyecto,edad_solicitante
		) values(
			@out_id_solicitante,@id_tipo_s,@id_dom_solicitante, @in_telefono, (select id_carrera from carreras where nombre=@in_carrera), @in_semestre, @in_grupo,
			@id_turno, @out_id_institucion, @in_inicio, @in_termino, @in_actividades, @tiene_apoyo,
			@in_monto, @in_fecha_entrega, now(), 0,

			@in_nom_proy,@in_edad
		);
		set out_id_solicitud=(select last_insert_id());
        
        if(@id_tipo_s-1) then
			-- es una solicitud de practicas
            set @in_giro =nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_institucion_json, '$.otros_detalles.Giro')));
            set @in_jefe_inmediato =nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_institucion_json, '$.otros_detalles.Jefe_inmediato')));
            set @in_tel =nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_institucion_json, '$.otros_detalles.Tel_j_i')));
            set @in_cargo =nullificar(JSON_UNQUOTE(JSON_EXTRACT(@datos_institucion_json, '$.otros_detalles.Cargo_j_i')));
        
            update institucion set giro=@in_giro where id_institucion=@out_id_institucion;

            insert into detalles_institucion_para_practicas 
                (jefe_inmediato,cargo_jefe_inmediato,telefono_jefe_inmediato, id_solicitud) 
            values (
                @in_jefe_inmediato,@in_cargo,@in_tel, out_id_solicitud
            );

        end if; 
    end etiqueta;
end //
DELIMITER ;


DELIMITER //

CREATE FUNCTION nullificar(dato varchar(100))
RETURNS varchar(100)
DETERMINISTIC -- o NO DETERMINISTIC si puede variar el resultado
BEGIN
    if(dato='null') then
		return null;
    end if;
    return dato;
END //
DELIMITER ;