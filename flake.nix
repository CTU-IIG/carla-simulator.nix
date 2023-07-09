{
  description = "Carla simulator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      carla-bin-versions = import ./carla-bin/versions.nix { inherit pkgs; };
      packagesInOverlay = self.overlays."0.9.12" null null;
    in {
      overlays = let
        overlayForVersion = version: final: prev: {
          #carla-bin = builtins.getAttr version (import ./carla-bin/versions.nix { pkgs = final; });
          carla-src = prev.callPackage (builtins.getAttr version (import ./carla-src/versions.nix)) {};
          carla-client = prev.callPackage carla-client/carla-client {};
          carla-py = prev.python3.pkgs.callPackage carla-client/carla-py {};
          osm2odr = prev.callPackage carla-client/osm2odr.nix {};
          recast = prev.callPackage carla-client/recastnavigation {};
          rpclib = prev.callPackage carla-client/rpclib.nix {};
          scenic = prev.callPackage ./scenic {};
        };
      in {
        "0.9.12" = overlayForVersion "0.9.12";
        "0.9.13" = overlayForVersion "0.9.13";
        "0.9.14" = overlayForVersion "0.9.14";
      };
      packages.x86_64-linux = {
        # Packages that we provide since beginning (backward compatibility)
        ue4 = pkgs.callPackage ./carla-simulator/carla-ue4.nix {};

        carla-bin_0_9_12 = carla-bin-versions."0.9.12";
        carla-bin_0_9_13 = carla-bin-versions."0.9.13";
        carla-bin_0_9_14 = carla-bin-versions."0.9.14";
      } // # Add also all packages from our overlay
      (builtins.intersectAttrs packagesInOverlay (pkgs.extend self.overlays."0.9.14"));
      devShells.x86_64-linux = {
        # Attempt to have a shell where one can build CARLA
        default = import ./build-env/shell.nix { inherit pkgs; };
        # A shell for running CARLA PythonAPI examples
        carla-py = pkgs.mkShell {
          name = "Shell for running CARLA PythonAPI examples";
          packages = [
            (pkgs.python3.withPackages(p: [
              (pkgs.extend self.overlays."0.9.14").carla-py
              p.pygame
              p.transforms3d
              p.opencv4
              p.networkx
            ]))
          ];
        };
      };
      checks.x86_64-linux.ci = let
        pkgsFromOverlay = version: pkgs.lib.attrsets.mapAttrs' (n: v: pkgs.lib.nameValuePair "${n}-${version}" v)
          (builtins.intersectAttrs packagesInOverlay (pkgs.extend (builtins.getAttr version self.overlays)));
      in
        pkgs.linkFarm "carla-all" (
          (builtins.removeAttrs self.packages.x86_64-linux [ "ue4" ])
          // (pkgsFromOverlay "0.9.12")
          // (pkgsFromOverlay "0.9.13")
          // (pkgsFromOverlay "0.9.14")
        );
    };
}
