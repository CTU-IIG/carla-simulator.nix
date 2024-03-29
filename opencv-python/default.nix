{ python3Packages
, fetchPypi
, fetchurl
, cmake
, ninja
, ffmpeg
, openblas
, libpng
, zlib
, lib
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
  version = "4.8.1.78";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zHrbvNERKHejknQQbLJ1LgSYS8AaAxFilS6XRQ1hF/Y=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'setuptools==59.2.0' 'setuptools' \
      --replace 'numpy==1.21.2' 'numpy' \
      --replace 'numpy==1.22.2' 'numpy'
  '';

  preConfigure = ''
      # See cmake/OpenCVDownload.cmake in OpenCV sources
      export OPENCV_DOWNLOAD_PATH=$PWD/.cache
      ${opencvInstallExtraFile ade}
    '';

  nativeBuildInputs = [
    cmake
    ninja
    python3Packages.scikit-build
    python3Packages.pip
    python3Packages.setuptools
  ] ++ (lib.optional (python3Packages ? cmake) python3Packages.cmake);

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
