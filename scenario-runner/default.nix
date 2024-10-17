{ python3Packages
, python3
, fetchFromGitHub
, fetchPypi
, opencv-python
, carla-py
, fetchpatch
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
  version = "0.9.15+dev";
  format = "other";

  src = fetchFromGitHub {
    owner = "carla-simulator";
    repo = "scenario_runner";
    rev = "7758d066080f180f8296887ed89b7c723a54706a"; #"v${version}";
    hash = "sha256-lRcq0bI/ZDRugiThH3nSYNvx5Aep76BwPo719LLVPlQ=";
  };

  patches = [
    (fetchpatch {
      # Don't depend on distutils
      url = "https://github.com/carla-simulator/scenario_runner/commit/272eda32a4d6db164b4f74cd9a11e232b35933ad.patch";
      hash = "sha256-muaPRhpN8YHQEY8bujwKt7MHZ5Ag3Kkl2qf7LedqIsM=";
    })
    (fetchpatch {
      # osc2_scenario: Fix SyntaxWarnings
      url = "https://github.com/carla-simulator/scenario_runner/commit/cd1a563e6d4b1ba087c3ca7093c1b231ae294565.patch";
      excludes = [ "Docs/CHANGELOG.md" ];
      hash = "sha256-0blb34LFP3ctxinniwSwC6TB+swgZ/A8MdemrN5SE44=";
    })
  ];

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
    graphviz
    antlr4-python3-runtime

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
