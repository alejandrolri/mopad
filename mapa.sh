#!/bin/bash
#x-terminal-emulator -geometry 60x15+50+50 -e ssh -t mopad@10.42.0.1 roscore
#sleep 2.0
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup all.launch

echo "¿Va a realizar una nueva sesión? "
select sn in "Si" "No"; do
    		case $sn in
        		Si ) 	arg=args:=\"--delete_db_on_start\"; var=0; break;;
        		No ) 	echo "¿Elegir mapa(.db) o por defecto? "
				select aux in "Mapa" "Defecto"; do
    					case $aux in
				"Mapa") 	echo "Introduzca la sesión:"; read mapa;
						arg=database_path:=/home/mopad/Escritorio/Sesiones/$mapa.db; var=1; break;;
				"Defecto")	 var=0; break;;
					esac
				done
			break;;
    		esac
	    done

PS3='Seleccione : '
scripts=("Mapeo" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeo")
		x-terminal-emulator -geometry 60x15+50+410 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup rtabmap.launch $arg
		x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_teleop keyboard_teleop.launch
		sleep 2.0
		x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz mapping_rviz.launch 
		;;
		"Salir")
            	echo "Guardando mapa..."
	    	x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation save_map.launch
		
		#cerrar los procesos de ros
		ssh mopad@10.42.0.1 pkill -2 ros
	    	ssh mopad@10.42.0.1 pkill -2 roslaunch
	   	pkill -2 roslaunch
	   	pkill -2 ros		

		if [ $var = 0 ];
		then 
		    echo "¿Quiere guardar el mapa(.db) fuera de la ubicación por defecto? "
		    select yn in "Si" "No"; do
    			case $yn in
        			Si )    echo "Introduzca el nombre"; read nombre;
					ssh mopad@10.42.0.1 cp /home/mopad/.ros/rtabmap.db /home/mopad/Escritorio/Sesiones/$nombre.db
					cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.pgm /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.pgm
					cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.yaml /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.yaml
				     	break;;
        			No ) 	break;;
    			esac
	    	    done
		#cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.pgm /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.pgm
		#cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.yaml /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.yaml

		fi
	   	echo "Saliendo..."
	   	exit;;
 	*) echo "Opción no incluida $REPLY";;
    esac
done

