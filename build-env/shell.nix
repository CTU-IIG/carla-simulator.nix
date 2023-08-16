{ pkgs ? import <nixpkgs> {} }:
with pkgs;
mkShell {
  nativeBuildInputs = [
    bashInteractive
    mono
    clang_10
    gcc7
    cmake
    ninja

    which
    xdg-user-dirs

    python3Packages.pip
    python3

    # clang-10 lld-10 g++-7 cmake ninja-build libvulkan1 python
    # python-dev python3-dev python3-pip libpng-dev libtiff5-dev
    # libjpeg-dev tzdata sed curl unzip autoconf libtool rsync
    # libxml2-dev git
  ];

  # Currently, we rely on nix-ld (https://github.com/Mic92/nix-ld) to
  # have a working development environment on NixOS. Hopefully, we'll
  # be able to get rid of it later.
  NIX_LD = "${glibc}/lib/ld-linux-x86-64.so.2";
  #NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker"; # works in nix-shell only
  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    mono
    zlib

    xorg.libX11 xorg.libXScrnSaver xorg.libXau xorg.libXcursor xorg.libXext
    xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXxf86vm
    xorg.libxcb

    udev
    vulkan-loader
  ];
}
