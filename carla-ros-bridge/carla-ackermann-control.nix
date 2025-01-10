# Automatically generated by: ros2nix --nixfmt --distro noetic --fetch --output-dir ../nix/carla-ros-bridge --output-as-nix-pkg-name
{
  lib,
  buildRosPackage,
  fetchFromGitHub,
  ackermann-msgs,
  carla-ackermann-msgs,
  carla-msgs,
  carla-ros-bridge,
  catkin,
  dynamic-reconfigure,
  ros-compatibility,
  roslaunch,
  rospy,
  std-msgs,
}:
buildRosPackage rec {
  pname = "ros-noetic-carla-ackermann-control";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "ros-bridge";
    rev = "e9063d97ff5a724f76adbb1b852dc71da1dcfeec";
    sha256 = "1zfmsgr9xiaj45mvjxjdfklwpy8yipjqsicgr5qxnlazzzhr5nmk";
  };

  buildType = "catkin";
  sourceRoot = "${src.name}/carla_ackermann_control/";
  buildInputs = [
    catkin
    roslaunch
  ];
  propagatedBuildInputs = [
    ackermann-msgs
    carla-ackermann-msgs
    carla-msgs
    carla-ros-bridge
    dynamic-reconfigure
    ros-compatibility
    rospy
    std-msgs
  ];
  nativeBuildInputs = [ catkin ];

  meta = {
    description = "The carla_ackermann_control package";
    license = with lib.licenses; [ mit ];
  };
}
