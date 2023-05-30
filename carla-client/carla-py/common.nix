{ version, src-hash }:

{ python3Packages
, fetchFromGitHub
, libpng
, libjpeg
, libtiff
, proj
, sqlite
, xercesc
, carla-client
, rpclib
, recast
, osm2odr
}:

python3Packages.buildPythonPackage rec {
  pname = "carla-py";
  inherit version;

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "carla";
    rev = version;
    sha256 = src-hash;
  };

  buildInputs = [
    carla-client
    libjpeg.dev
    libpng.dev
    libtiff.dev
    osm2odr
    proj.dev
    python3Packages.boost
    python3Packages.distro
    python3Packages.networkx
    python3Packages.shapely
    recast
    rpclib
    sqlite.dev
    xercesc
  ];

  propagatedBuildInputs = [
    python3Packages.numpy
    python3Packages.shapely
  ];
  sourceRoot = "source/PythonAPI/carla";
  patches = [
    ./0001-Allow-compiling-with-Nix.patch
    ./0002-Don-t-fail-when-compiling-with-gcc-12.patch
  ];
}
