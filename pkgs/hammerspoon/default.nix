# [[file:../../../nix-config.org::*Overlays][Overlays:2]]
{ lib, fetchFromGitHub }:
let version = "unstable";
in fetchFromGitHub rec {
  name = "hammerspoon-${version}";

  owner = "Hammerspoon";
  repo = "hammerspoon";
  rev = "b253735febedb5e0f61f136c2c82f78879986a96";
  sha256 = "sha256-hH5pLXD1NWqpKuQSqfDn50u2NPJmLlqOqllo2j3x2ag=";

  postFetch = ''
    mkdir -p $out/Applications/Hammerspoon.app
    cp -r $src/Contents $out/Applications/Hammerspoon.app/
    ln -sf $out/Applications/Hammerspoon.app/ /Applications/  '';

  meta = with lib; {
    description = "Hammerspoon";
    homepage = "https://github.com/Hammerspoon/hammerspoon/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ shaunsingh ];
  };

}
# Overlays:2 ends here
