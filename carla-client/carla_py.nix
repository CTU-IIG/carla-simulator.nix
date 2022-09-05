{ buildPythonPackage
, fetchFromGitHub
, libpng
, libjpeg
, libtiff
, proj
, sqlite
, xercesc
, boost
, numpy
, networkx
, distro
, setuptools
, carla-client
, rpclib
, recast
, osm2odr
}:

buildPythonPackage rec {
  pname = "carla-py";
  version = "0.9.12";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "carla";
    rev = version;
    sha256 = "sha256-DdZQ3TWVg1UcGlp/YN9jThIDltUwa4LGIrLKYase+tQ=";
  };

  buildInputs = [ distro carla-client boost rpclib recast osm2odr libpng.dev libjpeg.dev libtiff.dev proj.dev sqlite.dev xercesc networkx ];
  propagatedBuildInputs = [ numpy ];
  sourceRoot = "source/PythonAPI/carla";
  patches = [ ./carla_py.patch ];
}
