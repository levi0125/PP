CREAR ENTORNO VIRTUAL

python3 -m venv venv
source venv/bin/activate

CREAR EJECUTABLE:

pyinstaller --onefile --add-data "templates:templates" --add-data "static:static" pyweb.py

ABRIR EJECUTABLE:
cd dist
./pyweb

