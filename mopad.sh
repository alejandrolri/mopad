#!/bin/bash
PS3='Seleccione : '
scripts=("Mapeado" "Guardar mapa" "Localización" "Elegir ruta" "Navegación" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeado")
            echo "Iniciando proceso de mapeado..."
	    ./map.sh		#Script de mapeado
            ;;
	"Guardar mapa")
            echo "Abriendo mapa..."
	    roslaunch mopad_navigation save_map.launch
	    ;;
        "Localización")
            echo "Iniciando proceso de localización..."
	    ./localization.sh	#Script de localización
            ;;
	"Elegir ruta")
            echo "Abriendo mapa..."
	    roslaunch mopad_navigation select_route.launch #Seleccionar ruta
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
        *) echo "Opción no incluida $REPLY";;
    esac
done
