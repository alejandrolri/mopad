#!/bin/bash
#echo $1
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_bringup rtabmap.launch $1
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_teleop keyboard_teleop.launch
sleep 2.0
x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz mapping_rviz.launch 




