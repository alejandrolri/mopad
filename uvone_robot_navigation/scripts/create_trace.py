#!/usr/bin/env python
import rospy
import cv2
import math
import yaml


rospy.init_node('talker', anonymous=True)

origen = [0, 0, 0]
grid_size = 0
#path_yaml = '/home/rafaelm/Desktop/mapa_test.yaml'
#path_yaml = '/home/rafaelm/own_ws/src/uvone_robot/uvone_robot_navigation/maps/octomap_grid.yaml'
path_yaml = rospy.get_param('~yaml/path', '/home/rafaelm/own_ws/src/uvone_robot/uvone_robot_navigation/maps/')
file_yaml = rospy.get_param('~yaml/filename', 'octomap_grid.yaml')
route_path = rospy.get_param('~route/path', 'octomap_grid.yaml')
route_filename = rospy.get_param('~route/filename', 'octomap_grid.yaml')
f = open(route_path + route_filename, "w") # Archivo donde se guardaran las posiciones objetivo


height = 0
width = 0
channels = 0



init_point = (0,0)
final_point = (0,0)
init_point_off = (0,0)
final_point_off = (0,0)


def on_click(event, x, y, p1, p2):
    global init_point, final_point, init_point_off, final_point_off, height, width

    x_off = round(x*grid_size + origen[0],3)
    y_off = round((height - y)*grid_size + origen[1],3)

    if event == cv2.EVENT_LBUTTONDOWN:
        print("Presionado",x_off, y_off)
        init_point = (x, y)
        init_point_off = (x_off, y_off)
        
    if event == cv2.EVENT_LBUTTONUP:
        print("Soltado",x_off, y_off)
        final_point = (x, y)
        final_point_off = (x_off, y_off)

        vector = (final_point[0] - init_point[0], final_point[1] - init_point[1] )
        longitud = math.sqrt(vector[0]**2 + vector[1]**2) / (math.sqrt(height**2 + width**2) * 0.025)
        if longitud==0:
            return
        vector = (vector[0] / longitud, vector[1] / longitud)
        
        final_point = (int(init_point[0] + vector[0]), int(init_point[1] + vector[1]))


        f.write("%.4f  \t%.4f  \t%.4f\n" % (init_point_off[0], init_point_off[1], math.atan2(vector[1],vector[0])))


        cv2.arrowedLine(img, init_point, final_point, (100, 200, 0), 5)
        cv2.imshow("image", img)





if __name__ == '__main__':
    
    
    try:

        # Obtenemos la informacion del yaml del mapa y lo agregamos a las variables globales.

        with open(path_yaml + file_yaml) as file:

            datos = yaml.safe_load(file)

            for item, doc in datos.items():

                if item == 'origin':
                    origen = doc

                if item == 'resolution':
                    grid_size = doc

                if item == 'image':
                    path =  doc


        # Leemos el archivo del mapa, y medimos algunas propiedades.

        img = cv2.imread(path)
        height, width, channels = img.shape

        # Mostramos el mapa y anadimos el callback.
        cv2.namedWindow('image')
        cv2.setMouseCallback('image', on_click)
        cv2.imshow("image", img)


        # Esperamos que el usuario presione entres para salir y escribir el archivo.
        while(1):
            k = cv2.waitKey(33)
            if k==32:
                break
            else:
                continue
        
        cv2.destroyAllWindows()
        f.close()

        pass

    except rospy.ROSInterruptException:
        pass
