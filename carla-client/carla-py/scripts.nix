# This package makes CARLA Python scripts available in the PATH.
{ python3
, carla-py
, stdenv
, makeWrapper
}:
stdenv.mkDerivation {
  pname = "carla-py-scripts";
  version = carla-py.version;

  src = carla-py.src;
  sourceRoot = "source/PythonAPI";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    (python3.withPackages (p: [
      carla-py
      p.pygame
      p.imageio
      p.py-cpuinfo
    ]))
  ];

  installPhase = let
    # This must be define here due to nix escaping rules
    carla-host-arg = ''''${CARLA_HOST:+--host $CARLA_HOST}'';
    carla-port-arg = ''''${CARLA_PORT:+--port $CARLA_PORT}'';
  in ''
    runHook preInstall

    mkdir -p $out/bin

    wrapScriptsAs() {
      for i in *.py; do
        local script
        script=$out/bin/carla-"$1"-"$i"
        cp "$i" "$script"
        chmod +x "$script"
        wrapProgram "$script" \
          --add-flags '${carla-host-arg}' \
          --add-flags '${carla-port-arg}'
      done
    }

    pushd util
    wrapScriptsAs util
    popd

    pushd examples
    wrapScriptsAs example
    popd

    runHook postInstall
  '';

}
