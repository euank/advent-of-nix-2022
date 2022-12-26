{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    setlist = n: val: arr: (sublist 0 n arr) ++ [ val ] ++ (sublist (n + 1) (length arr) arr);
    trimSpace = str: strings.removePrefix " " (strings.removeSuffix " " str);
  };
in
lib
