{
  description = "Carla simulator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      packages.x86_64-linux = rec {
        ue4 = pkgs.callPackage ./carla-simulator/carla-ue4.nix {};

        carla-client = pkgs.callPackage carla-client/carla_client.nix { inherit rpclib recast; };
        carla-py = pkgs.python39.pkgs.callPackage carla-client/carla_py.nix { inherit carla-client rpclib recast osm2odr; };
        #carla-ros-bridge = pkgs.callPackage carla-client/carla_ros_bridge.nix {};
        osm2odr = pkgs.callPackage carla-client/osm2odr.nix {};
        recast = pkgs.callPackage carla-client/recast.nix {};
        rpclib = pkgs.callPackage carla-client/rpclib.nix {};
      };
      devShells.x86_64-linux.default = import ./build-env/shell.nix { inherit pkgs; };
    };
}
