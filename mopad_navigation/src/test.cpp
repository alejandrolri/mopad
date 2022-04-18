// NODO PARA NAVEGACIÓN Y TOMA DE DATOS DE MOPAD 2
// versión 3: incluye movimiento del pan-tilt y detección de fallos de BLK


#include <ros/ros.h>
#include <move_base_msgs/MoveBaseAction.h>
#include <actionlib/client/simple_action_client.h>

#include <tf2/LinearMath/Quaternion.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

#include <fstream> // Para leer el archivo
#include <iostream>

#include "asr_flir_ptu_driver/State.h"
#include <sensor_msgs/JointState.h>

#include <sys/stat.h>

#include <tf/transform_listener.h>



using namespace std;

typedef actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> MoveBaseClient;


sensor_msgs::JointState createJointCommand(double pan, double tilt, double panSpeed, double tiltSpeed)
{
	sensor_msgs::JointState joint_state;
	joint_state.header.stamp = ros::Time::now();
	joint_state.name.push_back("pan");
	joint_state.position.push_back(pan);
	joint_state.velocity.push_back(panSpeed);
	joint_state.name.push_back("tilt");
	joint_state.position.push_back(tilt);
	joint_state.velocity.push_back(tiltSpeed);
	return joint_state;
}

//Movimiento del pan-tilt
void ptu(double pan, double tilt, ros::Publisher state_pub)
{	for(int i=0;i<2;i++) //Manera de que envíe solo un mensaje  ros::spinOnce();
	{
	asr_flir_ptu_driver::State movement_goal;
	sensor_msgs::JointState joint_state = createJointCommand(pan, tilt, 0, 0);

	movement_goal.state = joint_state;
	state_pub.publish(movement_goal);
        ros::Duration(3).sleep();
	}
}

//Comprueba los archivos generados por el BLK y detecta si ha habido algún fallo. 
bool fallo(string direccion)
{
	direccion = direccion+"/data";
	char *path = &direccion[0];
		
	struct stat buffer;
	if (stat(path,&buffer))	//No se ha creado el directorio data.
	{	
		ROS_INFO("No existe data");
		return true;
	}
	else	//Existe el directorio data. Comprobar que están todos los ficheros.
	{
		string param = "cd "+direccion+" && ls | wc -l >> /tmp/text.txt";
		char *comando = &param[0];
		system(comando);
		ifstream myfile;
	  	myfile.open("/tmp/text.txt");
		int x;
		myfile >> x;
		myfile.close();
		remove("/tmp/text.txt");
		if(x==1 || x==52)
		{
			ROS_INFO("Se ha realizado el escaneado de forma correcta");	
			return true;	
		}
		else
		{
			ROS_INFO("Ha habido un problema");
			return false;
		}
	}
}


