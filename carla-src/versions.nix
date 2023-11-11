{
  "0.9.12" = import ./common.nix {
    version = "0.9.12";
    src-hash = "sha256-DdZQ3TWVg1UcGlp/YN9jThIDltUwa4LGIrLKYase+tQ=";
  };
  "0.9.13" = import ./common.nix {
    version = "0.9.13";
    src-hash = "sha256-0PzQ8XPDJ45lZFZtZaxwAKZ755ih9Zvqh1ozMMvTXXo=";
  };
  "0.9.14" = import ./common.nix {
    version = "0.9.14";
    src-hash = "sha256-7c6gi7lxnuQm4CBybJAXeUxKQRcQ6SIJUCz3Rlc6sP4=";
  };
  "0.9.15" = import ./common.nix {
    version = "0.9.15";
    src-hash = "sha256-yIU6Q9TDZg8/9UWJAo2FsZ7362WGQMk479eLkM/WD/U=";
  };

  # TODO: Update the path below to where you have CARLA sources
  "local" = { runCommandLocal }: runCommandLocal "carla-src-local" { meta.version = "local"; } ''
    cp -a ${/home/wsh/src/carla/carla} $out
  '';
}
