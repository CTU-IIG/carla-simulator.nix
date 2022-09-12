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
in
stdenv.mkDerivation rec {
  pname = "carla-bin";
  version = "0.9.12";
  src = fetchurl {
    url = "https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_${version}.tar.gz";
    sha256 = "04vgcsmai9bhq8bpzmaq1jcmqk7w42irkwi2x457vf266hy1ha8x";
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
    wrapProgram $out/CarlaUE4.sh --prefix LD_LIBRARY_PATH : '${lib.makeLibraryPath extraLibs}'
  '';
}