bool BLK(string modo,string densidad,int tomas,int posicion,double x,double y,double yaw,double emisividad,string color, ros::Publisher state_pub, string pantilt)
{
	ROS_INFO("BLK");
	string route, emissivity;
        
	if (modo=="NubedePuntos") 
	{
		if (color=="RGB")
			route = "adquisitionWithColor/DownloadPCWithColor";
		else
			route = "adquisitionOnlyPointCloud/DownloadPC";
	}	
	else
	{		
		emissivity= to_string(emisividad);
		if (color=="RGB")
			route = "adquisitionWithColorAndIR/DownloadPCWithColorAndIR";
		else
			route = "adquisitionPCAndIR/DownloadPCAndIR";		
	}	


	//Crea la carpeta de una posición
	string dir="/home/mopad/Escritorio/Nubes/posicion"+to_string(posicion);
	char *path = &dir[0];
       	mkdir(path,0777);

	//Guardar posición y orientación
	ofstream myfile;
	myfile.open(dir+"/posicion.txt");
	myfile << x << "\t" << y << "\t" << yaw << endl;
	myfile.close();
	

	if(pantilt=="Sí")
	{
		ROS_INFO("PTU");
		//INCLINADO 45
		ROS_INFO("Toma 45 grados");
		ptu(-90,0,state_pub);
		ptu(-90,-45,state_pub);

		string dir_i1 = dir+"/inclinado1";
		char *path_i1 = &dir_i1[0];
		mkdir(path_i1,0777);
		for(int i=1; i<=tomas;i++)
		{
			string dir_t= dir_i1+"/toma"+to_string(i);
			char *path_t = &dir_t[0];
			mkdir(path_t,0777);
			
			//Ejecuta BLK en la carpeta anterior
			string param = "cd "+dir_t+" && export DISPLAY=:0.0 && /home/mopad/blk/"+route+" "+densidad+" "+emissivity;
			char *command = &param[0];	
			system(command);
			if (fallo(dir_t))
			{
				ROS_INFO("FALLO BLK");
				ptu(-90,0,state_pub);
				ptu(0,0,state_pub);
				return false;
			}
		}



		//VERTICAL
		ROS_INFO("Toma vertical");
		ptu(-90,0,state_pub);
		ptu(0,0,state_pub);
		string dir_v = dir+"/vertical";
		char *path_v = &dir_v[0];
		mkdir(path_v,0777);
		for(int i=1; i<=tomas;i++)
		{
			string dir_t= dir_v+"/toma"+to_string(i);
			char *path_t = &dir_t[0];
			mkdir(path_t,0777);
			
			//Ejecuta BLK en la carpeta anterior
			string param = "cd "+dir_t+" && export DISPLAY=:0.0 && /home/mopad/blk/"+route+" "+densidad+" "+emissivity;
			char *command = &param[0];	
			system(command);
			
			if (fallo(dir_t))
			{
				ROS_INFO("FALLO BLK");
				return false;
			}

		}	

		
		
		
		//INCLINADO -45
		ROS_INFO("Toma -45");
		ptu(90,0,state_pub);
		ptu(90,-45,state_pub);


		string dir_i2 = dir+"/inclinado2";
		char *path_i2 = &dir_i2[0];
		mkdir(path_i2,0777);
		for(int i=1; i<=tomas;i++)
		{
			string dir_t= dir_i2+"/toma"+to_string(i);
			char *path_t = &dir_t[0];
			mkdir(path_t,0777);
			
			//Ejecuta BLK en la carpeta anterior
			string param = "cd "+dir_t+" && export DISPLAY=:0.0 && /home/mopad/blk/"+route+" "+densidad+" "+emissivity;
			char *command = &param[0];	
			system(command);
			if (fallo(dir_t))
			{
				ROS_INFO("FALLO BLK");
				ptu(90,0,state_pub);
				ptu(0,0,state_pub);
				return false;
			}
		}	

		ptu(90,0,state_pub);
		ptu(0,0,state_pub);
	}
	else
	{
		for(int i=1; i<=tomas;i++)
		{
			string dir_t= dir+"/toma"+to_string(i);
			char *path_t = &dir_t[0];
			mkdir(path_t,0777);
			
			//Ejecuta BLK en la carpeta anterior
			string param = "cd "+dir_t+" && export DISPLAY=:0.0 && /home/mopad/blk/"+route+" "+densidad+" "+emissivity;
			char *command = &param[0];	
			system(command);
			if (fallo(dir_t))
			{
				ROS_INFO("FALLO BLK");
				return false;
			}
		}	
	}
	
	return true;
}


	

