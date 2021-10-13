#include <ros/ros.h>
#include <move_base_msgs/MoveBaseAction.h>
#include <actionlib/client/simple_action_client.h>

#include <tf2/LinearMath/Quaternion.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

#include <fstream> // Para leer el archivo
#include <iostream>

#include "asr_flir_ptu_driver/State.h"
#include <sensor_msgs/JointState.h>

using namespace std;

typedef actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> MoveBaseClient;
//.......................................................................
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
{	for(int i=0;i<2;i++) //Manera de que envíe solo un mensaje
	{
	asr_flir_ptu_driver::State movement_goal;
	sensor_msgs::JointState joint_state = createJointCommand(pan, tilt, 0, 0);

	movement_goal.state = joint_state;
	state_pub.publish(movement_goal);
        ros::Duration(3).sleep();
	}
}
//..................................................................

int main(int argc, char** argv){
  double x, y, theta;
  ros::init(argc, argv, "navigation_goals");
//..................................................
  ros::NodeHandle nh;
  ros::Publisher state_pub = nh.advertise<asr_flir_ptu_driver::State>("/asr_flir_ptu_driver/state_cmd", 1);	
//..................................................

  tf2::Quaternion myQ;


  //tell the action client that we want to spin a thread by default
  MoveBaseClient ac("move_base", true);


  //wait for the action server to come up
  while(!ac.waitForServer(ros::Duration(5.0))){
    ROS_INFO("Waiting for the move_base action server to come up");
  }

//..............
  ifstream myfile;
  myfile.open("/home/alejandro/catkin_ws/src/mopad_navigation/paths/ruta.txt");
 if (myfile.is_open())
  { 
    cout << "abierto" <<"\n";
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

    if(ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED)
    {
      	ROS_INFO("Ha llegado correctamente");
	ptu(-80,0,state_pub);
	ptu(-80,24,state_pub);
	ros::Duration(10).sleep();
       //BLK
       	ptu(80,24,state_pub);
	ros::Duration(10).sleep();
       //BLK
	ptu(80,0,state_pub);
       	ptu(0,0,state_pub);
    }
    else
      ROS_INFO("Ha habido un fallo");
    }



    myfile.close();
  }

  else cout << "Unable to open file"; 

//.................

  return 0;
}
