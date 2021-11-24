# mopad
Incluye los paquetes necesarios para la puesta en funcionamiento del mopad 2
# Robot de desinfección para COVID-19
_Proyecto impulsado por ETSII-CR (Escuela Superior de Ingeniería Industrial - Ciudad Real)_

Se trata de un robot contruido sobre la base _kobuki_ y montados unos tubos _UVC_ que desinfectarán las áreas proximas.

Se usará ROS-MELODIC para la realización de este proyecto, aunque se ha tenido que adaptar los paquetes de kobuki, ya que no están incluidos en apt.

## Comenzando

### Prerequisitos
Para comenzar es necesario instalar los paquetes necesarios para utilizar la kobuki (base movil) y poder aportar movilidad al robot.

Es tan sencillo como crear un _workspace_ nuevo:
```
$ mkdir -p ~/kobuki_ws/src/
$ cd ~/kobuki_ws
$ catkin_make
```

Ahora descargamos todos los paquetes necesarios en la carpeta _src_:
```
$ cd ~/kobuki_ws/src/
$ git clone -b melodic https://github.com/yujinrobot/kobuki_desktop
$ git clone -b melodic https://github.com/yujinrobot/kobuki
$ git clone -b melodic https://github.com/yujinrobot/kobuki_msgs
$ git clone https://github.com/yujinrobot/yujin_ocs
$ git clone -b melodic https://github.com/yujinrobot/kobuki_core
$ git clone https://github.com/yujinrobot/yocs_msgs
```

Ahora instalamos los paquetes necesarios:
```
$ sudo apt install ros-melodic-ecl-* libftdi-dev libusb-dev ros-melodic-ar-track-alvar ros-melodic-navigation pyqt5-dev-tools ros-melodic-laser-filters
```

Comprobamos que es capaz de compilar los paquetes de kobuki:
```
$ cd ~/kobuki_ws/
$ catkin_make
```

Añadimos el workspace para que ROS sea capaz de encontrarlos, al _.bashrc_:
```
$ source ~/kobuki_ws/devel/setup.bash
```

### Instalacion
Asumiendo que los prerequisitos se cumplen, comenzamos a instalar este paquete. Se ha creado otro workspace por cuestion de orden, pero puede descargarse en el primer _workspace_ creado.
```
$ mkdir -p ~/uvone_ws/src
$ catkin_make
$ cd ~/uvone_ws/src/
$ git clone git@github.com:alejandrolri/mopad.git
```
