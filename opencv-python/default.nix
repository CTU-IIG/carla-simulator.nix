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
      hash = "sha256-WG/GudVpkO10kOJhoKXFMj672kggvyRYCIpezal3wcE=";
    };
    name = "v0.1.2d.zip";
    md5 = "dbb095a8bf3008e91edbbf45d8d34885";
    dst = ".cache/ade";
  };
in
python3Packages.buildPythonPackage rec {
  pname = "opencv-python";
  version = "4.9.0.80";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Gp8OYmfeOhodsMVCE9Aix8i1ucpLWA6AvcWFFskiyeE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'setuptools==59.2.0' 'setuptools' \
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
