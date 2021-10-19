#!/bin/bash
ssh -t mopad@10.42.0.1 "sudo chmod 666 /dev/ttyUSB0"
x-terminal-emulator -geometry 60x15+50+50 -e roscore
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch asr_flir_ptu_driver ptu_left.launch 	#Launch de configuración de PTU
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup all.launch		#Launch de inicialización robot
sleep 5.0
PS3='Seleccione : '
scripts=("Mapeo" "Guardar mapa" "Elegir ruta" "Localización" "Navegación(rviz)" "Navegación(ruta)" "Mover PTU" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeo")
            echo "Iniciando proceso de mapeado..."
  	    pkill roslaunch
	    ./map.sh		#Script de mapeo
            ;;
	"Guardar mapa")
            echo "Guardando mapa..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation save_map.launch			#Guardar mapa. Mapeo debe estar iniciado.	
	    ;;
        "Localización")
	    pkill roslaunch
            echo "Iniciando proceso de localización..."
	    ./localization.sh	#Script de localización. Necesario para navegación.
            ;;
	"Elegir ruta")
            pkill roslaunch
            echo "Abriendo mapa..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation select_route.launch 		#Seleccionar ruta
	    ;;
        "Navegación(rviz)")
  	    pkill roslaunch
            echo "Iniciando proceso de navegación..."
	    ./navigation_rviz.sh	#Script de navegación mediante rviz sin PTU
            ;;
	"Navegación(ruta)")
	    pkill roslaunch
            echo "Iniciando proceso de navegación..."
	    ./navigation_route.sh	#Script de navegación mediante ruta+PTU
            ;;
	"Mover PTU")
	    echo "Iniciando proceso de PTU..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation ptu.launch 		#Launch de movimiento de PTU
	    ;;
	"Salir")
	    echo "Saliendo..."
	    ssh mopad@10.42.0.1 pkill roslaunch
	    pkill ros
	    exit
	    ;;
        *) echo "Opción no incluida $REPLY";;
    esac
done
