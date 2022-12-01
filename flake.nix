{
  description = "Advent of Nix 2022";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
    dayDirs = pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "day" name) (builtins.readDir ./.);
    lib = import ./lib.nix { inherit pkgs; };
  in
 (pkgs.lib.mapAttrs (name: _: import ./${name} { inherit pkgs lib; }) dayDirs);
}
