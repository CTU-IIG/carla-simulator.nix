{ pkgs ? import <nixpkgs> {} }:
with pkgs;
(buildFHSEnv {
  pname = "carla-build";
  targetPkgs = pkgs: with pkgs; [
    # Unreal Engine
    #mono
    #clang_10
    #gcc7
    cmake
    ninja

    which
    xdg-utils
    xdg-user-dirs

    python3Packages.pip
    python3

    # clang-10 lld-10 g++-7 cmake ninja-build libvulkan1 python
    # python-dev python3-dev python3-pip libpng-dev libtiff5-dev
    # libjpeg-dev tzdata sed curl unzip autoconf libtool rsync
    # libxml2-dev git

    # CARLA
    aria2
    util-linux
    wget
    cacert
    git
    zlib.dev
    zlib
    #zlib.static
    autoconf
    automake
    rsync
    #llvmPackages_10.libcxx llvmPackages_10.libcxxabi
  ];

  # Currently, we rely on nix-ld (https://github.com/Mic92/nix-ld) to
  # have a working development environment on NixOS. Hopefully, we'll
  # be able to get rid of it later.
  #NIX_LD = "${glibc}/lib/ld-linux-x86-64.so.2";
  #NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker"; # works in nix-shell only
  multiPkgs = pkgs: with pkgs; [
    #stdenv.cc.cc.lib
    #mono
    zlib

    xorg.libX11 xorg.libXScrnSaver xorg.libXau xorg.libXcursor xorg.libXext
    xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXxf86vm
    xorg.libxcb

    udev
    vulkan-loader
  ];

  profile = let
    sysroot = pkgs.buildEnv {
      name = "carla-sysroot";
      paths = [
        pkgs.llvmPackages_10.libcxx
        pkgs.llvmPackages_10.libcxx.dev
        pkgs.llvmPackages_10.libcxxabi
        #pkgs.llvmPackages_10.libcxxabi.dev
        pkgs.llvmPackages_10.compiler-rt
        #pkgs.llvmPackages_10.compiler-rt.dev
      ];
    };
  in ''
    export UE4_ROOT=~/src/carla/nix/build-env/UnrealEngine_4.26
    cd ~/src/carla/carla
    # sed -i -e s,\$UE4_ROOT/Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64/v17_clang-10.0.1-centos7/x86_64-unknown-linux-gnu,${pkgs.llvmPackages_10.clang}, \
    #   Util/BuildTools/*.sh

    export CC="${pkgs.llvmPackages_10.clang}/bin/clang"
    export CXX="${pkgs.llvmPackages_10.clang}/bin/clang++"
    export PATH="${pkgs.llvmPackages_10.clang}/bin:$PATH"

    export LLVM_INCLUDE=${sysroot}/include/c++/v1
    export LLVM_LIBPATH=${sysroot}/lib

    export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
    # compatibility
    #  - openssl
    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
    #  - Haskell x509-system
    export SYSTEM_CERTIFICATE_PATH=/etc/ssl/certs/ca-bundle.crt

    TERM=xterm
  '';

}).env
