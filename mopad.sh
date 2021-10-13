#!/bin/bash
x-terminal-emulator -geometry 60x15+50+50 -e roscore
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup all.launch
sleep 2.0
PS3='Seleccione : '
scripts=("Mapeo" "Guardar mapa" "Elegir ruta" "Localización"	 "Navegación(rviz)" "Navegación(ruta)" "PTU" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeo")
            echo "Iniciando proceso de mapeado..."
	    ./map.sh		#Script de mapeo
            ;;
	"Guardar mapa")
            echo "Guardando mapa..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation save_map.launch			#Guardar mapa. Mapeo debe estar iniciado.	
	    ;;
        "Localización")
            echo "Iniciando proceso de localización..."
	    ./localization.sh	#Script de localización. Necesario para navegación.
            ;;
	"Elegir ruta")
            echo "Abriendo mapa..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation select_route.launch #Seleccionar ruta
	    ;;
        "Navegación(rviz)")
            echo "Iniciando proceso de navegación..."
	    ./navigation_rviz.sh	#Script de navegación mediante rviz sin PTU
            ;;
	"Navegación(ruta)")
            echo "Iniciando proceso de navegación..."
	    ./navigation_route.sh	#Script de navegación mediante ruta+PTU
            ;;
	"PTU")
	    echo "Iniciando proceso de PTU..."
	    ./PTU.sh			#Script de movimiento de PTU
	    ;;
	"Salir")
	    echo "Saliendo..."
	    exit
	    ;;
        *) echo "Opción no incluida $REPLY";;
    esac
done