int main(int argc, char** argv){
  
	int posicion,tomas;
	double x, y, theta;
	double x_r, y_r, yaw, emisividad;
	string modo, densidad, color, pantilt;
	bool status = true;


	//Posición de HOME	
	double x_home, y_home, yaw_home;
	bool home = false;	

	ros::init(argc, argv, "navigation_goals");
	ros::NodeHandle nh("~"); 
	ros::Publisher state_pub = nh.advertise<asr_flir_ptu_driver::State>("/asr_flir_ptu_driver/state_cmd", 1);	
	 

	tf::TransformListener listener;

	tf2::Quaternion myQ;


	//tell the action client that we want to spin a thread by default
	MoveBaseClient ac("move_base", true);


	//wait for the action server to come up

	while(!ac.waitForServer(ros::Duration(5.0))){
		ROS_INFO("Waiting for the move_base action server to come up");
	}

  	ifstream myfile;
  	myfile.open("/home/mopad/catkin_ws/src/mopad_navigation/paths/ruta.txt");
  	if (myfile.is_open())
  	{ 
		while ( (myfile >> x >> y >> theta >> modo >> tomas >> densidad >> emisividad >> color >> pantilt >> posicion) && status)
	    	{
			if(modo=="home")
			{
				x_home	= x;
				y_home = y;
				yaw_home = theta;
				home = true;	
			}
			else
			{
				cout << x << "\t" << y  <<  "\t" << theta << endl;
			    	cout << modo <<"\t" << tomas <<"\t" << densidad  <<"\t" << emisividad <<"\t" << color <<"\t" << pantilt  << endl;

				move_base_msgs::MoveBaseGoal goal;
				goal.target_pose.header.frame_id = "map";
				goal.target_pose.header.stamp = ros::Time::now();

				myQ.setRPY(0, 0, theta);
				     
				goal.target_pose.pose.position.x = x;
				goal.target_pose.pose.position.y = y;
				tf2::convert(myQ, goal.target_pose.pose.orientation);

				ROS_INFO("Moviendose a la siguiente posicion");
				ac.sendGoal(goal);

				ac.waitForResult();

				ros::Duration(0.1).sleep();
				    

				if(ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED)
				{
			    		ROS_INFO("Ha llegado correctamente");
				
					//GUARDA LA POSICIÓN
					tf::StampedTransform transform;
					try{
						listener.lookupTransform("/map","/base_footprint",ros::Time(0),transform);
						x_r = transform.getOrigin().x();
						y_r = transform.getOrigin().y();
						tf::Quaternion q = transform.getRotation();
						yaw = tf::getYaw(q);
					}
					catch(tf::TransformException ex){
						ROS_ERROR("Error tf");
					}

		
					ros::Duration(1).sleep();		//Pausa entre la llegada al destino y el lanzamiento del escáner
					status = BLK(modo,densidad,tomas,posicion,x_r,y_r,yaw,emisividad,color,state_pub,pantilt);
					if(!status)
					{
						ROS_INFO("fallo");
						ofstream pos_fallo;
					  	pos_fallo.open("/home/mopad/Escritorio/Nubes/fallo.txt");
						pos_fallo << posicion << endl;
						pos_fallo.close();
					}
			    	}
			   	 else
				{
			    	 	ROS_INFO("Ha habido un fallo");
					status = false;
				}
			}
		}
		myfile.close();
		
		//VUELTA A HOME
		if(home)
		{		
			move_base_msgs::MoveBaseGoal goal;
			goal.target_pose.header.frame_id = "map";
			goal.target_pose.header.stamp = ros::Time::now();

			myQ.setRPY(0, 0, yaw_home);
								     
			goal.target_pose.pose.position.x = x_home;
			goal.target_pose.pose.position.y = y_home;
			tf2::convert(myQ, goal.target_pose.pose.orientation);

			ROS_INFO("Volviendo a HOME");
			ac.sendGoal(goal);

			ac.waitForResult();
		}
	}

  	else cout << "Unable to open file"; 

	//ENVIAR
	system("pscp -pw mopad -r /home/mopad/Escritorio/Nubes mopad@10.42.0.82:C:/Users/mopad/Desktop/BLK");

	//BORRAR
	system("rm -r /home/mopad/Escritorio/Nubes/*");
	
	//Terminar nodos de move_base.launch
	system("rosnode kill move_base");
	system("rosnode kill navigation_velocity_smoother");
	system("rosnode kill kobuki_safety_controller"); 
  	return 0;
}
