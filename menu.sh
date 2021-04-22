#!/bin/bash


###########################################################
#                  1) INSTALL APACHE                     #
###########################################################
function apacheInstall()
{
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
		sudo pip install virtualenv
		cd /var/www/laguntest/public_html/
		if [ -d ".env" ]
		then
			echo "Entorno virtual creado\n"
			sleep 1	
		else 
			sudo virutalenv -p python3.env
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
	cp ./requirements.txt/var/www/laguntest/public_html/.env
	pip install -r requirements.txt
	deactivate
	
}

###########################################################
#           13) INSTALAR APLICACION LAGUNTEST             #
###########################################################

function instalandoAplicacionLaguntest(){
	cp *.php *.sh *.py *.gif /var/www/laguntest/public_html/
	cp -r textos /var/www/laguntest/public_html/

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
			20) fin;;
			*) ;;

	esac 
done 

echo "Fin del Programa" 
exit 0 
