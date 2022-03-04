
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

void BLK(string modo,string densidad,int tomas,int position,double x,double y,double yaw,double emisividad,string color)
{
	ROS_INFO("BLK");
	string route, scan, emissivity;
        
	if (modo=="NubedePuntos") {
		if (color=="RGB"){
		route = "adquisitionWithColor/DownloadPCWithColor";
		}
		else{
			route = "adquisitionOnlyPointCloud/DownloadPC";
		}
	}	
	else{		
		emissivity= to_string(emisividad);
		if (color=="RGB"){
			route = "adquisitionWithColorAndIR/DownloadPCWithColorAndIR";
		}
		else{
			route = "adquisitionPCAndIR/DownloadPCAndIR";
		}	
				
	}	


	//Crea la carpeta de una posición
	string dir="/home/mopad/Escritorio/Nubes/position"+to_string(position);
	int n_dir = dir.length(); char path[n_dir+1]; strcpy(path, dir.c_str()); 
       	mkdir(path,0777);

	//Guardar posición y orientación
	ofstream myfile;
	myfile.open(dir+"/posicion.txt");
	myfile << x << "\t" << y  <<  "\t" << yaw << endl;
	myfile.close();
	
	for(int i=1; i<=tomas;i++){
		string dir_t= dir+"/toma"+to_string(i);
		int n_dir_t = dir_t.length(); char path_t[n_dir_t+1]; strcpy(path_t, dir_t.c_str());
		mkdir(path_t,0777);
		
		//Ejecuta BLK en la carpeta anterior
		string param = "cd "+dir_t+" && export DISPLAY=:0.0 && /home/mopad/blk/"+route+" "+densidad+" "+emissivity;
		int n = param.length(); char command[n+1]; strcpy(command, param.c_str()); //system solo acepta char	
		system(command);
	}

}




int main(int argc, char** argv){
  
  int position = 0;
  int tomas;
  double x, y, theta;
  double x_r, y_r, yaw, emisividad;
  string modo, densidad,color;

  ros::init(argc, argv, "navigation_goals");
  ros::NodeHandle nh("~"); 
  ros::Publisher state_pub = nh.advertise<asr_flir_ptu_driver::State>("/asr_flir_ptu_driver/state_cmd", 1);	


//Obtener los parámetros para el escaneado
  //nh.getParam("/scan_mode", scan_mode);
  //nh.getParam("/density_mode", density_mode);
  //nh.getParam("/emissivity_mode", emissivity_mode);
 
//...........................................
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
    while ( myfile >> x >> y >> theta >> modo >> tomas >> densidad >> emisividad >> color)
    {
    cout << x << "\t" << y  <<  "\t" << theta << endl;
    cout << modo <<"\t" << tomas <<"\t" << densidad  <<"\t" << emisividad <<"\t" << color  << endl;

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
    
    position++;

    if(ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED)
    {
      	ROS_INFO("Ha llegado correctamente");
	
	//GUARDA LA POSICIÓN
	tf::StampedTransform transform;
	try{
	listener.lookupTransform("/map","/base_footprint",ros::Time(0),transform);
	//ROS_INFO("x=%f, y=%f",transform.getOrigin().x(),transform.getOrigin().y());
	x_r = transform.getOrigin().x();
	y_r = transform.getOrigin().y();
	tf::Quaternion q = transform.getRotation();
	yaw = tf::getYaw(q);
}

	catch(tf::TransformException ex){
	ROS_ERROR("Error tf");
}

	if(modo!="home"){
		BLK(modo,densidad,tomas,position,x_r,y_r,yaw,emisividad,color);
	}

	/*ptu(-80,0,state_pub);
	ptu(-80,24,state_pub);
	
       
       	ptu(80,24,state_pub);
	
        BLK
	ptu(80,0,state_pub);
       	ptu(0,0,state_pub);
*/

    }
    else
      ROS_INFO("Ha habido un fallo");
    }

    myfile.close();
  }

  else cout << "Unable to open file"; 

	//ENVIAR
 	//system("scp -r /home/mopad/Escritorio/Nubes mopad@10.42.0.82:/home/mopad/Escritorio/data/");
	system("pscp -pw mopad -r /home/mopad/Escritorio/Nubes mopad@10.42.0.82:C:/Users/mopad/Desktop/BLK");

	//BORRAR
	system("rm -r /home/mopad/Escritorio/Nubes/*");
  return 0;
}
