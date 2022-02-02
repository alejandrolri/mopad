# mopad
Incluye los paquetes necesarios para la puesta en funcionamiento del mopad 2


Se usará ROS Melodic para la realización de este proyecto.


# Instalación ROS Melodic
Para instalar los repositorios de ROS:
```
$ sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
$ sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80 --recv-key' C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
$ sudo apt update
$ sudo apt install ros-melodic-desktop-full
```
Para inicializar las variables de entorno automáticamente:
```
$ echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
$ source ~/.bashrc
```
Instalar paquetes básicos de ROS:
```
$ sudo apt install python-rosdep python-rosinstall build-essential python-rosinstall-generator python-wstool
$ sudo rosdep init
$ rosdep update
```

Crear el workspace:
```
$ mkdir -p ~/catkin_ws/src
$ cd catkin_ws/
$ catkin_make
```

### Prerrequisitos
Para comenzar es necesario instalar los paquetes necesarios para utilizar la kobuki (base movil) y poder aportar movilidad al robot.

Descargar todos los paquetes necesarios en la carpeta _src_:
```
$ cd ~/catkin_ws/src/
$ git clone -b melodic https://github.com/yujinrobot/kobuki_desktop
$ git clone -b melodic https://github.com/yujinrobot/kobuki
$ git clone -b melodic https://github.com/yujinrobot/kobuki_msgs
$ git clone https://github.com/yujinrobot/yujin_ocs
$ git clone -b melodic https://github.com/yujinrobot/kobuki_core
$ git clone https://github.com/yujinrobot/yocs_msgs
$ git clone https://github.com/orbbec/ros_astra_camera
$ git clone -b melodic https://github.com/turtlebot/turtlebot.git
$ git clone https://github.com/Slamtec/rplidar_ros.git
$ git clone https://github.com/asr-ros/asr_flir_ptu_driver.git
```

Instalar los paquetes necesarios:
```
$ sudo apt install ros-melodic-ecl-* libftdi-dev libusb-dev ros-melodic-ar-track-alvar ros-melodic-navigation pyqt5-dev-tools ros-melodic-laser-filters ros-melodic-rgbd-launch ros-melodic-libuvc ros-melodic-libuvc-camera ros-melodic-libuvc-ros ros-melodic-rtabmap-ros
```

Comprobar que es capaz de compilar los paquetes de kobuki:
```
$ cd ~/catkin_ws/
$ catkin_make
```

Añadir el workspace para que ROS sea capaz de encontrarlos, al _.bashrc_:
```
$ source ~/catkin_ws/devel/setup.bash
```

### Instalacion
Para instalar los paquetes del MoPAD 2 y su ejecutable:
```
cd ~/catkin_ws/src/
$ git clone git@github.com:alejandrolri/mopad.git
```
