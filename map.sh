#!/bin/bash
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_teleop keyboard_teleop.launch
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_bringup rtabmap.launch 
sleep 2.0
x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz mapping_rviz.launch 




