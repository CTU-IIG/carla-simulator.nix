# Nix expressions for the CARLA simulator

> This is a work-in-progress. The interface can change any time.

The repository contains a [Nix flake][] with the CARLA simulator and
related tools. Its content is as follows:

<!-- `$ nix flake show` -->
```
git+file:///home/wsh/src/carla/nix
├───checks
│   └───x86_64-linux
│       └───ci: derivation 'carla-all'
├───devShells
│   └───x86_64-linux
│       ├───carla-py: development environment 'Shell-for-running-CARLA-PythonAPI-examples'
│       └───default: development environment 'nix-shell'
├───overlays
│   ├───"0.9.12": Nixpkgs overlay
│   ├───"0.9.13": Nixpkgs overlay
│   └───"0.9.14": Nixpkgs overlay
└───packages
    └───x86_64-linux
        ├───carla-bin_0_9_12: package 'CarlaUE4.sh'
        ├───carla-bin_0_9_13: package 'CarlaUE4.sh'
        ├───carla-bin_0_9_14: package 'CarlaUE4.sh'
        ├───carla-client: package 'carla-client-0.9.14'
        ├───carla-py: package 'python3.10-carla-py-0.9.14'
        ├───carla-src: package 'source'
        ├───opencv-python: package 'python3.10-opencv-python-4.8.0.74'
        ├───osm2odr: package 'osm2odr-0.pre+date=2022-08-30'
        ├───recast: package 'recast-0.pre+date=2022-08-30'
        ├───rpclib: package 'rpclib-0.pre+date=2022-08-30'
        ├───scenario-runner: package 'python3.10-scenario-runner-0.9.13'
        ├───scenic: package 'python3.10-scenic-2.1.0'
        └───ue4: package 'ue4-carla-0.9.13-wrapper'
```

The outputs are documented in more detail below. Unfinished
(experimental) outputs are omitted.

### `devShells`

To quickly try CARLA Python bindings from this repository, execute
CARLA and then run:

    nix develop .#carla-py
    cd <CARLA_SOURCES>/PythonAPI/examples
    ./manual_control.py

If you have trouble getting graphical output on non-NixOS
distribution, use [NixGL][], e.g.:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:guibou/nixGL -- ./manual_control.py
```

[NixGL]: https://github.com/guibou/nixGL

### `overlays`

Overlays output contains [Nixpkgs overlays][] for different CARLA
versions. Use these in you Nix expressions.

### `packages`

The `packages` output contains CARLA binary releases as well as the
packages from the latest overlay applied over a random nixpkgs version
(locked in `flake.lock`).

Use these, for example, to run or install the packages on your
computer, e.g.:

    nix run github:CTU-IIG/carla-simulator.nix#carla-bin_0_9_14
    nix profile install github:CTU-IIG/carla-simulator.nix#scenic

## TODO

We wanted to build Carla and Unreal Engine from source via Nix.
However, this is tricky and currently, it's not our top priority.

## Contact

Feel free to contact us by submitting [issues][].

[Nix flake]: https://nixos.wiki/wiki/Flakes
[Scenic]: https://github.com/BerkeleyLearnVerify/Scenic
[Nixpkgs overlays]: https://nixos.wiki/wiki/Overlays
[issues]: https://github.com/CTU-IIG/carla-simulator.nix/issues

<!-- Local Variables: -->
<!-- compile-command: "mdsh" -->
<!-- End: -->
