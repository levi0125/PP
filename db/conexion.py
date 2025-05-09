import pymysql
from colorama import init, Fore, Back, Style
if(__name__=="__main__"):
    from open import SQLFile
else:
    from .open import SQLFile

class Conexion:
    conn=None
    archivoVersion='dbVersion.txt'
    print=True
    cursor=False
    db=None
    fetch= False

    instrucciones=["use","insert","select","update","delete",'create',"drop"]
    
    
    def __init__(self,database=None,version=None,archivoSQL=None):
        if(database==None and version==None and archivoSQL==None):
            print(self.detectar_Instruccion('use schema infinito'))
            return 
        
        self.makeConexionSQL()
        self.db=database
        ejecutar_procedures=False
        self.version= version
        self.archivoSQL=archivoSQL
        
        self.cursor = self.conn.cursor()

        self.version_tablas=self.getArchivoVersionDB()
        if (self.version_tablas!=None):
            vers=self.version_tablas.split(":")
            if (len(vers)==1):
                pass
            elif (vers[1])=="p":
                print("debe ejecutar procedures")
                #hay que ejecutar procedures.sql
                self.version_tablas=(vers[0])
                ejecutar_procedures=True

        self.conectarDB(version)

        if(ejecutar_procedures):
            self.execute_query(f"SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = '{self.obtenerBD()}'")
            for procedimiento in self.getFetch():
                print(procedimiento)
                self.execute_query("DROP PROCEDURE "+procedimiento[0])
            self.executeSQLFile("procedures.sql",self.extension)
    def obtenerBD(self):
        if(self.extension==None or self.extension=="1"):
            return self.db
        return self.db+"_"+self.extension
    
    def getArchivoDir(self,archivo):
        return f'db/{archivo}'
    
    def getArchivoVersionDB(self):
        try:
            return open(self.getArchivoDir(self.archivoVersion),'r').read()
        except Exception:
            open(self.getArchivoDir(self.archivoVersion),'x')
            #open(self.getArchivoDir(self.archivoVersion),'w').write()
            return ''
    
    def setNewFileVersion(self,version):
        open(self.getArchivoDir(self.archivoVersion),'w').write(f'{version}')
    
    def makeConexionSQL(self):
        try:
            self.conn= pymysql.connect(host='localhost', port=3306 , user='root', password="risemivicio125",charset="utf8mb4")
            #    print("Conexion 1")
        except Exception:
            self.conn= pymysql.connect(host='localhost', port=3306, user='root', password="",charset="utf8mb4")
            #    print("Conexion 2")
            
    def execute_query(self,query,args=None):
        try:
            #print(Back.MAGENTA+query+Back.RESET)
            if( self.print):
                print(query)
            else:
                print(query[:50])
            ##Ejecuta la consulta
            self.cursor.execute(query,(None if args==None else args) )
            #continua si la expresion es posible
            
            #detecta la instruccion principal de la consulta
            c=self.detectar_Instruccion(query)
            print(f"{Back.CYAN}___Consulta exitosa{Back.RESET}")

            #    print(f"c={c}")
            if c==2:
                self.fetch=self.cursor.fetchall()
            else:
                self.conn.commit()
                
            return 1
        except Exception as e:
            ##consulta mal formulada o imposible
            if( self.print==False):
                print(f'!========{query}!=======')
            print(f"{Back.RED}____________>Fallo La consulta{Back.RESET}({e})")
            print()
            return -1
    
    def callProcedure(self,procedureName,parametersTuple=None,returnFetch=False):
        print(f"{Back.LIGHTMAGENTA_EX}invocando el procedimiento {procedureName}{Back.RESET}")
        try:
            if parametersTuple!=None: 
                self.cursor.callproc(procedureName,parametersTuple)            
            else:
                self.cursor.callproc(procedureName)
            self.conn.commit()

        except Exception as e:
            print(e)
            return e
        
        if (returnFetch):
            return self.cursor.fetchall()
    
    def detectar_Instruccion(self,query):
        #    print("  __det consult")
        query=query.lower()    
        SinEspacios=query.replace(" ","").replace('\n','')

        c=0       
        
        for instrucc in self.instrucciones:
            if((SinEspacios.split(instrucc))[0]==""):
                return c
            c+=1
    
    def executeSQLFile(self,archivo,extension):
        self.file=SQLFile()
        #self.print=True
        self.showQuery(False)

        with open(self.getArchivoDir(archivo), "r",encoding="utf-8") as archivo:
            c=0
            bd=self.obtenerBD()
            #print('EXTENSION:',extension)
            while True:
                
                self.SqlQueries=self.file.getSQLines(archivo) 

                # print(f'{Back.GREEN}QUERYS:[')
                # print("\n.--".join(self.SqlQueries))
                # print(f'======<FIN{Back.RESET}')

                for i in self.SqlQueries:
                    #ubicamos la instuccion
                    #print(f'__i={i}')
                    i=i.replace('database','schema',1)
                    indexDB=i.find(self.obtenerBD())

                    # if(extension !=''):
                    #     print(f'{Back.WHITE}EXECUTE SIN PROBLEMAS__{Back.RESET}')
                    #     self.execute_query(i)

                    inst=self.detectar_Instruccion(i)
                    # if(indexDB!=-1):
                    #     # hay que hacer una operacion en la db ya que nuestra DB tuvo que ser renombrada por una extension          
                    #     print('EXECUTE CON UNA PEQUEÑA MODIFICACION')

                    divididos=i.split('begin')

                    if (len(divididos)>1 and extension !='' and indexDB!=-1):
                        dbChanged=[]
                        #estamos trabajando una funcion/ bloque begin...end
                        # a su vez la db tiene un nombre repetido
                        # y aqui aparece el nombre de la db en algun lado

                        for instOfBlock in divididos[1].split(';'):
                            #recorremos las insrtrucciones del bloque y hay que remplazar las bd en caso de usarlas
                            # instOfBlock.lower().split(self.db.lower())
                            
                            dbChanged.append(self.corregirDB(instOfBlock,extension))
                        self.execute_query(divididos[0]+'begin\n'+';'.join(dbChanged))

                    else:
                        if(inst ==6 or inst ==5) and indexDB!=-1 and len(divididos)==1:
                            # requiere crear o borrar la db
                            # res=re.search('create schema',i,re.IGNORECASE)
                            print(f'{Back.MAGENTA}NEL PERRO, NO DEJARE QUE LE HAGAS {self.instrucciones[inst]}{Back.RESET}')
                        else:
                            if(extension==''):
                                self.execute_query(i)
                            else:
                                self.execute_query(i.replace(self.db,f'{bd}'))    
                
                if self.SqlQueries==[''] or self.SqlQueries==[]:
                    #print('PM:{',self.file.primera_mitad,'}')
                    print(f'{Back.RED}FIN DE LA LECTURA{Back.RESET}')
                    print(self.file.primera_mitad)
                    if(len(self.file.primera_mitad)>1):
                        self.execute_query(self.file.primera_mitad)
                    break
                c+=1
        self.showQuery(True)

    def corregirDB(self,query,extension):
        # aqui deberia de instanciar un objeto DBLocator cuando le de un algoritmo que funcione
        divd=query.lower().split(self.db.lower())
        #print(divd)
        c=0
        index=0
        db=self.obtenerBD()
        queryAdapted=''
        while index < len(divd):
            x=divd[index]
            print(f'{c}:({c+len(x)})')
            queryAdapted+=query[c:(c+len(x))]
            if(index!=len(divd)-1):
                queryAdapted+=db
            c+=len(x)+10
            index+=1
        return queryAdapted

    def crear_DB(self,extension):
        bd=self.obtenerBD()
        self.execute_query(f"drop schema if exists {bd}")
        #self.execute_query(f"create schema {bd}")
        self.execute_query(f"create schema {bd} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;")

        self.execute_query(f"use {bd}")
        
        query='create table version( version int not null);'
        self.execute_query(query)
        query='insert into version values(%s);'%(self.version_tablas or 1)
        self.execute_query(query)

        self.executeSQLFile(self.archivoSQL,extension)

        

    def getFromVersion(self):
        r=self.execute_query('select version from version')
        if r==-1:
            return None
        return self.getFetch()[0]
        
    def conectarDB(self,extension):
        # print("\n\n\n CONECTAR")
        print('conectar')
        use="use "+self.db
        print("extension= ",extension)
        if extension!='1' and extension!=None:
            #no es un nombre unico para una bd, asi que agregemosle el numero de spiderman que somos
            use+=f'_{extension}'

        if self.execute_query(use)==-1:
            print('No existe la db')
            #fallo la conexion a la db
            #no existe
            if self.version_tablas!=extension:
                # la extension/version libre de la db no concuerda con la marcada en el archivo de Version
                
                self.setNewFileVersion(extension if extension!='' else 1)
            self.extension=extension
            self.crear_DB(extension)
            return 
        #existe la db
        print("EXISTE LA DB")
        return #agregado momentameamente, en lo que vuelvo a reparara el ejecutor sql
        #select a la tabla version en la DB
        ver=self.getFromVersion()
        if ver ==None:
            print('no es nuestra db(no existe tabla version)')
            #no esta agregada la tabla de version, es decir, no es nuestra base de datos
            if extension=="": 
                #es el primer fallo
                self.conectarDB("1")
            else: 
                #ya van varias bd a las que se intento conectar
                self.conectarDB(str(int(extension)+1))
            return
        print(f'VERSION ={ver[0]}')
        print(f'VERSION 2 ={self.version_tablas}')
        self.extension=extension

        if int(ver[0])!=int(self.version_tablas):
            print('la db esta desactualizada')
            # el campo version en la DB no concuerda con el que deberia ser
            self.crear_DB(extension)
            return 
        else:
            print('DB ACTUAL SIN NECESIDAD DE CAMBIOS')

    def getFetch(self):
        return self.fetch
    
    def reiniciarContatorAuto(self,tabla):
        self.execute_query(f"ALTER TABLE {tabla} AUTO_INCREMENT=0")
    
    def close(self):
        self.conn.close()
        self.cursor.close()
    
    def showQuery(self,booleano):
        self.print=booleano

