#!/bin/bash
#x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1
sleep 20.0
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_bringup rtabmap.launch localization:=true 
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_navigation move_base.launch	#Primero cerrar teleop para evitar conflictos
sleep 1.0
x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz navigation_rviz.launch 
sleep 15.0
#x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_navigation navigation.launch


