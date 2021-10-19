#!/bin/bash
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_bringup rtabmap.launch localization:=true
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_navigation move_base.launch	#Primero cerrar teleop para evitar conflictos
sleep 2.0
x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz navigation_rviz.launch 



