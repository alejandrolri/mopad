#include <ros/ros.h>
#include <move_base_msgs/MoveBaseAction.h>
#include <actionlib/client/simple_action_client.h>

#include <tf2/LinearMath/Quaternion.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

#include <fstream> // Para leer el archivo
std::ifstream infile("/home/rafaelm/own_ws/src/uvone_robot/uvone_robot_navigation/paths/ruta.txt");

typedef actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> MoveBaseClient;

int main(int argc, char** argv){
  double x, y, theta;
  ros::init(argc, argv, "simple_navigation_goals");

  tf2::Quaternion myQ;

  //tell the action client that we want to spin a thread by default
  MoveBaseClient ac("move_base", true);

  //wait for the action server to come up
  while(!ac.waitForServer(ros::Duration(5.0))){
    ROS_INFO("Waiting for the move_base action server to come up");
  }


  while (infile >> x >> y >> theta)
  {
    
    move_base_msgs::MoveBaseGoal goal;
    goal.target_pose.header.frame_id = "map";
    goal.target_pose.header.stamp = ros::Time::now();

    myQ.setRPY(0, 0, theta);

    goal.target_pose.pose.position.x = x;
    goal.target_pose.pose.position.y = y;
    tf2::convert(myQ, goal.target_pose.pose.orientation);

    ROS_INFO("Moviendose a la siguiente posicion.");
    ac.sendGoal(goal);

    ac.waitForResult();

    ros::Duration(0.1).sleep();

    if(ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED)
      ROS_INFO("Ha llegado correctamente");
    else
      ROS_INFO("The base failed for some reason");
  }

  return 0;
}