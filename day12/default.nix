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

  pointNeighbors = pt: builtins.genList (i: if i == 0 then { x = pt.x - 1; y = pt.y; } else if i == 1 then { x = pt.x + 1; y = pt.y; } else if i == 2 then { x = pt.x; y = pt.y - 1; } else { x = pt.x; y = pt.y + 1; }) 4;

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
            neighbors = pointNeighbors pt;
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
let
  # Part2: it turns out we shoulda used Dijkstra because we want shortest path
  # to all 'a' nodes from 'E', and A* doesn't give us an easy modification to
  # that. Oof.
  # Oh well, time to do part2 with Dijkstra's instead
  dijkstra = start: endH: grid:
    let
      gridWidth = array2.width grid;
      gridHeight = array2.height grid;
      # Distances, infinity, 0 for start
      dists = let maxed = array2.generate (x: y: maxScore) (array2.width grid) (array2.height grid); in array2.set maxed start.x start.y 0;
      q = lists.sort (l: r: (array2.get dists l.x l.y) < (array2.get dists r.x r.y)) allGridCoords;
      f = state:
        if length state.q == 0 then state.best
        else
          let
            pt = head state.q;
            ptH = array2.get grid pt.x pt.y;
            ptDist = array2.get state.dists pt.x pt.y;
            best = if ptH == endH && ptDist < state.best then ptDist else state.best;
            neighbors = pointNeighbors pt;
            neighbors' = filter
              (p:
                let
                  pH = array2.get grid p.x p.y;
                in
                # inside the grid
                p.x >= 0 && p.y >= 0 && p.x < gridWidth && p.y < gridHeight &&
                # And also verify we can be reached from it, i.e. if we are c then bcdef etc are okay
                pH >= (ptH - 1) &&
                # And verify it's inside our list to explore, otherwise it's already optimal
                # Eww, O(n), but this is fast enough it completes, so I'm not
                # optimizing it. Using a heap would obviously be faster.
                (lists.elem p state.q)
              )
              neighbors;
            dists = foldl' (acc: pt: let curDist = array2.get acc pt.x pt.y; in if curDist < (ptDist + 1) then acc else array2.set acc pt.x pt.y (ptDist + 1)) state.dists neighbors';
            remainingQ = lists.sort (l: r: (array2.get dists l.x l.y) < (array2.get dists r.x r.y)) (tail state.q);
          in
          f { inherit best dists; q = remainingQ; };
    in
    f { inherit q dists; best = maxScore; };

in
{
  part1 = astar start end gridNum;
  part2 = dijkstra end 0 gridNum;
}
