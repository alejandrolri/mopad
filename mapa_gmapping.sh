#!/bin/bash
#x-terminal-emulator -geometry 60x15+50+50 -e ssh -t mopad@10.42.0.1 roscore
#sleep 2.0
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup all_gmapping.launch

PS3='Seleccione : '
scripts=("Mapeo" "Salir")
select fav in "${scripts[@]}"; do
    case $fav in
        "Mapeo")
		x-terminal-emulator -geometry 60x15+50+410 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup gmapping.launch
		x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_teleop keyboard_teleop.launch
		sleep 2.0
		x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz mapping_rviz.launch 
		;;
		"Salir")
            	echo "Guardando mapa..."
	    	x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation save_map.launch
		sleep 5.0

		#cerrar los procesos de ros
		rosnode kill -a
		ssh mopad@10.42.0.1 pkill -2 ros
	    	ssh mopad@10.42.0.1 pkill -2 roslaunch
	   			

		
        	echo "Introduzca el nombre"; read nombre;
		cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.pgm /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.pgm
		cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.yaml /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.yaml
	
		#cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.pgm /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.pgm
		#cp /home/mopad/catkin_ws/src/mopad_navigation/maps/map.yaml /media/windows/Users/mopad/Desktop/BLK/maps/$nombre.yaml

	   	echo "Saliendo..."
	   	exit;;
 	*) echo "Opción no incluida $REPLY";;
    esac
done

