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
      lib = import ./lib.nix { inherit pkgs; };
      dayDirs = pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "day" name) (builtins.readDir ./.);
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      inherit lib;
    }
    // (pkgs.lib.mapAttrs (name: _: import ./${name} { inherit pkgs lib; }) dayDirs);
}
