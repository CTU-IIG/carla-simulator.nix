let
  hashes = {
    "0.9.12" = "sha256-DdZQ3TWVg1UcGlp/YN9jThIDltUwa4LGIrLKYase+tQ=";
    "0.9.13" = "sha256-0PzQ8XPDJ45lZFZtZaxwAKZ755ih9Zvqh1ozMMvTXXo=";
    "0.9.14" = "sha256-7c6gi7lxnuQm4CBybJAXeUxKQRcQ6SIJUCz3Rlc6sP4=";
    "0.9.15" = "sha256-yIU6Q9TDZg8/9UWJAo2FsZ7362WGQMk479eLkM/WD/U=";
  };
in
(builtins.mapAttrs (version: src-hash:
  import ./common.nix {
    inherit version src-hash;
  }
) hashes)
// {
  # TODO: Update the path below to where you have CARLA sources
  "local" = { runCommandLocal }: runCommandLocal "source" { meta.version = "0.9.15-local"; } ''
    cp -a ${/home/wsh/src/carla/carla} $out
  '';
}
