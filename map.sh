#!/bin/bash
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_teleop keyboard_teleop.launch
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch mopad_bringup all.launch
sleep 20.0
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch mopad_bringup rtabmap.launch #args :="--delete_db_on_start"
sleep 0.5
x-terminal-emulator -geometry 60x15+1000+410 -e roslaunch mopad_rviz mapping_rviz.launch 




