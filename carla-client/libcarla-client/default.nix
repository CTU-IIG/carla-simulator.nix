{ stdenv
, cmake
, boost
, rpclib
, recast
, carla-src
, enableDebug ? false
, runCommandLocal
}:

stdenv.mkDerivation rec {
  pname = "libcarla-client";
  version = carla-src.meta.version;

  src = runCommandLocal "LibCarla-copy" { } "cp -aT ${carla-src}/LibCarla/ $out";

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost rpclib recast ];
  patches = [
    ./carla_client.patch
    ./libcarla-Fix-compile-error-with-gcc-13.patch
    # Work around a segfault (and warn about the problem). The problem seems
    # to be related to the incorrect content of a map cache, e.g.:
    # CarlaUE4/Content/map_package/Maps/bdsc_export/TM/bdsc_export.bin.
    # Deleting this file removes the segfaults, but the following is printed:
    # "WARNING: No InMemoryMap cache found. Setting up local map. This may
    # take a while...". The time seems to be short for our maps.
    ./work-around-segfaults-in-the-traffic-manager.patch
  ];
  cmakeFlags = [
    "../cmake"
    "-DCMAKE_BUILD_TYPE=Client"
    "-DLIBCARLA_BUILD_DEBUG=${if enableDebug then "ON" else "OFF"}"
    "-DLIBCARLA_BUILD_RELEASE=${if !enableDebug then "ON" else "OFF"}"
    "-DCARLA_VERSION=${version}"
    "-DLIBCARLA_BUILD_TEST=OFF"
  ];
  # Have debug information also in the release build (to debug crashes)
  #CXXFLAGS = "-g";
  installPhase = ''
    mkdir -p $out/lib
    cp client/libcarla_client*.a $out/lib/libcarla_client.a
    mkdir -p $out/include/carla
    pushd ../source/carla
    cp *.h $out/include/carla
    cp --parents */*.h $out/include/carla
    cp --parents */*/*.h $out/include/carla
    popd
  '';
}
