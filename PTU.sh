#!/bin/bash
x-terminal-emulator -geometry 60x15+50+50 -e ssh mopad@10.42.0.1 roslaunch asr_flir_ptu_driver ptu_left.launch 
sleep 50.0
x-terminal-emulator -geometry 10x10+900+50 -e roslaunch mopad_navigation ptu.launch
