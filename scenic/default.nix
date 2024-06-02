{ lib
, python3
, fetchFromGitHub
, opencv-python
}:

python3.pkgs.buildPythonPackage rec {
  pname = "scenic";
  version = "2.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "BerkeleyLearnVerify";
    repo = "Scenic";
    rev = "v${version}";
    hash = "sha256-Y3+EM838AvtQgfN6lq/bXaqJbmosoVFW9mppOUxn9Og=";
  };

  # Scenic seems to work with shapely 2.0 (test suite passes). Use it.
  # Otherwise, we have collisions (carla uses shapely too and we
  # cannot have different version in a single Python process).
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'shapely ~= 1.7' 'shapely ~= 2.0' \
      --replace-fail 'pillow ~= 9.1' 'pillow ~= 10.3'
  '';

  nativeBuildInputs = [
    python3.pkgs.flit-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    antlr4-python3-runtime
    attrs
    decorator
    dotmap
    importlib-metadata
    mapbox-earcut
    matplotlib
    numpy
    opencv-python
    pillow
    pygame
    scipy
    shapely
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    dev = [
      astor
      inflect
      pygments
      pytest-cov
      scenic
      sphinx
      sphinx-rtd-theme
      tox
    ];
    guideways = [
      pyproj
    ];
    test = [
      pytest
      pytest-randomly
    ];
  };

  pythonImportsCheck = [ "scenic" ];

  meta = with lib; {
    description = "A compiler and scene generator for the Scenic scenario description language";
    homepage = "https://github.com/BerkeleyLearnVerify/Scenic/tree/2.x";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "scenic";
  };
}