if(__name__=="__main__"):
    cx=Conexion('SSPP','1','DB.sql')
    # datos='{"institucion": {"datos": {"Institucion": "HOSPITAL TERCER MILENIO", "Persona_objetivo": "ALGUIEN", "Cargo": "DIRECTORA GENERAL", "RFC": "CC389ASSC", "Telefono": "444912839"}, "domicilio": {"Calle": "ALSDMA", "Num": "123", "Colonia": "MKMLADSM S", "CP": "2033"}, "otros-detalles": {"Giro": "SERVICIOS", "Jefe_inmediato": "HERNANDEZ HERNANDEZ", "Tel_j_i": "44912892039", "Cargo_j_i": "JEFE DE SERVICIO AL CLIENTE"}}, "solicitante": {"datos": {"Apellido_paterno": "AGUILAR", "Apellido_materno": "MARTIN", "Nombres": "PEREZ", "Sexo": null, "No_Control": "22301061551234", "Edad": null, "Curp": null, "Correo_Institucional": null, "Telefono": "4498889999"}, "domicilio": {"Calle": "UNA CALLE", "Num": "15", "Colonia": "GRANADITAS", "CP": "30456"}}, "solicitud": {"datos": {"Carrera": "SOPORTE Y MANTENIMIENTO DE EQUIPO DE COMPUTO", "Semestre": "6", "Grupo": "A", "Turno": "Vespertino", "Fecha_entrega": null, "Inicio": "2025-09-03", "Termino": "2025-10-09", "Actividades": "VIGILANCIA", "Recibe_apoyo": "NO", "Monto": null, "Nombre_proyecto": "VIGILANCIA SUPREMA"}}}'
    # cx.callProcedure("hacerSolicitud",(datos,"Servicio Social","@id_solic"))