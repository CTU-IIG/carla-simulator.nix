# Nix expressions for the CARLA simulator

> This is a work-in-progress. The interface can change any time.

To use this repository, you have to [install Nix][].

The repository contains a [Nix flake][] with the CARLA simulator and
related tools. Its content is as follows:

<!-- `$ nix flake show | sed -e '1ccarla-simulator.nix'` -->
```
carla-simulator.nix
├───checks
│   └───x86_64-linux
│       └───ci: derivation 'carla-all'
├───devShells
│   └───x86_64-linux
│       ├───carla-cpp: development environment 'Shell-for-building-CARLA-C++-examples'
│       ├───carla-py: development environment 'Shell-for-running-CARLA-PythonAPI-examples'
│       └───default: development environment 'nix-shell'
├───overlays
│   ├───"0.9.12": Nixpkgs overlay
│   ├───"0.9.13": Nixpkgs overlay
│   ├───"0.9.14": Nixpkgs overlay
│   ├───"0.9.15": Nixpkgs overlay
│   └───local: Nixpkgs overlay
└───packages
    └───x86_64-linux
        ├───carla-bin_0_9_12: package 'CarlaUE4.sh'
        ├───carla-bin_0_9_13: package 'CarlaUE4.sh'
        ├───carla-bin_0_9_14: package 'CarlaUE4.sh'
        ├───carla-bin_0_9_15: package 'CarlaUE4.sh'
        ├───carla-py: package 'python3.10-carla-py-0.9.15'
        ├───carla-py-scripts: package 'carla-py-scripts-0.9.15'
        ├───carla-src: package 'source'
        ├───libcarla-client: package 'libcarla-client-0.9.15'
        ├───opencv-python: package 'python3.10-opencv-python-4.8.1.78'
        ├───osm2odr: package 'osm2odr-0.pre+date=2022-08-30'
        ├───recast: package 'recast-0.pre+date=2023-02-21'
        ├───rpclib: package 'rpclib-0.pre+date=2022-08-30'
        ├───scenario-runner: package 'python3.10-scenario-runner-0.9.13'
        ├───scenic: package 'python3.10-scenic-2.1.0'
        └───ue4: package 'ue4-carla-0.9.13-wrapper'
```

The outputs are documented in more detail below. Unfinished
(experimental) outputs are omitted.

### `devShells`

#### Python

To quickly try CARLA Python bindings from this repository, execute
CARLA (e.g. via [a package in this repo](#packages)) and then run:

    nix develop .#carla-py
    cd <CARLA_SOURCES>/PythonAPI/examples
    ./manual_control.py

If you have trouble getting graphical output on non-NixOS
distribution, use [NixGL][], e.g.:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:guibou/nixGL -- ./manual_control.py
```

[NixGL]: https://github.com/guibou/nixGL

#### C++

To compile CARLA `CppClient` example, run:

    nix develop .#carla-cpp
    cd <CARLA_SOURCES>/Examples/CppClient
    g++ -std=c++14 -pthread -fPIC -O3 -DNDEBUG -Werror -Wall -Wextra -o cpp_client main.cpp \
        -Wl,-Bstatic -lcarla_client -lrpc \
        -Wl,-Bdynamic -lpng -ltiff -ljpeg -lRecast -lDetour -lDetourCrowd -lboost_filesystem


Instead of running `g++` manually, you can use the `Makefile` coming
with the example, but you need to modify it not to use hardcoded
compiler paths, not to build `libcarla` and to link `boost_filesystem`
dynamically.

### `overlays`

Overlays output contains [Nixpkgs overlays][] for different CARLA
versions. Use these in you Nix expressions.

### `packages`

The `packages` output contains CARLA binary releases as well as the
packages from the latest overlay applied to a random nixpkgs version
(locked in `flake.lock`).

Use these, for example, to run or install the packages on your
computer, e.g.:

- `nix run github:CTU-IIG/carla-simulator.nix#carla-bin_0_9_14`
- `nix profile install github:CTU-IIG/carla-simulator.nix#scenic`

## TODO

We wanted to build Carla and Unreal Engine from source via Nix.
However, this is tricky and currently, it's not our top priority.
It should work as follows:

- Building Unreal Engine:

  ```sh
  cd build-env
  nix-shell
  ```

  Then follow the official Carla build instructions. Note that this is
  not yet complete and compilation will likely fail at some stage.


## Contact

Feel free to contact us by submitting [issues][].

[install Nix]: https://nixos.org/download.html#download-nix
[Nix flake]: https://nixos.wiki/wiki/Flakes
[Scenic]: https://github.com/BerkeleyLearnVerify/Scenic
[Nixpkgs overlays]: https://nixos.wiki/wiki/Overlays
[issues]: https://github.com/CTU-IIG/carla-simulator.nix/issues

<!-- Local Variables: -->
<!-- compile-command: "mdsh" -->
<!-- End: -->
