{
  description = "Carla simulator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit (pkgs.lib) last versionAtLeast genAttrs concatMap;
      carla-bin-versions = import ./carla-bin/versions.nix { inherit pkgs; };
      allVersions = [ "0.9.12" "0.9.13" "0.9.14" "0.9.15" ];
      lastVersion = last allVersions;
    in {
      overlays = let
        overlayForVersion = version: final: prev: {
          carla-bin = carla-bin-versions.${version};
          carla-src = prev.callPackage (builtins.getAttr version (import ./carla-src/versions.nix)) {};
          libcarla-client = prev.callPackage carla-client/libcarla-client {};
          carla-py = prev.python3.pkgs.callPackage carla-client/carla-py {};
          carla-py-scripts = prev.callPackage carla-client/carla-py/scripts.nix {};
          osm2odr = prev.callPackage carla-client/osm2odr.nix {};
          recast = if versionAtLeast version "0.9.15"
                   then prev.callPackage carla-client/recastnavigation/0.9.15.nix {}
                   else prev.callPackage carla-client/recastnavigation {};
          rpclib = prev.callPackage carla-client/rpclib.nix {};
          opencv-python = prev.callPackage ./opencv-python {};
          scenic = prev.callPackage ./scenic {};
          scenario-runner = prev.callPackage ./scenario-runner {};
        };
      in
        genAttrs allVersions (v: overlayForVersion v);

      legacyPackages.x86_64-linux =
        genAttrs allVersions (version:
          # All packages from our overlay
          (builtins.intersectAttrs
            (self.overlays.${version} null null)
            (pkgs.extend self.overlays.${version})));

      packages.x86_64-linux =
        builtins.listToAttrs
          (concatMap (version:
            map (name: {
              name = "${name}-${builtins.replaceStrings ["."] ["_"] version}";
              value = (import nixpkgs {
                system = "x86_64-linux";
                overlays = [ self.overlays.${version} ];
              }).${name};
            }) (builtins.attrNames (self.overlays.${version} null null))
          ) allVersions)
        // {
          # Package that we provide since beginning (backward compatibility)
          ue4 = pkgs.callPackage ./carla-simulator/carla-ue4.nix {};
        };

      devShells.x86_64-linux = {
        # Attempt to have a shell where one can build CARLA
        default = import ./build-env/shell.nix { inherit pkgs; };
        carla-py = pkgs.mkShell {
          name = "Shell for running CARLA PythonAPI examples";
          packages = [
            (pkgs.python3.withPackages(p: [
              (pkgs.extend self.overlays.${lastVersion}).carla-py
              p.pygame
              p.transforms3d
              p.opencv4
              p.networkx
            ]))
          ];
        };
        carla-cpp = pkgs.mkShell {
          name = "Shell for building CARLA C++ examples";
          packages = [
            pkgs.bashInteractive
            self.packages.x86_64-linux."libcarla-client-${builtins.replaceStrings ["."] ["_"] lastVersion}"
            pkgs.libpng
            pkgs.libjpeg
            pkgs.libtiff
          ];
        };
      };
      checks.x86_64-linux = let
        maps-tar = pkgs.fetchurl {
          url = "https://carla-releases.s3.us-east-005.backblazeb2.com/Linux/AdditionalMaps_0.9.15.tar.gz";
          sha256 = "0hz11k26jp2rm9xfh9z6n5g53y799hzab5hz69x0y9j6rs04xbac";
        };
        maps = pkgs.runCommand "carla-maps" { } ''mkdir $out && cd $out && tar xf ${maps-tar}'';
      in {
        ci = pkgs.linkFarm "carla-all"
          (builtins.removeAttrs self.packages.x86_64-linux [ "ue4" ]);
        carla-with-maps = self.packages.x86_64-linux.carla-bin-0_9_15.withAssets [ maps-tar ];
        carla-with-maps-derivation = self.packages.x86_64-linux.carla-bin-0_9_15.withAssets [ maps ];
      };
    };
}
