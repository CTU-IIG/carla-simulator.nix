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
          carla-client = prev.callPackage (builtins.getAttr version (import carla-client/carla-client/versions.nix)) {};
          carla-py = prev.python3.pkgs.callPackage (builtins.getAttr version (import carla-client/carla-py/versions.nix)) {};
          osm2odr = prev.callPackage carla-client/osm2odr.nix {};
          recast = prev.callPackage carla-client/recastnavigation {};
          rpclib = prev.callPackage carla-client/rpclib.nix {};
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
      devShells.x86_64-linux.default = import ./build-env/shell.nix { inherit pkgs; };
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
