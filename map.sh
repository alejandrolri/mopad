#!/bin/bash
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch uvone_robot_teleop keyboard_teleop.launch
sleep 0.5
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1
sleep 0.5
x-terminal-emulator -geometry 60x15+50+410 -e roslaunch uvone_robot_bringup rtabmap.launch #args :="--delete_db_on_start"
sleep 0.5
rosrun rviz rviz


