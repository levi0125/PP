from flask import Flask, render_template, request, redirect, url_for, flash
from db.conexion import Conexion

app = Flask(__name__)

@app.route('/')
def home():
    return render_template("home.html")

@app.route("/solicitudServicio", methods=['POST','GET'])
def solicitarSS():
    if(request.method=="GET"):
        return render_template("solicitudSS.html")

@app.route("/solicitudPracticas",methods=['POST','GET'])
def solicitarPP():
    if(request.method=="GET"):
        return render_template("solicitud")

if __name__ == "__main__":
    app.run(debug=True)