# Automatically generated by: ros2nix --nixfmt --distro noetic --fetch --output-dir ../nix/carla-ros-bridge --output-as-nix-pkg-name
{
  lib,
  buildRosPackage,
  fetchFromGitHub,
  carla-common,
  carla-manual-control,
  carla-msgs,
  carla-spawn-objects,
  catkin,
  cv-bridge,
  derived-object-msgs,
  geometry-msgs,
  nav-msgs,
  python3Packages,
  ros-compatibility,
  rosbag-storage,
  rosgraph-msgs,
  roslaunch,
  rospy,
  sensor-msgs,
  shape-msgs,
  std-msgs,
  tf,
  tf2,
  tf2-msgs,
  visualization-msgs,
}:
buildRosPackage rec {
  pname = "ros-noetic-carla-ros-bridge";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "ros-bridge";
    rev = "e9063d97ff5a724f76adbb1b852dc71da1dcfeec";
    sha256 = "1zfmsgr9xiaj45mvjxjdfklwpy8yipjqsicgr5qxnlazzzhr5nmk";
  };

  buildType = "catkin";
  sourceRoot = "${src.name}/carla_ros_bridge/";
  buildInputs = [
    catkin
    roslaunch
  ];
  propagatedBuildInputs = [
    carla-common
    carla-manual-control
    carla-msgs
    carla-spawn-objects
    cv-bridge
    derived-object-msgs
    geometry-msgs
    nav-msgs
    python3Packages.transforms3d
    ros-compatibility
    rosbag-storage
    rosgraph-msgs
    rospy
    sensor-msgs
    shape-msgs
    std-msgs
    tf
    tf2
    tf2-msgs
    visualization-msgs
  ];
  nativeBuildInputs = [ catkin ];

  meta = {
    description = "The carla_ros_bridge package";
    license = with lib.licenses; [ mit ];
  };
}
