{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    setlist = n: val: arr: (sublist 0 n arr) ++ [ val ] ++ (sublist (n + 1) (length arr) arr);
    trimSpace = str: strings.removePrefix " " (strings.removeSuffix " " str);

    abs = x: if x < 0 then (-1) * x else x;

    array2 = {
      # set returns a new array with the same elements as 'arr', except for 'x,y' being set to 'val'.
      # The array is interpreted such a 2x4 array would have x,y values refer to the following elements:
      # [ [ "0,0" "1,0" ]
      #   [ "0,1" "1,1" ]
      #   [ "0,2" "1,2" ]
      #   [ "0,3" "1,3" ] ]
      set = arr: x: y: val:
        let
          toY = sublist 0 y arr;
          elY = elemAt arr y;
          afterY = sublist (y + 1) ((length arr) - (y + 1)) arr;
          toX = sublist 0 x elY;
          afterX = sublist (x  + 1) ((length elY) - (x + 1)) elY;
        in
          toY ++ [ (toX ++ [ val ] ++ afterX) ] ++ afterY;

      get = arr: x: y: elemAt (elemAt arr y) x;
      getDefault = arr: x: y: def:
        if x < 0 || y < 0 then def
        else if y >= (length arr) then def
        else if x >= (length (elemAt arr y)) then def
        else elemAt (elemAt arr y) x;

      width = arr: length (head arr);
      height = arr: length arr;

      generate = f: w: h: builtins.genList (y: builtins.genList (x: f x y) w) h;
    };

    lists = rec {
      dedupeSorted = arr:
        if length arr <= 1 then arr else
        let
          h = head arr;
          t = tail arr;
        in
        if h == (head t) then dedupeSorted ([h] ++ (tail t))
        else [h] ++ (dedupeSorted t);

      # flatten, but only 1 layer deep
      flatten1 = ll: foldl' (out: el: out ++ el) [] ll;
    };

    heap = import ./heap.nix { inherit pkgs lib; };
  };
in
lib
