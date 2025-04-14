from flask import Flask, render_template, request, redirect, url_for, flash
from db.conexion import Conexion
from docx import Document
import io
#pip install python-docx

app = Flask(__name__)

@app.route('/')
def home():
    return render_template("home.html")

@app.route("/solicitudServicio", methods=['POST','GET'])
def solicitarSS():
    if(request.method=="GET"):
        return render_template("solicitudSS.html")

    campos="apellido-paterno,apellido-materno,nombres,curp,edad,sexo,sexo,Calle,Num,Colonia,CP,Telefono,No-Control,Carrera,Correo-Institucional,semestre,Grupo,Turno,Institucion,Persona-objetivo,Cargo,Calle-institucion,Num-institucion,Colonia-institucion,CP-institucion,Telefono-institucion,RFC,Inicio,Termino,Actividades,recibe-apoyo,monto".split(",")
    datos={}
    vacios=[]
    for campo in campos:
        datos[campo]=request.form.get(campo) 
        print(datos[campo])
        if(datos[campo]==""):
            vacios.append(campo)
            #return "HUBO UN CAMPO VACIO:"+campo
    

@app.route("/solicitudPracticas",methods=['POST','GET'])
def solicitarPP():
    if(request.method=="GET"):
        return render_template("solicitud")

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
