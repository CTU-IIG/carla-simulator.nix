{ python3Packages
, python3
, fetchFromGitHub
, fetchPypi
, opencv-python
, carla-py
}:
let
  py-trees = python3Packages.buildPythonPackage rec {
    pname = "py_trees";
    version = "0.8.3";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Z54MItiFR1kYCpxPQ/jEyHR51TFCBolKIw91hpyCLJE=";
    };

    propagatedBuildInputs = with python3Packages; [
      pydot
    ];

    doCheck = false; # nose-htmloutput is not in nixpkgs
  };
  simple-watchdog-timer = python3Packages.buildPythonPackage rec {
    pname = "simple_watchdog_timer";
    version = "0.1.1";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-XVs+Nmz8wdghRqT4I35JRjpZzIzKxVQu3BsmzXYDEPI=";
    };
  };
in
python3Packages.buildPythonPackage rec {
  pname = "scenario-runner";
  version = "0.9.13";
  format = "other";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "scenario_runner";
    rev = "v${version}";
    hash = "sha256-48cN/l5cQOLwEN9lueZDgGJvhn0aVsZeBfxWXJ0x3S0=";
  };

  buildInputs = [
    python3
  ];

  propagatedBuildInputs = (with python3Packages; [
    # From requirements.txt
    py-trees #==0.8.3
    networkx #==2.2
    shapely# ==1.7.1
    psutil
    xmlschema #==1.0.18
    ephem
    tabulate
    opencv-python #==4.2.0.32
    numpy
    matplotlib
    six
    simple-watchdog-timer

    # for manual_control.py
    pygame
  ]) ++ [
    # Other
    carla-py
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/${python3.sitePackages}
    cp -r $src/srunner $out/${python3.sitePackages}

    mkdir -p $out/bin
    cp $src/scenario_runner.py $out/bin
    cp $src/metrics_manager.py $out/bin/scenario_runner_metrics_manager.py
    chmod +x $out/bin/scenario_runner_metrics_manager.py
    cp $src/no_rendering_mode.py $out/bin/scenario_runner_no_rendering_mode.py
    cp $src/manual_control.py $out/bin/scenario_runner_manual_control.py
  '';

  makeWrapperArgs = [
    "--prefix PYTHONPATH : ''$out/${python3.sitePackages}"
    "--set-default SCENARIO_RUNNER_ROOT $out/${python3.sitePackages}"
  ] ++ (let
    # This must be defined here due to nix escaping rules
    carla-host-arg = ''''${CARLA_HOST:+--host $CARLA_HOST}'';
    carla-port-arg = ''''${CARLA_PORT:+--port $CARLA_PORT}'';
  in [
    "--add-flags '${carla-host-arg}'"
    "--add-flags '${carla-port-arg}'"
  ]);
}
