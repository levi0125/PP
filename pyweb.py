import webview
#apt install python3-webview
#pip install pywebview


html = '''
<html>
  <body>
    <h1>Hola desde HTML</h1>
  </body>
</html>
'''

html=open("./templates/index.html").read()

webview.create_window('Mi App', html=html)
webview.start()