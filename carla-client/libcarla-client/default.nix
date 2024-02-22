{ stdenv
, cmake
, boost
, rpclib
, recast
, fetchFromGitHub
, carla-src
, enableDebug ? false
}:

stdenv.mkDerivation rec {
  pname = "libcarla-client";
  version = carla-src.meta.version;

  src = carla-src;
  prePatch = "cd LibCarla";

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost rpclib recast ];
  patches = [
    ./carla_client.patch
    ./libcarla-Fix-compile-error-with-gcc-13.patch
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
