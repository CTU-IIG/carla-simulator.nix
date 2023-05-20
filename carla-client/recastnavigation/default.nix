{ stdenv
, cmake
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "recast";
  version = "0.pre+date=2022-08-30";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "recastnavigation";
    rev = "0b13b0d288ac96fdc5347ee38299511c6e9400db";
    sha256 = "sha256-AoN7GF6i0+AvwtxyUlda8mzleDGXbemimJAkLdxArWQ=";
  };

  nativeBuildInputs = [ cmake ];
  patches = [ ./recast.patch ];

  cmakeFlags = [
    "-DRECASTNAVIGATION_DEMO=False"
    "-DRECASTNAVIGATION_TEST=False"
  ];
  postInstall = ''
    mkdir -p $out/include/recast
    mv $out/include/*.h $out/include/recast/
  '';
}
