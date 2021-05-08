#!/bin/bash


###########################################################
#                  1) INSTALL APACHE                     #
###########################################################
function apacheInstall()
{																		#si se instala en una maquina nueva es necesario
	sudo apt update
	sudo apt install build-essential
	sudo apt install aptitude 										
	sudo apt install firefox
	aux=$(aptitude show apache2 | grep "State: installed")
	aux2=$(aptitude show apache2 | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then 
 	  echo "instalando ..."
 	  sudo apt-get install apache2
	else
   	  echo "apache ya estaba instalado"
    
	fi 
}

###########################################################
#                  2) INICIAR APACHE                      #
###########################################################

function apacheStart() {
	ps aux | grep apache2 | grep -v grep
	if [ $? != 0 ]
	then
		echo "inicializando apache..."
		/etc/init.d/apache2 start
	else
		echo "apache ya está iniciado"
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
	sudo netstat -anp | grep "apache2" | grep :80
}

###########################################################
#                 4) VER HOJA POR DEFECTO                 #
###########################################################
function apacheIndex(){
	echo -e "¿Quieres abrir la página web por defecto?(S/N)\n"
	read respuesta
	if [ $respuesta == "S" ]
		then
			firefox http://localhost
		fi
}

###########################################################
#                 5) CAMBIAR INDEX                        #
###########################################################
function personalIndex(){
	
	echo -e "Se va a cambiar la página HTML por defecto"
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
	sudo mkdir -p public_html
	sudo cp /var/www/html/index.html /var/www/laguntest/public_html/
	sudo chown -R www-data:www-data /var/www/laguntest/public_html
	sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laguntest.conf
	sudo sed -i "s/80/8888/g" /etc/apache2/sites-available/laguntest.conf
	sudo sed -i "s/\/var\/www\/html/\/var\/www\/laguntest\/public_html/g" /etc/apache2/sites-available/laguntest.conf
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
			echo "Instalando el modulo php ...\n"    
    		sudo apt install php libapache2-mod-php
    		sudo systemctl restart apache2
    		echo "El modulo php se ha instalado correctamente\n"    
    		sleep 1
		else
    #PHP instalado
    		echo "PHP ya estaba instalado\n"     
    		sleep 1
		fi
}

###########################################################
#                 9) TESTEAR EL MODULO PHP                #
###########################################################

function phpTest(){
    	sudo echo "<?php phpinfo(); ?>" > test.php
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
		echo "Instalando python3-pip... \n"
		sudo apt install python3-pip
		sudo python3 -m  pip install --upgrade pip
		echo "El módulo se ha instalado correctamente \n"
		sleep 1
	else
		echo "python3-pip ya estaba instalado \n"
		sleep 1
	fi
	#INSTALAR DOS2UNIX
	aux=$(aptitude show dos2unix | grep "State: installed")
	aux2=$(aptitude show dos2unix | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
		echo "Instalando dos2unix... \n"
		sudo apt install dos2unix
		echo "El módulo se ha instalado correctamente \n"
		sleep 1
	else
		echo "dos2unix ya estaba instalado \n"
		sleep 1
	fi
	#INSTALAR LIBRSVG2-BIN
	aux=$(aptitude show librsvg2-bin | grep "State: installed")
	aux2=$(aptitude show librsvg2-bin | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then
		echo "Instalando librsvg2-bin ... \n"
		sudo apt install librsvg2-bin 
		echo "El módulo se ha instalado correctamente \n"
		sleep 1
	else
		echo "librsvg2-bin ya estaba instalado \n"
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
		sudo pip3 install virtualenv
		cd /var/www/laguntest/public_html/
		if [ -d ".env" ]
		then
			echo "Entorno virtual creado\n"
			sleep 1	
		else
			sudo virtualenv -p python3 .env
		fi
	fi	
}

###########################################################
#           12) INSTALAR LIBRERIAS PYTHON3                #
###########################################################

function instalandoLibreriasPythonLagunTest(){
	pId = id -u
	pGroup = id -g
	sudo chown -R $pId:$pGroup
	source /var/www/laguntest/public_html/.env/bin/activate
	cp ./requirements.txt /var/www/laguntest/public_html/.env
	sudo pip install -r requirements.txt
	deactivate
	
}

###########################################################
#           13) INSTALAR APLICACION LAGUNTEST             #
###########################################################

function instalandoAplicacionLaguntest(){
	echo "Instalando la aplicación..."
	sudo cp *.php *.sh *.py *.gif /var/www/laguntest/public_html/
	sudo cp -r textos /var/www/laguntest/public_html/
}

###########################################################
#           14) PASAR LA PROPIEDAD WWW-DATA               #
###########################################################

function pasoPropiedad(){
	echo "Dando permisos a www-data..."
	sudo chown -R www-data:www-data /var/www
}

###########################################################
#             15) COMPROBAR WEBPROCESS.SH                 #
###########################################################

function comprobarWebprocess(){
	cd /var/www/laguntest/public_html/
	sudo chmod uo+x webprocess.sh
	sudo chown -R www-data:www-data webprocess.sh
	sudo -u root su - www-data -s /bin/bash
	cd /var/www/laguntest/public_html/
	./webprocess.sh textos/english.doc.txt
}


###########################################################
#           16) VISUALIZAR LA APLICACION                  #
###########################################################

function visualizandoAplicacion(){
	firefox http://127.0.0.1:8888/index.php
}

###########################################################
#           17) VISUALIZAR LA APLICACION                  #
###########################################################

function viendoLogs(){
	echo 'visualizando el documento de errores..'
	tail -n100 /var/log/apache2/error.log
}

###########################################################
#           18) DESCRIBIR PASOS PARA INSTALAR SSH         #
###########################################################

function instalarSSH(){
	sudo aptitude install ssh 
	echo 'SSH (Secure SHell) es un software y protocolo que permite el acceso remoto a un servidor mediante un canal seguro con la información cifrada. Tambien puedes usarlo para controlar otro dispositivo. El software suele venir instalado en dispotivos Linux pero por si acaso puedes instalarlo con "sudo aptitude install openssh-server".
	Para el cliente necesitas otro dispositivo. En Linux y Mac ya viene instalado el software necesario para poder conectarte a ellos, para Windows necesitaras el programa Putty. 
	Una vez tengas cliente y servidor preparados asegurate de que SSH esta activado, para ello usa "systemctl enable ssh" en tu ordenador.  
	Para conectarte al servidor necesitas el nombre de usuario, su IP y su contraseña. 
	Para obtener la IP en Linux puedes usar "hostname -I" en la terminal del servidor remoto.
	Ahora para conectarte al servidor usar "ssh usuario@IP" donde usuario es el nombre de usuario del servidor al que te quieres conectar.
	Una vez hecho esto te pedira la contraseña introducela y ya estaras usando el servidor remotamente.'
	echo 'Para ejecutar la applicación web desde un servidor remoto es necesario que cumplas los requisitos mencionados anteriormente.
	Si tienes la IP, nombre de usuario y contraseña ya puedes empezar.' 
	echo -e 'Introduce la IP del servidor remoto:'
	read IP
	echo -e 'Ahora introduce el nombre de usuario del servidor:'
	read user
	echo -e 'Primero de todo es necesario que tenga los archivos.
	¿Tienes los archivos instalados en el servidor? [SI/NO]'
	read respuesta
	if [ $respuesta=NO ]
	then
		echo 'Se van a copiar los archivos de instalación al servidor web'
		scp -r ../proyecto $user@$IP:/home/$user/
		fi
	echo 'Se va a instalar la aplicación en el servidor'
		
	echo 'Ahora vas a conectarte al sevidor'	
	ssh $user@$IP 

	
}

###########################################################
#           19) CONTROL DE LOS INTENTOS DE CONEXIÓN       #
###########################################################

function controlConexiones() {
	cat /var/log/auth* > ./logs.txt
	echo "Los intentos de conexión por ssh, esta semana y este mes han sido:"
	echo " "
	grep "Failed password" logs.txt | while read -r line; do
		echo ${line} > linea.txt
		fecha=$(cut -d " " -f 1,2,3 linea.txt)
		user=$(cut -d " " -f 9 linea.txt)
		echo "Status: [fail] Account name: $user Date: $fecha"
		echo " "
	done
	grep "Accepted password" logs.txt | while read -r line; do
		echo ${line} > linea.txt
		fecha=$(cut -d " " -f 1,2,3 linea.txt)
		user=$(cut -d " " -f 9 linea.txt)
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
			18)	instalarSHH;;
			19)	controlConexiones;;
			20) fin;;
			*) ;;

	esac 
done 

echo "Fin del Programa" 
exit 0 
