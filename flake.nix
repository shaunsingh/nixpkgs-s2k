# Overlays
# Sometimes there are packages that I want from git, or that aren't available from =nixpkgs=. This overlay adds the following:
# - Yabai (mac) from https://github.com/donaldguy/yabai
# - Neovide (mac) from https://github.com/neovide/neovide
# - SFmono Nerd Font Ligaturized from https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized

# [[file:../nix-config.org::*Overlays][Overlays:1]]
{
  description = "Shaunsingh's stash of fresh packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    meson059.url = "github:boppyt/nixpkgs/meson";

    alacritty-src = {
      url = "github:zenixls2/alacritty/ligature";
      flake = false;
    };

    wlroots-src = {
      url = "github:swaywm/wlroots";
      flake = false;
    };

    sway-src = {
      url = "github:fluix-dev/sway-borders";
      flake = false;
    };

    neovide-src = {
      url = "github:neovide/neovide";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-nightly = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "nixpkgs";
      inputs.fenix.follows = "nixpkgs";
      # inputs.flake-utils.follows = "nixpkgs";
    };

  };

  outputs = args@{ self, flake-utils, nixpkgs, rust-nightly, meson059, darwin, ... }:
    {
      overlay = final: prev: {
        inherit (self.packages.${final.system})
          neovide-git sf-mono-liga-bin emacs-ng sway-borders-git
          wlroots-git eww mxfw
          # hammerspoon
          alacritty-ligatures;
      };
    } // flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-nightly.overlay ];
          allowBroken = true;
          allowUnsupportedSystem = true;
        };
        mesonPkgs = import meson059 { inherit system; };
        version = "999-unstable";
      in {
        defaultPackage = self.packages.${system}.eww;

        packages = rec {

          eww = args.eww.defaultPackage.${system};

          sf-mono-liga-bin = pkgs.callPackage ./pkgs/sf-mono-liga-bin { };
          mxfw = pkgs.callPackage ./pkgs/mxfw { };
          # hammerspoon-git = pkgs.callPackage ./pkgs/hammerspoon { };

          alacritty-ligatures = with pkgs;
            (alacritty.overrideAttrs (old: rec {
              src = args.alacritty-src;

              postInstall = ''
                install -D extra/linux/Alacritty.desktop -t $out/share/applications/
                install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg
                strip -S $out/bin/alacritty
                patchelf --set-rpath "${
                  lib.makeLibraryPath old.buildInputs
                }:${stdenv.cc.cc.lib}/lib${
                  lib.optionalString stdenv.is64bit "64"
                }" $out/bin/alacritty
                installShellCompletion --zsh extra/completions/_alacritty
                installShellCompletion --bash extra/completions/alacritty.bash
                installShellCompletion --fish extra/completions/alacritty.fish
                install -dm755 "$out/share/man/man1"
                gzip -c extra/alacritty.man > "$out/share/man/man1/alacritty.1.gz"
                install -Dm644 alacritty.yml $out/share/doc/alacritty.yml
                install -dm755 "$terminfo/share/terminfo/a/"
                tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
                mkdir -p $out/nix-support
                echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
              '';

              cargoDeps = old.cargoDeps.overrideAttrs (_: {
                inherit src;
                outputHash =
                  "sha256-tY5sle1YUlUidJcq7RgTzkPsGLnWyG/3rtPqy2GklkY=";
              });
            }));

          wlroots-git = (pkgs.wlroots.overrideAttrs (old: {
            inherit version;
            src = args.wlroots-src;

            buildInputs = (old.buildInputs or [ ])
              ++ (with pkgs; [ seatd vulkan-headers vulkan-loader glslang ]);
          })).override { inherit (mesonPkgs) meson; };

          sway-borders-git = (pkgs.sway-unwrapped.overrideAttrs (_: {
            inherit version;
            src = args.sway-src;
          })).override {
            inherit (mesonPkgs) meson;
            wlroots = wlroots-git;
          };

          neovide-git = (pkgs.neovide.overrideAttrs (old: {
            inherit version;
            src = args.neovide-src;
            buildInputs = (old.buildInputs or [ ])
              ++ (with pkgs; [ rust-bin.nightly.latest.default ]);
          }));
        };
      });
}
# Overlays:1 ends here
