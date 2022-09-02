{ stdenv
, cmake
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "rpclib";
  version = "0.pre+date=2022-08-30";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "rpclib";
    rev = "v2.2.1_c5";
    sha256 = "sha256-QY1vLApeVaDRxFtM/lQU1abnCGA/rElgETcA0zOqewg=";
  };

  nativeBuildInputs = [ cmake ];
}
