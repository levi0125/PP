from flask import Flask, render_template, request, redirect, url_for, flash,send_file
from db.conexion import Conexion
from docx import Document
import json
import io
#pip install python-docx
cx=None
app = Flask(__name__)
cx=Conexion('SSPP','1','DB.sql')
# call hacerSolicitud(
# 	'{"institucion": {"datos": {"Institucion": "CENTRO DE ESTUDIOS TECNOLOFIOCOS INDUSTRIAL Y DE SERVICIOS NO 155", "Persona_objetivo": "AMIRA", "Cargo": "DIRECTORA", "RFC": null, "Telefono": "4496368159"}, "domicilio": {"Calle": "AV PERSEO", "Num": "99", "Colonia": "PRIMO VERDAD", "CP": "20130"}}, "solicitante": {"datos": {"Apellido_paterno": "PEREZ", "Apellido_materno": "BERNAL", "Nombres": "MARTIN ALEJANDRO", "Sexo": null, "No_Control": "22301061550038", "Edad": null, "Curp": null, "Correo_Institucional": null, "Telefono": "4491261629"}, "domicilio": {"Calle": "ALBINO GARCIA", "Num": "110", "Colonia": "MORELOS I", "CP": "20298"}}, "solicitud": {"datos": {"Carrera": "PROGRAMACION", "Semestre": "6", "Grupo": "A", "Turno": "Matutino", "Inicio": "2025-08-04", "Termino": "2025-09-07", "Actividades": "GENERAR UNA PLANTILLA PARA AUTOMATIZAR EL TRAMITE DE SS Y PP", "Recibe_apoyo": "NO", "Monto": null}}}'
#     ,"Servicio Social",@id_s);
@app.route('/')
def home():
    # datos={
    #     "institucion":{
    #         "datos":{
    #             "Institucion":cambiarFormato("cetis 155 Otilio Montaños","Mayus"),
    #             "Persona_objetivo":cambiarFormato("Cra. almira ivette Jauregui Pérez","titulo"),
    #             "Cargo":cambiarFormato("Directora","Mayus"),
    #             'RFC':cambiarFormato("ccc191129574","Mayus"),
    #             "Telefono":cambiarFormato("4496368159")
    #         },
    #         "domicilio":{
    #             "Calle":cambiarFormato("av. perseo","titulo"),
    #             "Num":cambiarFormato("99"),
    #             "Colonia":cambiarFormato("Primo Verdad","Mayus"),
    #             "CP":cambiarFormato("20130"),
    #         }
            
    #     },
    #     "solicitante":{
    #         "datos":{
    #             "Apellido_paterno":cambiarFormato("perez","Mayus"),
    #             "Apellido_materno":cambiarFormato("bernal","Mayus"),
    #             "Nombres":cambiarFormato("martin aljandro","Mayus"),
    #             "Sexo":cambiarFormato("M","Mayus"),
    #             "No_Control":cambiarFormato("22301061550038"),
                
    #             "Edad":cambiarFormato("18"),
    #             "Curp":cambiarFormato("pebm070206hasrrra5","Mayus"),
    #             "Correo_Institucional":cambiarFormato("Correo_Institucional"),
    #             "Telefono":cambiarFormato("4491261629")
    #         },
    #         "domicilio":{
    #             "Calle":cambiarFormato("Almendra Gomez","Mayus"),
    #             "Num":cambiarFormato("110"),
    #             "Colonia":cambiarFormato("Mariantonieta","Mayus"),
    #             "CP":cambiarFormato("20000"),
    #         }
    #     },
    #     "solicitud":{
    #         "datos":{
    #             "Carrera":cambiarFormato("Programacion","mayus"),
    #             "Semestre":cambiarFormato("6"),
    #             "Grupo":cambiarFormato("a","mayus"),
    #             "Turno":cambiarFormato("matutino","Capital"),

    #             "Inicio":cambiarFormato("2024-09-02"),
    #             "Termino":cambiarFormato("2025-03-2025"),
    #             "Actividades":cambiarFormato("aseo"),
    #             "Recibe_apoyo":cambiarFormato("NO"),
    #             "Monto":None
    #         }
    #     }
    # }
    # print(json.dumps(datos))
    # cx.callProcedure("hacerSolicitud",(json.dumps(datos),"Servicio Social","@id_mi_solicitud"))

    return render_template("home.html")

def busquedaEnDicc(dicc,busqueda):
    if(not dicc):
        return ""
    for nivel in busqueda.split("."):
        dicc=dicc.get(nivel) 
        if(not isinstance(dicc,dict)):
            #ejecutado si llegas a un directorio del dicc que es un valor, no otro nivel

            return dicc
    return dicc #el usuario quiere un diccionario dentro del mismo diccionario

def cambiarFormato(texto,formato=None):
    if(not texto):
        return None
    if(formato=="Mayus"): # UN EJEMPLO
        return texto.upper()
    if(formato=="Capital"):# Un ejemplo
        return texto.capitalize()
    if(formato=="Minus"): # un ejemplo
        return texto.lower()
    if(formato=="titulo"): # Un Ejemplo
        return texto.title()
    return texto


