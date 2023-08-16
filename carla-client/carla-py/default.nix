{ python3Packages
, python3
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
, carla-src
}:

python3Packages.buildPythonPackage rec {
  pname = "carla-py";
  version = carla-src.meta.version;

  src = carla-src;

  separateDebugInfo = true;

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

  postInstall = ''
    cp -r $src/PythonAPI/carla/agents $out/${python3.sitePackages}
  '';

  sourceRoot = "source/PythonAPI/carla";
  patches = [
    ./0001-Allow-compiling-with-Nix.patch
    ./0002-Don-t-fail-when-compiling-with-gcc-12.patch
  ];
}
