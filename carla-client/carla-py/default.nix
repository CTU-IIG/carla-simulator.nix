{ python3Packages
, python3
, libpng
, libjpeg
, libtiff
, proj
, sqlite
, xercesc
, libcarla-client
, osm2odr
, carla-src
, lib
, enableDebug ? false
}:

python3Packages.buildPythonPackage rec {
  pname = "carla-py";
  version = carla-src.meta.version;

  src = carla-src;
  sourceRoot = "source/PythonAPI/carla";
#   src = /home/wsh/src/carla/carla;
#   sourceRoot = "carla/PythonAPI/carla";

  separateDebugInfo = !enableDebug;
  # sepaseparateDebugInfo is not sufficient to get debug info in
  # backtraces. Not sure why.
  dontStrip = enableDebug;

  buildInputs = [
    (libcarla-client.override { inherit enableDebug; })
    libjpeg.dev
    libpng.dev
    libtiff.dev
    osm2odr
    proj.dev
    python3Packages.boost
    python3Packages.distro
    python3Packages.networkx
    python3Packages.shapely
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

  patches = if lib.versionOlder version "0.9.15" then [
    ./0001-Allow-compiling-with-Nix.patch
    ./0002-Don-t-fail-when-compiling-with-gcc-13.patch
    ./0003-PythonAPI-Fix-segfault-in-GetAvailableMaps.patch
    ./0004-PythonAPI-Fix-segfault-in-world.get_random_location_.patch
  ] else [
    ./0001-Allow-compiling-with-Nix-0.9.15.patch
    ./0002-Don-t-fail-when-compiling-with-gcc-13.patch
  ];

  passthru = {
    inherit src; # for ./scripts.nix
  };
}
