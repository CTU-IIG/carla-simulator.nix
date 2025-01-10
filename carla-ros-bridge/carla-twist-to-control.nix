# Automatically generated by: ros2nix --nixfmt --distro noetic --fetch --output-dir ../nix/carla-ros-bridge --output-as-nix-pkg-name
{
  lib,
  buildRosPackage,
  fetchFromGitHub,
  carla-msgs,
  catkin,
  geometry-msgs,
  roslaunch,
  rospy,
}:
buildRosPackage rec {
  pname = "ros-noetic-carla-twist-to-control";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "ros-bridge";
    rev = "e9063d97ff5a724f76adbb1b852dc71da1dcfeec";
    sha256 = "1zfmsgr9xiaj45mvjxjdfklwpy8yipjqsicgr5qxnlazzzhr5nmk";
  };

  buildType = "catkin";
  sourceRoot = "${src.name}/carla_twist_to_control/";
  buildInputs = [
    catkin
    roslaunch
  ];
  propagatedBuildInputs = [
    carla-msgs
    geometry-msgs
    rospy
  ];
  nativeBuildInputs = [ catkin ];

  meta = {
    description = "The carla_twist_to_control package";
    license = with lib.licenses; [ mit ];
  };
}
