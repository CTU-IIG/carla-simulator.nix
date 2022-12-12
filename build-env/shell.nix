with import <nixpkgs> {};
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
  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
}
