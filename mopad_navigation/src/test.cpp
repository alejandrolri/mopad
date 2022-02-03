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

string BLK(bool mode,string density,string emissivity_mode)
{
	string route, scan, emissivity;
        
	if (mode==false) {//OnlyPointCloud
		route = "adquisitionOnlyPointCloud";
		scan = "DownloadPC";
	}
	else{		//PCandIR
		route = "adquisitionPCAndIR";
		scan = "DownloadPCAndIR";		
		emissivity=emissivity_mode;
	}	

	//string param = "cd ~ && export DISPLAY=:0.0 && ./blk/"+route+" "+density+" "+emissivity;
	string param_ssh = "ssh mopad@10.42.0.1 \"cd blk/"+route+" && export DISPLAY=:0.0 && ./"+scan+" "+density+" "+emissivity+" \"";
	//cout<<param_ssh<<endl;
	int n_ssh = param_ssh.length();
	char command_ssh[n_ssh+1];
	strcpy(command_ssh, param_ssh.c_str()); //system solo acepta char
	
	/*string param_pscp = "pscp -pw mopad -r mopad@10.42.0.1:/home/mopad/blk/"+route+"/data /home/mopad/Escritorio";
	int n_pscp = param_pscp.length();
	char command_pscp[n_pscp+1];
	strcpy(command_pscp, param_pscp.c_str());

	string param_rm = "ssh mopad@10.42.0.1 rm /home/mopad/blk/"+route+"/data/*";
	int n_rm = param_rm.length();
	char command_rm[n_rm+1];
	strcpy(command_rm, param_rm.c_str()); */	

        system(command_ssh);
	//system(command_pscp);
	//system(command_rm);

	return route;
	
	/*system(command);
	system("cp -r /home/mopad/data /home/mopad/Escritorio"); ///media/windows/Users/mopad/Desktop  
	system("cp /home/mopad/catkin_ws/src/mopad_navigation/paths/ruta.txt /home/mopad/Escritorio/data"); 	
	system("rm /home/mopad/data/*");*/
	}

void send(string route,int position)
{
	string param_dir = "/home/mopad/Escritorio/data/position"+to_string(position);
	int n_dir = param_dir.length();
	char command_dir[n_dir+1];
	strcpy(command_dir, param_dir.c_str());
	
	string param_pscp = "pscp -pw mopad -r mopad@10.42.0.1:/home/mopad/blk/"+route+"/data/* /home/mopad/Escritorio/data/position"+to_string(position);
	int n_pscp = param_pscp.length();
	char command_pscp[n_pscp+1];
	strcpy(command_pscp, param_pscp.c_str());

	string param_rm = "ssh mopad@10.42.0.1 rm /home/mopad/blk/"+route+"/data/*";
	int n_rm = param_rm.length();
	char command_rm[n_rm+1];
	strcpy(command_rm, param_rm.c_str());

	mkdir(command_dir,0777);
	system(command_pscp);
	system(command_rm);
}


int main(int argc, char** argv){
  
  int position = 0;
  double x, y, theta;
  bool scan_mode;
  string density_mode, emissivity_mode, route;

  ros::init(argc, argv, "navigation_goals");
  ros::NodeHandle nh("~"); 
  ros::Publisher state_pub = nh.advertise<asr_flir_ptu_driver::State>("/asr_flir_ptu_driver/state_cmd", 1);	

//Obtener los parámetros para el escaneado
  nh.getParam("/scan_mode", scan_mode);
  nh.getParam("/density_mode", density_mode);
  nh.getParam("/emissivity_mode", emissivity_mode);
 

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
    while ( myfile >> x >> y >> theta)
    {
    cout << x <<"\t" << y <<"\t" << theta << endl;

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
	route = BLK(scan_mode,density_mode,emissivity_mode); //Devuelve la ruta para la funcion send
	send(route,position);

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

  system("cp /home/mopad/catkin_ws/src/mopad_navigation/paths/ruta.txt /home/mopad/Escritorio/data");

  return 0;
}
