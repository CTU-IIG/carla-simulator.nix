{ lib, stdenv, writeScript, fetchurl, requireFile, unzip, mono, which,
  xorg, xdg-user-dirs, zlib, udev, runCommand, autoPatchelfHook
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
  ue4-sdk-clang = fetchurl {
    url = "http://cdn.unrealengine.com/Toolchain_Linux/native-linux-${toolchainArchive}";
    sha256 = "sha256-3FvMikfcQrHyzt04ZQXpCgxU9T365EptetKebTiiOcA=";
  };
in
stdenv.mkDerivation rec {
  pname = "carla-ue4";
  version = "0.9.13";
  sourceRoot = "UnrealEngine-${version}";
  src = requireFile {
    name = "${sourceRoot}.zip";
    url = "https://github.com/CarlaUnreal/UnrealEngine/archive/refs/tags/${version}.zip";
    sha256 = "10q73ax9v44h6s5r0rjglg6x7iqjfbbcc58ssdssk4qq3lp63qp8";
  };
  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';
  postPatch = ''
    substituteInPlace Engine/Build/BatchFiles/Linux/GenerateGDBInit.sh \
        --replace '~/.config/Epic/GDBPrinters/' "$out/share/Epic/GDBPrinters/" \
        --replace '~/.gdbinit' "$out/share/Epic/GDBPrinters/.gdbinit"
  '';

  nativeBuildInputs = [ autoPatchelfHook ];

  configurePhase = ''
    mkdir -p .git
    ln -s ${linkedDeps}/.git/ue4-gitdeps  .git/ue4-gitdeps
    mkdir -p .git/ue4-sdks
    ln -s ${ue4-sdk-clang} .git/ue4-sdks/${toolchainArchive}

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
    export MONO_REGISTRY_PATH=$out/etc/mono/registry/LocalMachine
    mkdir -p "$MONO_REGISTRY_PATH"

    ./Setup.sh

    # Patch binaries in the clang toolchain from ue4-sdk-clang. We link to
    # Nix-provided libraries instead of the libraries from the toolchain,
    # because the toolchains libraries cause clang to segfault. This means
    # that autoPatchelf should not look into .../x86_64-unknown-linux-gnu/lib.
    autoPatchelf Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64/${toolchainVersion}/x86_64-unknown-linux-gnu/bin/

    # Remove the file that makes patchelf fail (assertion)
    rm Engine/Binaries/Linux/UnrealVersionSelector-Linux-Shipping.debug

    addAutoPatchelfSearchPath Engine/Binaries/ThirdParty/CEF3/Linux
    autoPatchelf Engine/Binaries/Linux

    ./GenerateProjectFiles.sh

    # Patch newly generated binaries
    autoPatchelf Engine/Binaries/Linux
  '';

  # Do not use Mono bundled with UE
  UE_USE_SYSTEM_MONO = 1;

  installPhase = ''
    mkdir -p $out/bin $out/share/UnrealEngine

    sharedir="$out/share/UnrealEngine"

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
    export LD_LIBRARY_PATH="${libPath}\''${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH"
    exec ./UE4Editor "\$@"
    EOF
    chmod +x $out/bin/UE4Editor

    cp -r . "$sharedir"
  '';

  buildInputs = [ mono which xdg-user-dirs zlib udev ];

  meta = {
    description = "A suite of integrated tools for game developers to design and build games, simulations, and visualizations";
    homepage = "https://www.unrealengine.com/what-is-unreal-engine-4";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
