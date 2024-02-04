{ version
, src-hash
}:
{ lib
, autoPatchelfHook
, fetchurl
, libglvnd
, libusb1
, libxkbcommon
, llvmPackages_8
, makeWrapper
, patchelf
, pigz
, stdenv
, systemd
, vulkan-loader
, xorg
, zlib
, symlinkJoin
, unzip
}:

let
  extraLibs = [
    libglvnd
    libxkbcommon
    systemd                     # for libudev
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXxf86vm
    vulkan-loader
  ];
  # Use our own wrapper in $out/bin/ instead of the original CarlaUE4.sh in $out/
  wrapCarlaUE4 = ''
    rm -f $out/CarlaUE4.sh
    makeWrapper $out/CarlaUE4/Binaries/Linux/CarlaUE4-Linux-Shipping $out/bin/CarlaUE4.sh \
      --prefix LD_LIBRARY_PATH : '${lib.makeLibraryPath extraLibs}' \
      --add-flags CarlaUE4
  '';
  carla = stdenv.mkDerivation rec {
    pname = "carla-bin";
    inherit version;
    src = fetchurl {
      url = "https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_${version}.tar.gz";
      sha256 = src-hash;
    };

    nativeBuildInputs = [
      pigz
      patchelf
    ];
    buildInputs = [
      autoPatchelfHook
      makeWrapper
      llvmPackages_8.openmp
      libusb1
      zlib
    ];

    dontUnpack = true;
      installPhase = ''
      mkdir -p $out
      cd $out
      pigz -dc $src | tar xf -
    '';

    postFixup = ''
      for i in libChronoModels_robot.so libChronoEngine_vehicle.so libChronoEngine.so libChronoModels_vehicle.so; do
        patchelf --replace-needed libomp.so.5 libomp.so $out/CarlaUE4/Plugins/Carla/CarlaDependencies/lib/$i
      done
      ${wrapCarlaUE4}
    '';

    meta.mainProgram = "CarlaUE4.sh";

    /**
      Create CARLA installation extended with given assets.

      # Arguments

      - [assets] List of tarballs, zip files or derivations with
        assets. Using derivations has the advantage that the same
        asset can be reused in multiple versions of CARLA without
        consuming additional storage space.

      # Examples

      let
        maps = pkgs.fetchurl {
          url = "https://carla-releases.s3.us-east-005.backblazeb2.com/Windows/AdditionalMaps_0.9.15.zip";
          hash = "sha256-3w6K/5+xGBXJgPtu4Yt6SdGTCts6PGErsuaishpO6Xg=";
        };
        maps-derivation = pkgs.runCommand "carla-maps" {
          nativeBuildInputs = [ pkgs.unzip ];
        } ''mkdir $out && cd $out && unzip ${maps}'';
      in {
        carla-with-maps = carla-bin-0_9_15.withAssets [ maps ];
        carla-with-maps2 = carla-bin-0_9_15.withAssets [ maps-derivation ];
      }
    */
    passthru.withAssets = assets: symlinkJoin {
      name = "carla-with-assets";
      paths = [
        carla
      ] ++ builtins.filter (f: (builtins.readFileType f) == "directory") assets;

      nativeBuildInputs = [ makeWrapper unzip ];
      postBuild = ''
        pushd $out
        for asset in ${builtins.concatStringsSep " " assets}; do
          [[ -d $asset ]] && continue
          case $asset in
            *.tar*) tar xf $asset;;
            *.zip)  unzip -o $asset;;
            *) echo >&2 "Unknown asset type: $asset"; exit 1;;
          esac
        done
        popd

        rm $out/bin/CarlaUE4.sh $out/CarlaUE4/Binaries/Linux/CarlaUE4-Linux-Shipping
        # Carla/UE4 determines root directory for finding assets based
        # on the real path of its executable. Therefore, we have to copy
        # the main executable to let CARLA search
        # /nix/store/...carla-with-assets instead of
        # /nix/store/...carla-bin... path.
        cp {${carla},$out}/CarlaUE4/Binaries/Linux/CarlaUE4-Linux-Shipping
        ${wrapCarlaUE4}
      '';
      meta.mainProgram = "CarlaUE4.sh";
    };
  };
in
carla
