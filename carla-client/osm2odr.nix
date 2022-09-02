{ stdenv
, cmake
, xercesc
, zlib
, proj
, xorg
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "osm2odr";
  version = "0.pre+date=2022-08-30";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "sumo";
    rev = "ee0c2b9241fef5365a6bc044ac82e6580b8ce936";
    sha256 = "sha256-5vQ5VbGGOPbVLniEUAk4ZbY5xpGg42OOC/IeLKTrVUc=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ xercesc zlib.dev proj.dev xorg.libX11.dev ];
}
