{ stdenv
, cmake
, boost
, rpclib
, recast
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "carla_client";
  version = "0.9.12";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "carla";
    rev = version;
    sha256 = "sha256-DdZQ3TWVg1UcGlp/YN9jThIDltUwa4LGIrLKYase+tQ=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost rpclib recast ];
  sourceRoot = "source/LibCarla";
  patches = [ ./carla_client.patch ];
  cmakeFlags = [
    "../cmake"
    "-DCMAKE_BUILD_TYPE=Client"
    "-DLIBCARLA_BUILD_DEBUG=OFF"
    "-DLIBCARLA_BUILD_RELEASE=ON"
    "-DCARLA_VERSION=${version}"
    "-DLIBCARLA_BUILD_TEST=OFF"
  ];
  installPhase = ''
    mkdir -p $out/lib
    cp client/libcarla_client.a $out/lib
    mkdir -p $out/include/carla
    pushd ../source/carla
    cp *.h $out/include/carla
    cp --parents */*.h $out/include/carla
    cp --parents */*/*.h $out/include/carla
    popd
  '';
}
