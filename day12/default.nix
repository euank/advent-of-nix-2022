{ lib, pkgs }:
with lib; with pkgs.lib;
let
  input = fileContents ./input;
  gridChars = map (l: remove "" (strings.splitString "" l)) (strings.splitString "\n" input);
  allGridCoords = lists.flatten (builtins.genList (x: builtins.genList (y: { inherit x y; }) (array2.height gridChars)) (array2.width gridChars));
  start = lists.findSingle (el: (array2.get gridChars el.x el.y) == "S") null null allGridCoords;
  end = lists.findSingle (el: (array2.get gridChars el.x el.y) == "E") null null allGridCoords;
  gridNum' = map (map (c: (strings.charToInt c) - (strings.charToInt "a"))) gridChars;
  gridNum = array2.set (array2.set gridNum' end.x end.y 25) start.x start.y 0;
  maxScore = (array2.width gridNum) * (array2.height gridNum);

  fVal = p: end:
    # Cheapest possible distance is steps x + steps y
    let
      dx = abs (end.x - p.x);
      dy = abs (end.y - p.y);
    in
    dx + dy;

  # time for an A*
  astar = start: end: grid:
    let
      gridWidth = array2.width grid;
      gridHeight = array2.height grid;
      openSet = [ start ];
      gScores = let maxed = array2.generate (x: y: maxScore) (array2.width grid) (array2.height grid); in array2.set maxed start.x start.y 0;

      astar' = state:
        if length state.open == 0 then builtins.throw "none left in open"
        else
          let
            pt = head state.open;
            ptScore = array2.get state.g pt.x pt.y;
            ptH = array2.get grid pt.x pt.y;
            neighbors = builtins.genList (i: if i == 0 then { x = pt.x - 1; y = pt.y; } else if i == 1 then { x = pt.x + 1; y = pt.y; } else if i == 2 then { x = pt.x; y = pt.y - 1; } else { x = pt.x; y = pt.y + 1; }) 4;
          in
          if pt == end then ptScore
          else
          # Otherwise, expand
            let
              neighbors' = filter
                (p:
                  let
                    oldG = array2.get state.g p.x p.y;
                    pH = array2.get grid p.x p.y;
                  in
                  # outside the grid
                  p.x >= 0 && p.y >= 0 && p.x < gridWidth && p.y < gridHeight &&
                  # And also verify it's at most 1 taller than us
                  pH <= (ptH + 1) &&
                  # And verify that this would be an improvement
                  (ptScore + 1) < oldG
                )
                neighbors;
              # Update g
              state' = foldl'
                (state: p: {
                  open = state.open;
                  g = array2.set state.g p.x p.y (ptScore + 1);
                  f = array2.set state.f p.x p.y (ptScore + 1 + (fVal p end));
                })
                state
                neighbors';
              open' = (tail state.open) ++ neighbors';
              openSorted = lists.sort (l: r: (array2.get state'.f l.x l.y) < (array2.get state'.f r.x r.y)) open';
              openSortedDeduped = lib.lists.dedupeSorted openSorted;
            in
            astar' { open = openSortedDeduped; g = state'.g; f = state'.f; steps = state.steps + 1; };
    in
    astar' { open = openSet; g = gScores; f = gScores; steps = 0; };
in
{
  part1 = astar start end gridNum;
}
