final: prev:
{
  carla-ackermann-control = final.callPackage ./carla-ackermann-control.nix {};
  carla-ackermann-msgs = final.callPackage ./carla-ackermann-msgs.nix {};
  carla-ad-agent = final.callPackage ./carla-ad-agent.nix {};
  carla-ad-demo = final.callPackage ./carla-ad-demo.nix {};
  carla-common = final.callPackage ./carla-common.nix {};
  carla-manual-control = final.callPackage ./carla-manual-control.nix {};
  carla-msgs = final.callPackage ./carla-msgs.nix {};
  carla-ros-bridge = final.callPackage ./carla-ros-bridge.nix {};
  carla-ros-scenario-runner = final.callPackage ./carla-ros-scenario-runner.nix {};
  carla-ros-scenario-runner-types = final.callPackage ./carla-ros-scenario-runner-types.nix {};
  carla-spawn-objects = final.callPackage ./carla-spawn-objects.nix {};
  carla-twist-to-control = final.callPackage ./carla-twist-to-control.nix {};
  carla-walker-agent = final.callPackage ./carla-walker-agent.nix {};
  carla-waypoint-publisher = final.callPackage ./carla-waypoint-publisher.nix {};
  carla-waypoint-types = final.callPackage ./carla-waypoint-types.nix {};
  pcl-recorder = final.callPackage ./pcl-recorder.nix {};
  ros-compatibility = final.callPackage ./ros-compatibility.nix {};
  rqt-carla-control = final.callPackage ./rqt-carla-control.nix {};
  rviz-carla-plugin = final.callPackage ./rviz-carla-plugin.nix {};
}
