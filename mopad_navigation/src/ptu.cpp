#include <ros/ros.h>
#include "asr_flir_ptu_driver/State.h"
#include <sensor_msgs/JointState.h>

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


int main(int argc, char **argv)
{
	ros::init(argc, argv, "my_ptu");
	ros::NodeHandle nh;
	ros::Publisher state_pub = nh.advertise<asr_flir_ptu_driver::State>("/asr_flir_ptu_driver/state_cmd", 1);	

	double pan = 10;
	double tilt = 10;

	for(int i=0;i<2;i++)
	{
	asr_flir_ptu_driver::State movement_goal;
	sensor_msgs::JointState joint_state = createJointCommand(pan, tilt, 0, 0);

	movement_goal.state = joint_state;
	state_pub.publish(movement_goal);
        ros::Duration(5).sleep();
	}
}
