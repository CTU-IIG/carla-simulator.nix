{ version, src-hash }:
{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "carla-simulator";
  repo = "carla";
  rev = version;
  sha256 = src-hash;
  meta = {
    # Make the version available to packages using this source
    inherit version;
  };
}
