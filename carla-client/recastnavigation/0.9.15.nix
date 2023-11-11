{ stdenv
, cmake
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "recast";
  version = "0.pre+date=2023-02-21";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "recastnavigation";
    rev = "22dfcb46204df1a07f696ae3d9efc76f718ea531";
    sha256 = "sha256-9UCIXcWV8OJp+Gr/xOmRCTk+mBRWU5rbveGmukm+4rc=";
  };

  nativeBuildInputs = [ cmake ];
  patches = [
    ./recast.patch
    ./0001-nix-Install-path-fixes.patch
  ];

  cmakeFlags = [
    "-DRECASTNAVIGATION_DEMO=False"
    "-DRECASTNAVIGATION_TEST=False"
  ];
}
