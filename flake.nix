{
  description = "Carla simulator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      packages.x86_64-linux = rec {
        ue4 = pkgs.callPackage ./carla-simulator/carla-ue4.nix {};

        carla-client = pkgs.callPackage carla-client/carla-client/0.9.14.nix { inherit rpclib recast; };
        carla-py = pkgs.python3.pkgs.callPackage carla-client/carla-py/0.9.14.nix { inherit carla-client rpclib recast osm2odr; };
        #carla-ros-bridge = pkgs.callPackage carla-client/carla_ros_bridge.nix {};
        osm2odr = pkgs.callPackage carla-client/osm2odr.nix {};
        recast = pkgs.callPackage carla-client/recastnavigation {};
        rpclib = pkgs.callPackage carla-client/rpclib.nix {};
      };
      devShells.x86_64-linux.default = import ./build-env/shell.nix { inherit pkgs; };
      checks.x86_64-linux.ci = pkgs.linkFarm "all" (builtins.removeAttrs self.packages.x86_64-linux [ "ue4" ]);
    };
}
