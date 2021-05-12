#!/bin/bash

path=$(cd `dirname $0`; pwd)											#obtenemos la ruta del menu.sh

###########################################################
#                  1) INSTALL APACHE                     #
###########################################################
function apacheInstall()
{																		#si se instala en un sistema nuevo es necesario
	sudo apt update
	sudo apt install build-essential
	sudo apt install aptitude 										
	sudo apt install firefox
	aux=$(aptitude show apache2 | grep "State: installed")
	aux2=$(aptitude show apache2 | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]													# if_[_-z_"$aux"_] ESPACIOS -z significa que la variable esta vacia
	then 
 	  echo -e "instalando ...\n"										#echo -e (necesario para \n) \n salto de linea
 	  sudo apt-get install apache2
	else
   	  echo -e "apache ya estaba instalado\n"
    
	fi 
}

###########################################################
#                  2) INICIAR APACHE                      #
###########################################################

function apacheStart() {
	ps -aux | grep apache2 | grep -v grep								#ps = procesos actuales / -a procesos de otros usuarios / -u procesos del usuario que ejecuta ps / -x procesos no controlados por ninguna terminal  
	if [ $? != 0 ]														#Codigo de salida del pipe más reciente, equivalente a aux = comand1 | comand2
	then
		echo -e "inicializando apache...\n"
		/etc/init.d/apache2 start
	else
		echo -e "apache ya está iniciado\n"
	fi
} 

###########################################################
#                3) TESTEAR PUERTO 80                     #
###########################################################

