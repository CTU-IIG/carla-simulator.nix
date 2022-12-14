{ pkgs }:
let
  # A wrapper, which has CarlaUE4.sh in /bin rather than in /.
  carla-wrapper = carla: pkgs.writeShellScriptBin "CarlaUE4.sh" ''
    exec ${carla}/CarlaUE4.sh "$@"
  '';
  wrap-carla = {...}@args:
    let carla = pkgs.callPackage (import ./carla.nix {
          inherit (args) version src-hash;
        }) {};
    in
      carla-wrapper carla;
in {
  "0.9.12" = wrap-carla {
    version = "0.9.12";
    src-hash = "04vgcsmai9bhq8bpzmaq1jcmqk7w42irkwi2x457vf266hy1ha8x";
  };
  "0.9.13" = wrap-carla {
      version = "0.9.13";
      src-hash = "aac2147197d69fa76abc3c74f9db3e293ceb5e031b795eba509e26d954d6e97d";
    };
}
