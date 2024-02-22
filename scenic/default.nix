{ python3Packages
, fetchPypi
, opencv-python
}:
python3Packages.buildPythonPackage rec {
  pname = "scenic";
  version = "2.1.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vtJHqgHU8f9/6Sp6cXHwDJ2kY5Ro3e8sTd7oiik48uY=";
  };

  # Scenic seems to work with shapely 2.0 (test suite passes). Use it.
  # Otherwise, we have collisions (carla uses shapely too and we
  # cannot have different version in a single Python process).
  postPatch = ''
    substituteInPlace pyproject.toml --replace 'shapely ~= 1.7' 'shapely ~= 2.0'
  '' ++
  # Nixpkgs recently added pythonRuntimeDepsCheckHook, which complains
  # about pillow 10.* incompatibility. I'm not sure whether the
  # following workaround is sufficient. Somebody has to test it.
  ''
    substituteInPlace pyproject.toml --replace 'pillow ~= 9.1' 'pillow >= 9.1, <11'
  '';

  propagatedBuildInputs = with python3Packages; [
    attrs
    flit-core
    scipy
    mapbox-earcut
    matplotlib
    antlr4-python3-runtime
    pygame
    opencv-python
    shapely
    decorator
    dotmap
  ];

  doCheck = false; # finds zero tests. why?

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    python3Packages.tox
    python3Packages.pytest
    python3Packages.pytest-randomly
  ];

  pythonImportsCheck = [
    "scenic"
  ];
}