def getFormField(request,field_name,missing_data,formato="Mayus"):
    field_value=cambiarFormato(request.form.get(field_name),formato)
    if(not field_value):
        missing_data[field_name]=1
        # missing_data.append(field_name)
    return field_value

def crearJSONpDatos(request):
    missing_data={}
    return {
        "institucion":{
            "datos":{
            "Institucion":getFormField(request,"Institucion",missing_data),
            "Persona_objetivo":getFormField(request,"Persona-objetivo",missing_data),
            "Cargo":getFormField(request,"Cargo",missing_data),
            'RFC':getFormField(request,'RFC',missing_data),
            "Telefono":getFormField(request,"Telefono-institucion",missing_data)
            },
            "domicilio":{
                "Calle":getFormField(request,"Calle-institucion",missing_data),
                "Num":getFormField(request,"Num-institucion",missing_data),
                "Colonia":getFormField(request,"Colonia-institucion",missing_data),
                "CP":getFormField(request,"CP-institucion",missing_data),
            }
            
        },
        "solicitante":{
            "datos":{
            "Apellido_paterno":getFormField(request,"Apellido-paterno",missing_data),
            "Apellido_materno":getFormField(request,"Apellido-materno",missing_data),
            "Nombres":getFormField(request,"Nombres",missing_data),
            "Sexo":getFormField(request,"Sexo",missing_data),
            "No_Control":getFormField(request,"No-Control",missing_data),
                
            "Edad":getFormField(request,"Edad",missing_data),
            "Curp":getFormField(request,"Curp",missing_data),
            "Correo_Institucional":getFormField(request,"Correo-Institucional",missing_data),
            "Telefono":getFormField(request,"Telefono",missing_data)
            },
            "domicilio":{
                "Calle":getFormField(request,"Calle",missing_data),
                "Num":getFormField(request,"Num",missing_data),
                "Colonia":getFormField(request,"Colonia",missing_data),
                "CP":getFormField(request,"CP",missing_data),
            }
        },
        "solicitud":{
            "datos":{
            "Carrera":getFormField(request,"Carrera",missing_data),
            "Semestre":getFormField(request,"Semestre",missing_data).replace("°",""),
            "Grupo":getFormField(request,"Grupo",missing_data),
            "Turno":getFormField(request,"Turno",missing_data,"Capital"),
            "Fecha_entrega":getFormField(request,"Fecha-entrega",missing_data),

            "Inicio":getFormField(request,"Inicio",missing_data),
            "Termino":getFormField(request,"Termino",missing_data),
            "Actividades":getFormField(request,"Actividades",missing_data),
            "Recibe_apoyo":getFormField(request,"Recibe-apoyo",missing_data),
            "Monto":getFormField(request,"Monto",missing_data) 
            }
        }
    },missing_data

@app.route("/solicitudServicio", methods=['POST','GET'])
def solicitarSS():
    selects={}
    cx.execute_query("select sexo from sexo")
    selects["sexo"]=cx.getFetch()
    cx.execute_query("select nombre from carreras")
    selects["carreras"]=cx.getFetch()
    
    if(request.method=="GET"):
        return render_template("solicitudSS.html",datos=None,abrirDicc=busquedaEnDicc,selects=selects)
    msj=""
    datos,missing_data=crearJSONpDatos(request)

    if("Monto" in missing_data and datos["solicitud"]["datos"]["Recibe_apoyo"]=="SI"):
        msj="Debes ingresar el Monto"
    elif (len(missing_data)>0 and not("Monto" in missing_data) ):
        msj="Debes llenar todos los campos("+str(missing_data)+")"
        print(missing_data)
    else:
        print("json=",json.dumps(datos))
        id_solicitud=cx.callProcedure("hacerSolicitud",(json.dumps(datos),"Servicio Social","@id_solic"))
        if(isinstance(id_solicitud, BaseException)):
            #nos devolvió una excepcion
            msj="Excepcion:"+str(id_solicitud)
        else:
            print("pre id soli:",id_solicitud)
            cx.execute_query("select @id_solic")
            id_solicitud=cx.getFetch()[0][0]
            print("id soli:",id_solicitud)
            if(id_solicitud==None or id_solicitud=="-1"):
                msj="No puedes enviar mas de una solicitud del mismo tipo"
            else:
                msj="Se envió la solcitud:"+str(id_solicitud)

    return render_template("solicitudSS.html",mensaje=msj,datos=datos,abrirDicc=busquedaEnDicc,selects=selects)
    
    # campos="Apellido-paterno,Apellido-materno,nombres,curp,edad,sexo," \
    #     "Calle,Num,Colonia,CP,Telefono," \
    #     "No-Control,Carrera,Correo-Institucional,semestre,Grupo,Turno," \
    #     "Institucion,Persona-objetivo,Cargo," \
    #     "Calle-institucion,Num-institucion,Colonia-institucion,CP-institucion,Telefono-institucion,RFC," \
    #     "Inicio,Termino,Actividades,recibe-apoyo,monto".split(",")
    

