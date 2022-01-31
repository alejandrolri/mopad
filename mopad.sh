#!/bin/bash
sudo /etc/init.d/chrony stop
sudo ntpdate 10.42.0.1
sudo /etc/init.d/chrony start
#ssh -t mopad@10.42.0.1 "sudo chmod 666 /dev/ttyUSB0"
x-terminal-emulator -geometry 60x15+50+50 -e roscore
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup all.launch		#Launch de inicialización robot
#x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch asr_flir_ptu_driver ptu_left.launch 	#Launch de configuración de PTU

echo "¿Va a realizar una nueva sesión? "
select sn in "Si" "No"; do
    		case $sn in
        		Si ) 	arg=args:=\"--delete_db_on_start\"; var=0; break;;
        		No ) 	echo "¿Elegir mapa(.db) o por defecto? "
				select aux in "Mapa" "Defecto"; do
    					case $aux in
				"Mapa") 	echo "Introduzca la ruta del archivo:"; read mapa;
						arg=database_path:=$mapa; var=1; break;;
				"Defecto")	 var=0; break;;
					esac
				done
			break;;
    		esac
	    done

PS3='Seleccione : '
scripts=("Mapeo" "Guardar mapa" "Elegir ruta" "Localización" "Navegación(rviz)" "Navegación(ruta)" "Mover PTU" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeo")
            echo "Iniciando proceso de mapeado..."
  	    pkill roslaunch
	    ./map.sh $arg		#Script de mapeo
            ;;
	"Guardar mapa")
            echo "Guardando mapa..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation save_map.launch			#Guardar mapa. Mapeo debe estar iniciado.	
	    ;;
	"Elegir ruta")
            pkill roslaunch
            echo "Abriendo mapa..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation select_route.launch 		#Seleccionar ruta
	    ;;
        "Localización")		#Script de localización. Necesario para navegación.
	    pkill roslaunch
            echo "Iniciando proceso de localización..."
	    if [ $var = 1 ];
	    then 
	    	./localization.sh $arg	
     	    else
	    	./localization.sh
	    fi
 	    ;;
        "Navegación(rviz)")	 #Script de navegación mediante rviz sin PTU
  	    pkill roslaunch
            echo "Iniciando proceso de navegación..."
	    if [ $var = 1 ];
	    then 
	    	./navigation_rviz.sh $arg
     	    else
	    	./navigation_rviz.sh
	    fi
 	    ;;
	"Navegación(ruta)")	#Script de navegación mediante ruta+PTU
	    pkill roslaunch
            echo "Iniciando proceso de navegación..."
	    if [ $var = 1 ];
	    then 
	    	./navigation_route.sh $arg
     	    else
	    	./navigation_route.sh
	    fi
 	    ;;
	"Mover PTU")
	    echo "Iniciando proceso de PTU..."
	    x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation ptu.launch 		#Launch de movimiento de PTU
	    ;;
	"Salir")
		if [ $var = 0 ];
		then 
		    echo "¿Quiere guardar el mapa(.db) fuera de la ubicación por defecto? "
		    select yn in "Si" "No"; do
    			case $yn in
        			Si ) 	echo "Introduzca la ruta:"; read ruta;
					echo "Introduzca el nombre sin extensión:"; read nombre;
					cp /home/mopad/.ros/rtabmap.db $ruta/$nombre.db
				     	break;;
        			No ) 	break;;
    			esac
	    	    done
		fi
	   	echo "Saliendo..."
 	    	ssh mopad@10.42.0.1 pkill ros
	    	ssh mopad@10.42.0.1 pkill roslaunch
	   	pkill roslaunch
	   	pkill ros
	   	exit;;
        *) echo "Opción no incluida $REPLY";;
    esac
done



