{ lib, fetchFromGitHub, meson}:
let version = "unstable";
in fetchFromGitHub rec {
  name = "mxfw-${version}";

  owner = "Sweets";
  repo = "mx";
  rev = "9e0dfdb5b9b6ad3153fd92924bf43e3e2352fa9f";
  sha256 = "sha256-hH5pLXD1NWqpKuQSqfDn50u2NPJmLlqOqllo2j3x2ag=";

  nativeBuildInputs = [ lua meson ];

  meta = with lib; {
    description = "framework window manager for macOS";
    homepage = "https://github.com/Sweets/mx";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ boppyt ];
  };
}