@app.route("/solicitudPracticas",methods=['POST','GET'])
def solicitarPP():
    selects={}
    cx.execute_query("select sexo from sexo")
    selects["sexo"]=cx.getFetch()
    cx.execute_query("select nombre from carreras")
    selects["carreras"]=cx.getFetch()
    if(request.method=="GET"):
        return render_template("solicitudPP.html",datos=None,abrirDicc=busquedaEnDicc,selects=selects,practicas=True)
    msj=""
    # sin :
    #       curp, edad, sexo, correo institucional

    #recibe :
        # nombre/razon = 'institucion'
        # representante legal = 'Persona-objetivo'
        # Giro,  Jefe-inmediato, tel-j-i, Cargo-j-i, nombre-proyecto
    datos,missing_data=crearJSONpDatos(request)

    datos['institucion']['otros-detalles']={
        "Giro":getFormField(request,"Giro",missing_data),
        "Jefe_inmediato":getFormField(request,"Jefe-inmediato",missing_data),
        "Tel_j_i":getFormField(request,"Tel-j-i",missing_data),
        "Cargo_j_i":getFormField(request,"Cargo-j-i",missing_data)
    }
    datos['solicitud']['datos']["Nombre_proyecto"]=getFormField(request,"Nombre-proyecto",missing_data)

    if("Monto" in missing_data and datos["solicitud"]["datos"]["Recibe_apoyo"]=="SI"):
        msj="Debes ingresar el Monto"
    else :
        if(len(missing_data)>0 ):
            pequeñasColiciones=0
            for campo in ("Curp","Edad","Sexo","Correo_Institucional"):
                if(campo in missing_data):
                    pequeñasColiciones+=1
            if(pequeñasColiciones-len(missing_data)>0):
                msj="Debes llenar todos los campos"
                print(missing_data)
        if(msj==""):
            print("json=",json.dumps(datos))
            id_solicitud=cx.callProcedure("hacerSolicitud",(json.dumps(datos),"Practicas Profesionales","@id_solic"),True)
            if(isinstance(id_solicitud, BaseException)):
                #nos devolvió una excepcion
                msj=str(id_solicitud)
            else:
                cx.execute_query("select @id_solic")
            id_solicitud=cx.getFetch()[0][0]
            if(id_solicitud==None):
                msj="No puedes enviar mas de una solicitud del mismo tipo"
            else:
                msj="Se envió la solcitud:"+str(id_solicitud)
    
    return render_template("solicitudPP.html",mensaje=msj,datos=datos,abrirDicc=busquedaEnDicc,selects=selects,practicas=True)

@app.route("/solicitudes")
def listarSolicitudes():
    cx.execute_query("""select 
	s.id_solicitud,ste.nombres,ste.apellidoPaterno,ste.apellidoMaterno,ste.num_de_control,t.tipo,s.fecha_entrega_solicitud
FROM solicitud s
    LEFT JOIN solicitante ste ON ste.id_solicitante = s.id_solicitante 
    LEFT JOIN tipoSolicitud t on t.id_tipo=s.tipo_solicitud
order by apellidoPaterno""")
    solicitudes=cx.getFetch()

    return render_template("solicitudes.html",solicitudes=solicitudes)

@app.route("/solicitud:<int:id>")
def obtener_solicitud(id):
    cx.execute_query("""SELECT 
    s.id_solicitud, s.tipo_solicitud, ste.*, s.telefono_solicitante, edad_solicitante, c.nombre,
    s.semestre, grupo, t.turno, s.fecha_inicio, s.fecha_termino, s.actividades,
    tiene_apoyo_economico, monto_apoyo_economico, fecha_entrega_solicitud, nombre_proyecto,
    i.*
FROM solicitud s
    LEFT JOIN solicitante ste ON ste.id_solicitante = s.id_solicitante
    LEFT JOIN domicilio d ON d.id_domicilio = s.id_domicilio_solicitante
    LEFT JOIN turno t ON t.id_turno = s.id_turno
    LEFT JOIN carreras c ON c.id_carrera = s.id_carrera
    LEFT JOIN institucion i ON i.id_institucion = s.id_institucion where s.id_solicitud=%s""",(id))

    return str(cx.getFetch()[0])

@app.route("/documento")
def generar_documento():
    # Cargar plantilla
    doc = Document('documentos_plantilla/prueba.docx')
    
    # Variables a insertar
    variables = {
        '{{ nombre }}': 'Juan Pérez'
        #,'{{ edad }}': '30'
    }

    # Reemplazar variables en cada párrafo
    for p in doc.paragraphs:
        for key, value in variables.items():
            if key in p.text:
                p.text = p.text.replace(key, value)

    # Guardar en memoria
    buffer = io.BytesIO()
    doc.save(buffer)
    buffer.seek(0)

    return send_file(
        buffer,
        as_attachment=True,
        download_name='documento_generado.docx',
        mimetype='application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    )

if __name__ == "__main__":
    app.run(debug=True)
