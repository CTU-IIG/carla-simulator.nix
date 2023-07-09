{ python3Packages
, fetchPypi
, fetchurl
, cmake
, ninja
, ffmpeg
, openblas
, libpng
, zlib
}:
let
  opencvInstallExtraFile = extra: ''
    mkdir -p "${extra.dst}"
    ln -s "${extra.src}" "${extra.dst}/${extra.md5}-${extra.name}"
  '';
  # See opencv/modules/gapi/cmake/DownloadADE.cmake
  ade = rec {
    src = fetchurl {
      url = "https://github.com/opencv/ade/archive/${name}";
      sha256 = "sha256-TjLRbFbC7MDY9PxIy560ryviBI58cbQwqgc7A7uOHkg=";
    };
    name = "v0.1.2a.zip";
    md5 = "fa4b3e25167319cb0fa9432ef8281945";
    dst = ".cache/ade";
  };

  opencv-python = python3Packages.buildPythonPackage rec {
    pname = "opencv-python";
    version = "4.8.0.74";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-AJ4841agzS10I3I+AKMv09PMW7WXDtJ6mh+KjyIdHbU=";
    };

    preConfigure = ''
      # See cmake/OpenCVDownload.cmake in OpenCV sources
      export OPENCV_DOWNLOAD_PATH=$PWD/.cache
      ${opencvInstallExtraFile ade}
    '';

    nativeBuildInputs = [
      cmake
      ninja
      python3Packages.scikit-build
    ];

    buildInputs = [
      ffmpeg
      openblas
      libpng
      zlib
    ];

    dontUseCmakeConfigure = true;

    propagatedBuildInputs = with python3Packages; [
      numpy
    ];
  };
in
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
