{
  inputs = {
    nixpkgs.url = "nixpkgs";
    carla = { url = "github:CTU-IIG/carla-simulator.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };
  outputs = { self, nixpkgs, carla }: {
    nixosConfigurations."carla-box" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ carla.overlays."0.9.14" ];
          environment.systemPackages = [ pkgs.carla-bin ];
          boot.isContainer = true;
        })
      ];
    };
  };
}
