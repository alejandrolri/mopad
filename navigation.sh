#!/bin/bash
#x-terminal-emulator -geometry 10x10+900+50 -e roslaunch uvone_robot_bringup rtabmap.launch localization:=true 
#x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1
sleep 20.0
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch uvone_robot_navigation move_base.launch
sleep 1.0
x-terminal-emulator -geometry 60x15+50+410 -e rosrun rviz rviz
sleep 5.0
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch uvone_robot_navigation prueba.launch


