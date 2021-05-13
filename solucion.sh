function desisntalar_apche() {
	aux1=$(ps -aux | grep apache2 | grep start)									#ps = procesos actuales / -a procesos de otros usuarios / -u procesos del usuario que ejecuta ps / -x procesos no controlados por ninguna terminal  
	if [ -z "$aux1" ]													#Codigo de salida del pipe más reciente, equivalente a aux = comand1 | comand2
	then
		echo -e "Apache ya parado\n"
	else
		echo -e "apache esta en marcha\n"
		/etc/init.d/apache2 stop
	fi
	aux2=$(aptitude show apache2 | grep "State: installed")
	aux3=$(aptitude show apache2 | grep "Estado: instalado")
	aux4=$aux2$aux3
	if [ -z "$aux4" ]
	then 
		echo -e "Apache no esta instalado\n"
	else
		echo -e "Desinstalando apache...\n"
		sudo apt-get remove apache2
	fi		
} 