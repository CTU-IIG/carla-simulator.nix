{ buildRosPackage
, fetchFromGitHub
, colcon
, ros-environment
, ament-cmake-auto
, builtin-interfaces
, carla-msgs
, rosidl-default-generators
, ament-cmake-cppcheck
, ament-cmake-cpplint
, ament-cmake-uncrustify
, ament-cmake-flake8
, ament-cmake-pep257
, ament-lint-auto
, nav-msgs
, rviz-common
, tf2-eigen
, pcl-conversions
}:
buildRosPackage rec {
  pname = "carla-ros-bridge";
  version = "0.9.12";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "ros-bridge";
    rev = version;
    sha256 = "sha256-K98r7RpDVVUqZ5oEjygquXiY2dB9hMFK6hWu08BHnRw=";
  };

  buildType = "colcon";
  nativeBuildInputs = [ colcon ];
  buildInputs = [
    ros-environment
    ament-cmake-auto
    builtin-interfaces
    carla-msgs
    rosidl-default-generators
    ament-cmake-cppcheck
    ament-cmake-cpplint
    ament-cmake-uncrustify
    ament-cmake-flake8
    ament-cmake-pep257
    ament-lint-auto
    nav-msgs
    rviz-common
    tf2-eigen
    pcl-conversions
  ];
  sourceRoot = "carla-ros-bridge";
  unpackPhase = ''
    mkdir -p carla-ros-bridge/src
    cp -r $src carla-ros-bridge/src/ros-bridge
    chmod -R u+w -- carla-ros-bridge
  '';
  buildPhase = ''
    colcon build --merge-install --install-base $out
  '';
  dontConfigure = true;
  dontInstall = true;
}
