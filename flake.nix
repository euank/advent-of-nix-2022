{
  description = "Advent of Nix 2022";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      lib = pkgs.lib;
      dayDirs = lib.filterAttrs (name: _: lib.hasPrefix "day" name) (builtins.readDir ./.);
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    }
    // (pkgs.lib.mapAttrs (name: _: import ./${name} { inherit pkgs lib; }) dayDirs);
}
