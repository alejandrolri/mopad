#!/bin/bash
PS3='Seleccione : '
scripts=("Mapeado" "Localización" "Ruta" "Navegación" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeado")
            echo "Iniciando proceso de mapeado..."
	    ./map.sh		#Script de mapeado
            ;;
        "Localización")
            echo "Iniciando proceso de localización..."
	    ./localization.sh	#Script de localización
            ;;
	"Ruta")
            echo "Abriendo mapa..."
	    roslaunch uvone_robot_navigation select_route.launch #Seleccionar ruta
	    ;;
        "Navegación")
            echo "Iniciando proceso de navegación..."
	    ./navigation.sh	#Script de navegación
	    #break
            ;;
	"Salir")
	    echo "Saliendo..."
	    exit
	    ;;
        *) echo "invalid option $REPLY";;
    esac
done
