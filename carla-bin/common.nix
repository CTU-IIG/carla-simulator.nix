{ version
, src-hash
}:
{ lib
, autoPatchelfHook
, fetchurl
, libglvnd
, libusb1
, libxkbcommon
, llvmPackages_8
, makeWrapper
, patchelf
, pigz
, stdenv
, systemd
, vulkan-loader
, xorg
, zlib
}:

let
  extraLibs = [
    libglvnd
    libxkbcommon
    systemd                     # for libudev
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXxf86vm
    vulkan-loader
  ];
  # Use our own wrapper in $out/bin/ instead of the original CarlaUE4.sh in $out/
  wrapCarlaUE4 = ''
    rm -f $out/CarlaUE4.sh
    makeWrapper $out/CarlaUE4/Binaries/Linux/CarlaUE4-Linux-Shipping $out/bin/CarlaUE4.sh \
      --prefix LD_LIBRARY_PATH : '${lib.makeLibraryPath extraLibs}' \
      --add-flags CarlaUE4
  '';
  carla = stdenv.mkDerivation rec {
    pname = "carla-bin";
    inherit version;
    src = fetchurl {
      url = "https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_${version}.tar.gz";
      sha256 = src-hash;
    };

    nativeBuildInputs = [
      pigz
      patchelf
    ];
    buildInputs = [
      autoPatchelfHook
      makeWrapper
      llvmPackages_8.openmp
      libusb1
      zlib
    ];

    dontUnpack = true;
      installPhase = ''
      mkdir -p $out
      cd $out
      pigz -dc $src | tar xf -
    '';

    postFixup = ''
      for i in libChronoModels_robot.so libChronoEngine_vehicle.so libChronoEngine.so libChronoModels_vehicle.so; do
        patchelf --replace-needed libomp.so.5 libomp.so $out/CarlaUE4/Plugins/Carla/CarlaDependencies/lib/$i
      done
      ${wrapCarlaUE4}
    '';

    meta.mainProgram = "CarlaUE4.sh";
  };
in
carla
