{ lib, stdenv, writeScript, fetchurl, requireFile, unzip, mono, which,
  xorg, xdg-user-dirs, zlib, udev, runCommand, buildFHSUserEnv, autoPatchelfHook,
  lzma,

  alsa-lib, atk, bzip2, cairo, dbus, expat, fontconfig, freetype,
  gnome2, gdbm, libglvnd, glib, ncurses5, nspr, nss_latest, readline,
  sqlite, tcl-8_5, tk-8_5, libuuid
}:

let
  deps = import ./cdn-deps.nix { inherit fetchurl; };
  linkDeps = writeScript "link-deps.sh" (lib.concatMapStringsSep "\n" (hash:
    let prefix = lib.concatStrings (lib.take 2 (lib.stringToCharacters hash));
    in ''
      mkdir -p .git/ue4-gitdeps/${prefix}
      ln -s ${lib.getAttr hash deps} .git/ue4-gitdeps/${prefix}/${hash}
    ''
  ) (lib.attrNames deps));
  linkedDeps = runCommand "linked-deps" {} ''
    mkdir -p $out
    cd $out
    ${linkDeps}
  '';
  libPath = lib.makeLibraryPath [
    xorg.libX11 xorg.libXScrnSaver xorg.libXau xorg.libXcursor xorg.libXext
    xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXxf86vm
    xorg.libxcb
  ];

  # Values from Engine/Build/BatchFiles/Linux/SetupToolchain.sh
  toolchainVersion = "v17_clang-10.0.1-centos7";
  toolchainArchive = "${toolchainVersion}.tar.gz";
  ue4SdkClang = fetchurl {
    url = "http://cdn.unrealengine.com/Toolchain_Linux/native-linux-${toolchainArchive}";
    sha256 = "sha256-3FvMikfcQrHyzt04ZQXpCgxU9T365EptetKebTiiOcA=";
  };

  carlaUe4 = stdenv.mkDerivation rec {
    pname = "ue4-carla";
    version = "0.9.13";
    sourceRoot = "UnrealEngine-${version}";
    src = requireFile {
      name = "${sourceRoot}.zip";
      url = "https://github.com/CarlaUnreal/UnrealEngine/archive/refs/tags/${version}.zip";
      sha256 = "10q73ax9v44h6s5r0rjglg6x7iqjfbbcc58ssdssk4qq3lp63qp8";
    };

    # Unpack and build in $out for generated files to contain the correct path
    unpackPhase = ''
      mkdir -p $out/share
      cd $out/share
      ${unzip}/bin/unzip $src
    '';
    postPatch = ''
      substituteInPlace Engine/Build/BatchFiles/Linux/GenerateGDBInit.sh \
          --replace '~/.config/Epic/GDBPrinters/' "$out/share/Epic/GDBPrinters/" \
          --replace '~/.gdbinit' "$out/share/Epic/GDBPrinters/.gdbinit"
    '';

    nativeBuildInputs = [ ];

    # Do not use Mono bundled with UE
    UE_USE_SYSTEM_MONO = 1;

    configurePhase = ''
      mkdir -p .git
      ln -s ${linkedDeps}/.git/ue4-gitdeps  .git/ue4-gitdeps
      mkdir -p .git/ue4-sdks
      ln -s ${ue4SdkClang} .git/ue4-sdks/${toolchainArchive}

      # Sometimes mono segfaults and things start downloading instead of being
      # deterministic. Let's just fail in that case.
      export http_proxy="nodownloads"

      patchShebangs Setup.sh
      patchShebangs Engine/Build/BatchFiles/Linux

      # UnrealBuildTool wants to create
      # "~/.config/Unreal Engine/UnrealBuildTool/BuildConfiguration.xml".
      # Override the location.
      export XDG_CONFIG_HOME=$(mktemp -d)

      # Override write attempts to /etc/mono/registry/LocalMachine
      export MONO_REGISTRY_PATH=$(mktemp -d)

      ./Setup.sh
      ./GenerateProjectFiles.sh
    '';

    installPhase = ''
      rm -rf .git  # Attempt to not have the linked deps in the resulting closure
    '';

    buildInputs = [ mono which xdg-user-dirs zlib udev ];

    meta = {
      description = "A suite of integrated tools for game developers to design and build games, simulations, and visualizations";
      homepage = "https://www.unrealengine.com/what-is-unreal-engine-4";
      license = lib.licenses.unfree;
      platforms = lib.platforms.linux;
      maintainers = [ ];
    };
  };
  # https://github.com/NixOS/nixpkgs/compare/master...ElvishJerricco:nixpkgs:run-in-fhs
  # Similar to runInLinuxVM, except we run under a FHS user env instead
  # of a VM. This allows you to use build systems that depend on the FHS
  # without any sort of patching. Resulting binaries may not work on
  # NixOS without wrapping them in FHS though.
  runInFHSUserEnv = drv: envArgs: let
    fhsWrapper = buildFHSUserEnv ({
      name = "${drv.name}-fhs-wrapper";
      runScript = "$@";
    } // envArgs);
  in lib.overrideDerivation drv (old: {
    builder = "${fhsWrapper}/bin/${fhsWrapper.name}";
    args = [old.builder] ++ old.args;
  });
  carlaUe4InFHS = runInFHSUserEnv carlaUe4 {};
in
stdenv.mkDerivation rec {
  name = "${carlaUe4InFHS.name}-wrapper";
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  autoPatchelfIgnoreMissingDeps = [
    "libGLESv2.so"
    "libOpenSLES.so"
    "libandroid.so"
    "liblog.so"
    "libc++_shared.so"
    "libcrypto.so.10"
    "libffi.so.6"
    "libgdbm.so.4"
    "libgnustl_shared.so"
    "libjnigraphics.so"
    "libssl.so.10"
    "usdSchemaExamples.so"
  ];

  buildInputs = [ zlib lzma alsa-lib atk bzip2 cairo dbus expat
    fontconfig freetype gnome2.GConf gdbm libglvnd glib ncurses5 nspr
    nss_latest gnome2.pango readline sqlite tcl-8_5 tk-8_5 libuuid

    xorg.libX11 xorg.libXScrnSaver xorg.libXau xorg.libXcursor xorg.libXext
    xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXxf86vm
    xorg.libxcb xorg.libXcomposite xorg.libXdamage xorg.libXtst
  ];

  installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share
      #ln -s "${carlaUe4InFHS}/share/UnrealEngine-${carlaUe4InFHS.version}" $out/share
      cp -a "${carlaUe4InFHS}/share/UnrealEngine-${carlaUe4InFHS.version}" $out/share

      # Remove files which break patchelf
      chmod +w $out/share/UnrealEngine-${carlaUe4InFHS.version}/Engine/Binaries/Linux
      rm $out/share/UnrealEngine-${carlaUe4InFHS.version}/Engine/Binaries/Linux/*.debug

      sharedir="$out/share/UnrealEngine-${carlaUe4InFHS.version}"

      cat << EOF > $out/bin/UE4Editor
      #! $SHELL -e

      sharedir="$sharedir"

      # Can't include spaces, so can't piggy-back off the other Unreal directory.
      workdir="\$HOME/.config/unreal-engine-nix-workdir"
      if [ ! -e "\$workdir" ]; then
        mkdir -p "\$workdir"
        ${xorg.lndir}/bin/lndir "\$sharedir" "\$workdir"
        unlink "\$workdir/Engine/Binaries/Linux/UE4Editor"
        cp "\$sharedir/Engine/Binaries/Linux/UE4Editor" "\$workdir/Engine/Binaries/Linux/UE4Editor"
      fi

      cd "\$workdir/Engine/Binaries/Linux"
      export PATH="${xdg-user-dirs}/bin\''${PATH:+:}\$PATH"
      export LD_LIBRARY_PATH="${libPath}:\$sharedir/Engine/Binaries/Linux:\$sharedir/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu\''${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH"
      exec ./UE4Editor "\$@"
      EOF
      chmod +x $out/bin/UE4Editor
  '';
}