function apacheTets() {
	aux=$(aptitude show net-tools | grep "State: installed")
	aux2=$(aptitude show net-tools | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
		echo "instalando net-tools"
		sudo apt install net-tools
	fi
	sudo netstat -anp | grep "apache2" | grep :80						#netstat -anp ver puertos abiertos, usar netstat -help si hay dudas
}

###########################################################
#                 4) VER HOJA POR DEFECTO                 #
###########################################################
function apacheIndex(){
	echo -e "¿Quieres abrir la página web por defecto?(S/N)\n"
	read respuesta
	if [[ $respuesta == "S" || $respuesta == "s" ]]
		then
			firefox http://localhost
		fi
}

###########################################################
#                 5) CAMBIAR INDEX                        #
###########################################################
function personalIndex(){
	
	echo -e "Se va a cambiar la página HTML por defecto\n"
	sudo cp ./index.html /var/www/html
	sudo cp -r grupo /var/www/html
	firefox http://127.0.0.1/index.html
}

###########################################################
#                 6) CREAR VIRTUAL HOST                   #
###########################################################
function createVirtualHost(){
	#sudo rm /etc/apache2/sites-available/laguntest.conf
	cd /var/www
	sudo mkdir laguntest
	cd laguntest
	sudo mkdir -p public_html												#caperta para los usuarios del programa que solo podran acceder a esto
	sudo cp /var/www/html/index.html /var/www/laguntest/public_html/
	sudo chown -R www-data:www-data /var/www/laguntest/public_html			#change owner -Recursivo usuario:grupo archivo
	sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laguntest.conf #fichero estandar con la configuracion de apache2
	sudo sed -i "s/80/8888/g" /etc/apache2/sites-available/laguntest.conf	#sed sirve para cambiar partes de un archivo sin tener que abrirlo / -i insertar de forma permanente / "s(sustituir)/lo que se borra/lo que se escribe/g (todas las apariciones)" [ruta de archivo]
	sudo sed -i "s/\/var\/www\/html/\/var\/www\/laguntest\/public_html/g" /etc/apache2/sites-available/laguntest.conf #si hay que modificar texto en el que salen / se añade \ antes de la barra 
	sudo sed -i "s/<\/VirtualHost>/\<Directory \/var\/www\/laguntest\/public_html\>\nOptions Indexes FollowSymLinks MultiViews\nAllowOverride All\nOrder allow,deny\nallow from all\n<\/Directory>\n<\/VirtualHost>\n/g" /etc/apache2/sites-available/laguntest.conf
	aux2=$(grep 8888 /etc/apache2/ports.conf)
	echo $aux2
	if [ -z "$aux2" ]
	then
		echo -e "Añadiendo puerto Listen 8888\n"    
		sudo sed -i "s/Listen 80/Listen 80\nListen 8888/g"  /etc/apache2/ports.conf
		sleep 1
	else
		echo -e "Ya esta añadido\n"    
	fi
	cd /etc/apache2/sites-available
	sudo a2ensite laguntest.conf
	sudo systemctl reload apache2
	sudo systemctl start apache2
}

###########################################################
#                 7) VIRTUAL HOST TEST                    #
###########################################################

function virtualhostTest() {
	firefox http://127.0.0.1:8888
}

###########################################################
#                 8) INSTALAR MODULO PHP                  #
###########################################################

function phpInstall() {
	aux=$(aptitude show php | grep "State: installed")
	aux2=$(aptitude show php | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
			echo -e "Instalando el modulo php ...\n"    
    		sudo apt install php libapache2-mod-php
    		sudo systemctl restart apache2
    		echo -e "El modulo php se ha instalado correctamente\n"    
    		sleep 1
		else
    #PHP instalado
    		echo -e "PHP ya estaba instalado \n"     
    		sleep 1
		fi
}

###########################################################
#                 9) TESTEAR EL MODULO PHP                #
###########################################################

function phpTest(){
    sudo echo "<?php phpinfo(); ?>" > test.php								#pasar el comando a test.php
	sudo cp test.php /var/www/laguntest/public_html		
	sudo chown -R www-data:www-data /var/www/laguntest/public_html
    firefox http://127.0.0.1:8888/test.php
}

###########################################################
#                 10) INSTALAR PAQUETES UBUNTU            #
###########################################################

function instalandoPaquetesUbuntuLagunTest() {
	#INSTALAR PYTHON3-PIP
	aux=$(aptitude show python3-pip | grep "State: installed")
	aux2=$(aptitude show python3-pip | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
		echo -e "Instalando python3-pip... \n"
		sudo apt install python3-pip
		sudo python3 -m  pip install --upgrade pip
		echo -e "El módulo se ha instalado correctamente \n"
		sleep 1
	else
		echo -e "python3-pip ya estaba instalado \n"
		sleep 1
	fi
	#INSTALAR DOS2UNIX
	aux=$(aptitude show dos2unix | grep "State: installed")
	aux2=$(aptitude show dos2unix | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
		echo -e "Instalando dos2unix... \n"
		sudo apt install dos2unix
		echo -e "El módulo se ha instalado correctamente \n"
		sleep 1
	else
		echo -e "dos2unix ya estaba instalado \n"
		sleep 1
	fi
	#INSTALAR LIBRSVG2-BIN
	aux=$(aptitude show librsvg2-bin | grep "State: installed")
	aux2=$(aptitude show librsvg2-bin | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
		echo -e "Instalando librsvg2-bin ... \n"
		sudo apt install librsvg2-bin 
		echo -e "El módulo se ha instalado correctamente \n"
		sleep 1
	else
		echo -e "librsvg2-bin ya estaba instalado \n"
		sleep 1
	fi
}
###########################################################
#           11) CREAR ENTORNO VIRTUAL DE PYTHON           #
###########################################################
function creandoEntornoVirutalPython3(){
	aux=$(aptitude show python3-pip | grep "State: installed")
	aux2=$(aptitude show python3-pip | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z aux3 ]
	then 
		instalandoPaquetesUbuntuLagunTest
	else
		pip3 install virtualenv
		cd /var/www/laguntest/public_html/
		if [ -d ".env" ]
		then
			echo -e "Entorno virtual creado\n"
			sleep 1	
		else
			sudo virtualenv -p python3 .env							#se crea el entorno virtual de python
		fi
	fi
}

###########################################################
#           12) INSTALAR LIBRERIAS PYTHON3                #
###########################################################

function instalandoLibreriasPythonLagunTest(){
	cd /var/www/laguntest/public_html
	pId=$(id -u)
	pGroup=$(id -g)
	sudo chown -R $pId:$pGroup .
	source /var/www/laguntest/public_html/.env/bin/activate
	sudo cp requirements.txt /var/www/laguntest/public_html/.env
	cd /var/www/laguntest/public_html/.env
	pip3 install -r requirements.txt
	deactivate
}

###########################################################
#           13) INSTALAR APLICACION LAGUNTEST             #
###########################################################

function instalandoAplicacionLaguntest(){								#copiar los archivos a la carpeta public_html
	echo -e "Instalando la aplicación...\n"
	sudo cp *.php *.sh *.py *.gif *.pem /var/www/laguntest/public_html/	#.pem necesario para conectarse al servidor creado
	sudo cp -r textos /var/www/laguntest/public_html/
}

###########################################################
#           14) PASAR LA PROPIEDAD WWW-DATA               #
###########################################################

function pasoPropiedad(){
	echo -e "Dando permisos a www-data...\n"
	sudo chown -R www-data:www-data /var/www
}

###########################################################
#             15) COMPROBAR WEBPROCESS.SH                 #
###########################################################

function comprobarWebprocess(){
	cd /var/www/laguntest/public_html/
	sudo chmod u+x webprocess.sh										#dar permisos de ejecucion a webprocess.sh
	sudo chown -R www-data:www-data /var/www/							#cambiar owner de toda la caperta	
	sudo -u root su - www-data -s /bin/bash								#cambiar de usuario
	#Ejecutar los siguientes comandos una vez cambiado el usuario para relizar la comprobación
	#cd /var/www/laguntest/public_html/
	#./webprocess.sh textos/english.doc.txt
	#Una vez realizado lo anterior: exit
}


###########################################################
#           16) VISUALIZAR LA APLICACION                  #
###########################################################

function visualizandoAplicacion(){
	firefox http://127.0.0.1:8888/index.php
}

###########################################################
#   17) VER LOS LOGS O ERRORES PRODUCIDOS POR APACHE      #
###########################################################

function viendoLogs(){
	echo -e 'visualizando el documento de errores..\n'
	tail -n100 /var/log/apache2/error.log								#ultimas 100 lineas
}

###########################################################
#           18) DESCRIBIR PASOS PARA INSTALAR SSH         #
###########################################################

function instalarSSH(){
	sudo aptitude install ssh 
	echo -e 'SSH (Secure Shell) es un software y protocolo que permite el acceso remoto a un servidor mediante un canal seguro con la información cifrada. También puedes usarlo para controlar otro dispositivo. El software suele venir instalado en dispositivos Linux pero por si acaso puedes instalarlo con "sudo aptitude install openssh-server".
	
	Para el cliente necesitas otro dispositivo. En Linux y Mac ya viene instalado el software necesario para poder conectarte a ellos, para Windows necesitarás el programa Putty. Para este proyecto proponemos conectarte a una instancia de Ubuntu de un servidor de aws. Esta instancia estará activa temporalmente y para representar el proceso completo la instancia partirá desde cero, es decir no tiene nada instalado y hay que pasarle los archivos del proyecto.  
	
	Para asegurarte de que SSH está activado usa usa "systemctl enable ssh" en tu ordenador.  
	Para conectarte al servidor necesitas el nombre de usuario, su IP y contraseña (opcional).
	Estos son los datos del servidor que hemos creado:
	IP: 13.51.85.233
	Usuario: Ubuntu
	Contraseña: hay que incluir la ruta de una clave .pem incluida en el proyecto

	Antes de nada es necesario cambiar los permisos de la clave .pem. Por si no está hecho usa "chmod 400 [path .pem]".
	Como este servidor no tiene los archivos tenemos que mandarselo. Para ello usaremos scp -i [path Contraseña.pem] -r [path proyecto] usuario@IP:[path destino].
	SCP (secure copy protocol) es un protocolo basado en SSH para el envío de archivos a servidores remotos.
	-i indica que enviamos la clave .pem y -r copia recursivamente todo el directorio. 
	El comando exacto que tendremos que introducir es:
	scp -i Claves.pem -r ../proyecto/ ubuntu@13.51.85.233:/home/ubuntu
	
	Ahora para conectarte al servidor usa "ssh -i [path Contraseña.pem] usuario@IP".
	En caso de querer conectarte al servidor proporcionado el comando será:
	ssh -i [path Contraseña.pem] Ubuntu@13.51.85.233
	Una vez dentro puedes instalar el programa con menu.sh, ten encuenta que algunas funciones no son necesarias.
	
	Tras instalarlo podrás usar el programa en el servidor remoto. Al ser un ser un servidor remoto al que se accede desde la consola es preferible que ejecutes el archivo webprocess.sh en vez de usar la app con Firefox (para ello es necesario añadir -X en el comando ssh), cargar el modo gráfico en esta situación suele causar problemas por los drivers gráficos.  
	
	Por último hay que añadir que el servidor estará activado hasta el Domingo 23 de Mayo, que no cuenta con ningún software extra instalado y que tiene unas capacidades muy limitadas.\n'
	
}

###########################################################
#           19) CONTROL DE LOS INTENTOS DE CONEXIÓN       #
###########################################################

function controlConexiones() {
	cat /var/log/auth.log > ./logs.txt
	cat /var/log/auth.log.? >> ./logs.txt
	zcat /var/log/auth*.gz >> ./logs.txt
	echo "Los intentos de conexión por ssh, esta semana y este mes han sido:"
	echo " "
	grep "Failed password" logs.txt | while read -r line; do
		echo $line > linea.txt
		fecha=$(cut -d " " -f 1,2,3 linea.txt)
		user=$(cut -d " " -f 9 linea.txt)
		if [ $user = "times:" ]											#En caso de que haya repeticiones del mismo comando
		then 
			user=$(cut -d " " -f 14 linea.txt)
		fi
		echo "Status: [fail] Account name: $user Date: $fecha"
		echo " "
	done
	grep "Accepted password" logs.txt | while read -r line; do
		echo $line > linea.txt
		fecha=$(cut -d " " -f 1,2,3 linea.txt)
		user=$(cut -d " " -f 9 linea.txt)
		if [ $user = "times:" ]											#En caso de que haya repeticiones del mismo comando
		then 
			user=$(cut -d " " -f 14 linea.txt)
		fi
		echo "Status: [accept] Account name: $user Date: $fecha"
		echo " "
	done
	rm logs.txt
	rm linea.txt
}	

###########################################################
#                     20) SALIR                           #
###########################################################

function fin()
{
	echo -e "¿Quieres salir del programa?(S/N)\n"
        read respuesta
	if [ $respuesta == "N" ] 
		then
			opcionmenuppal=0
		fi	
}

### Main ###
opcionmenuppal=0
while test $opcionmenuppal -ne 20
do
	#Muestra el menu
		cd $path														#Para solucionar cualquier problema de rutas, la actualizamos cada vez que volvamos al menú
      	echo -e "1) Instala Apache \n"
		echo -e "2) Iniciar Apache \n"
		echo -e "3) Testear puerto 80 \n"
		echo -e "4) Ver hoja por defecto \n"
		echo -e "5) Cambiar Index \n"
		echo -e "6) Crear Virtual Host \n"
		echo -e "7) Testear Virtual Host \n"
		echo -e "8) Intalar PHP \n"
		echo -e "9) Testear PHP \n"
		echo -e "10) Instalar paquetes Ubuntu \n"
		echo -e "11) Crear entorno virtual de Python \n"
		echo -e "12) Instalar librerias Python3 \n"
		echo -e "13) Instalar la aplicacion laguntest \n"
		echo -e "14) Pasar la propiedad a www-data  \n"
		echo -e "15) Comprobar que el script “webprocess.sh” funciona correctamente  \n"
		echo -e "16) Visualizar la aplicación  \n"
		echo -e "17) Ver los logs o errores producidos por apache  \n"
		echo -e "18) Describe los pasos necesarios para instalar laguntest en un servidor remoto utilizando ssh  \n"
		echo -e "19) Controla los intentos de conexión de ssh \n"
		echo -e "20) fin \n"



        read -p "Elige una opcion:" opcionmenuppal
	case $opcionmenuppal in
 			1) apacheInstall;;
			2) apacheStart;;
			3) apacheTets;;
			4) apacheIndex;;
			5) personalIndex;;
			6) createVirtualHost;;
			7) virtualhostTest;;
			8) phpInstall;;
			9) phpTest;;
			10) instalandoPaquetesUbuntuLagunTest;;
			11) creandoEntornoVirutalPython3;;
			12) instalandoLibreriasPythonLagunTest;;
			13) instalandoAplicacionLaguntest;;
			14) pasoPropiedad;;
			15) comprobarWebprocess;;
			16) visualizandoAplicacion;;
			17) viendoLogs;;
			18)	instalarSSH;;
			19)	controlConexiones;;
			20) fin;;
			*) ;;

	esac 
done 

echo "Fin del Programa" 
exit 0 
