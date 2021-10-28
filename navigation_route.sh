#!/bin/bash
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_bringup rtabmap.launch  $1 localization:="true"  
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_navigation move_base.launch	#Primero cerrar teleop para evitar conflictos
x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz navigation_rviz.launch 
sleep 20.0
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_navigation navigation.launch


