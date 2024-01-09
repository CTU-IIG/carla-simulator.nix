{ pkgs }:
let
  hashes = {
    "0.9.12" = "04vgcsmai9bhq8bpzmaq1jcmqk7w42irkwi2x457vf266hy1ha8x";
    "0.9.13" = "aac2147197d69fa76abc3c74f9db3e293ceb5e031b795eba509e26d954d6e97d";
    "0.9.14" = "sha256-3SBze9jhpSL0D6EbHPMBSk3viRTFQddN84j2AiBrQlI=";
    "0.9.15" = "sha256-ey9DLOdLJRWT+V3Mje5tma2WJcKnGi1tSPJNh53hnvc=";
  };
  carla = version: src-hash: pkgs.callPackage (import ./common.nix { inherit version src-hash; }) {};
in
builtins.mapAttrs carla hashes
