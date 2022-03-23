#include <ros/ros.h>
#include "asr_flir_ptu_driver/State.h"
#include <sensor_msgs/JointState.h>


using namespace std;


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

int main(int argc, char **argv)
{
	ros::init(argc, argv, "my_ptu");
	ros::NodeHandle nh;
	ros::Publisher state_pub = nh.advertise<asr_flir_ptu_driver::State>("/asr_flir_ptu_driver/state_cmd", 1);

	ptu(-90,0,state_pub);
	/*ptu(-90,-40,state_pub);
	ros::Duration(10).sleep();
       //BLK
	ptu(-90,0,state_pub);
	ptu(90,0,state_pub);
       	ptu(90,-40,state_pub);
	ros::Duration(10).sleep();
       //BLK
	ptu(90,0,state_pub);*/
	ros::Duration(1).sleep();
     	ptu(0,0,state_pub);	
} 

