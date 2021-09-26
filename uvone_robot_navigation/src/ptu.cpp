#include "ros/ros.h"
#include "asr_flir_ptu_driver/State.h"
#include <sensor_msgs/JointState.h>

int main()    {
		sensor_msgs::JointState joint_state = createJointCommand(panSlider->GetValue(), tiltSlider->GetValue(), 0, 0);
        asr_flir_ptu_driver::State msg;
        msg.state = joint_state;
        seq_num++;
        msg.seq_num = seq_num;
        jointStatePublisher.publish(msg);
	
	ros::spinOnce();
	if (!ros::ok())
	{
		Close();
	}
}

sensor_msgs::JointState PTU_GUI::createJointCommand(double pan, double tilt, double panSpeed, double tiltSpeed) {
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

