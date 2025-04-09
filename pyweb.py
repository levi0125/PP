import webview
from openFile import openFile
#apt install python3-webview
#pip install pywebview


#html=open("/home/martin/Desktop/PP/templates/index.html").read()
html=openFile("./templates/index.html").read()

webview.create_window('Mi App', html=html)

webview.start()