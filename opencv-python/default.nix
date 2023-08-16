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
in
python3Packages.buildPythonPackage rec {
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
}
