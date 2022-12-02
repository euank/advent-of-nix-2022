{ lib, pkgs }:
with lib;
let
  # part 1
  charToNum = c:
    if c == "A" || c == "X" then 1
    else if c == "B" || c == "Y" then 2
    else if c == "C" || c == "Z" then 3
    else throw "Invalid input";

  parseInput = file: map (ss: map charToNum (splitString " " ss)) (splitString "\n" (fileContents file));

  # winScore is the points (6 for win, 3 for draw, 0 for loss)
  # Our numbers are rock: 1, paper: 2, scissors: 3
  # We can thus see if it's a win by seeing if the RHS is 1 greater than the LHS, mod 3
  winScore = l: r:
    if l == r then 3 # draw
    else if (mod l 3) == (r - 1) then 6 # win
    else 0;

  part1Answer = input:
    let
      parsed = parseInput input;
    in
    foldl' (acc: el: acc + (winScore (head el) (elemAt el 1)) + (elemAt el 1)) 0 parsed;
in
{
  part1 = part1Answer ./input;
  #   part2 = part2Answer ./input;
}
