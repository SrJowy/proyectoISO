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
	aux=$(dpkg -s net-tools | grep "Status: install ok installed")
	if [ -z "aux" ]
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
	sudo cp ./grupo /var/www/html
}

###########################################################
#                 6) CREAR VIRTUAL HOST                   #
###########################################################
function createVirtualHost(){
	cd /var/www
	sudo mkdir laguntest
	cd laguntest
	sudo mkdir public
	cd /etc/apache2/sites-available
	conf="<VirtualHost *:80>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.
	#ServerName www.example.com
 
	ServerAdmin webmaster@localhost 
	DocumentRoot /var/www/html
 
	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn
 
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
 
	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with "a2disconf".
	#Include conf-available/serve-cgi-bin.conf
 
	<Directory /var/www/html>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	allow from all
	</Directory>
 
		</VirtualHost>"
	sudo touch laguntest.conf
	echo $conf > laguntest.conf 
}

###########################################################
#                     20) SALIR                          #
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
      	echo -e "1 Instala Apache \n"
	echo -e "...\n"
	echo -e "20) fin \n"
        read -p "Elige una opcion:" opcionmenuppal
	case $opcionmenuppal in
 			1) apacheInstall;;

			20) fin;;
			*) ;;

	esac 
done 

echo "Fin del Programa" 
exit 0 
