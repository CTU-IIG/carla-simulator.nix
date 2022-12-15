# Nix expressions for Carla simulator

This is a work-ip-progress. The interface can change any time.

To use this repository, you have to [install Nix][].

Available functionality:
- Build Carla client library and its Python bindings:
  ```sh
  nix build .#carla-py
  ```
- Building Unreal Engine
  ```sh
  cd build-env
  nix-shell
  ```
  Then follow the official Carla build instructions. Note that this is
  not yet complete and compilation likely fails at some stage.

[install Nix]: https://nixos.org/download.html#download-nix
