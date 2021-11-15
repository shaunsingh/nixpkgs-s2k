# nixpkgs-s2k

Based off of https://github.com/fortuneteller2k/nixpkgs-f2k

Provides the following: 
- yabai-m1 (mac only) for https://github.com/donaldguy/yabai/canon
- neovide-git for https://github.com/neovide/neovide
- sf-mono-liga-bin for https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized
- emacs-ng from https://github.com/emacs-ng/emacs-ng
- sway-borders-git for https://github.com/fluix-dev/sway-borders
- wlroots-git for https://github.com/swaywm/wlroots
- alacritty-ligatures for https://github.com/zenixls2/alacritty/ligature

# Usage

**NOTE: these instructions aren't 100% what you should do, use accordingly to your configuration**

## Flake enabled Nix:

```nix
{
  inputs.nixpkgs-s2k.url = "github:shaunsingh/nixpkgs-s2k";

  outputs = { self, nixpkgs-s2k, ... }@inputs: {
    nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = [ nixpkgs-s2k.overlay ]; }
        ./configuration.nix
      ];
    };
  }
}
```

## Non-flake enabled Nix, append to `configuration.nix`, or `home.nix`:
```nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/shaunsingh/nixpkgs-s2k/archive/master.tar.gz;
    }))
  ];
}
```
