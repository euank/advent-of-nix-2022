{ lib
, pkgs
,
}:
with lib; let
  # part 1
  parseInput = file: map (ss: map toInt (splitString "\n" ss)) (splitString "\n\n" (fileContents file));

  part1Answer = input:
    let
      parsed = parseInput input;
      sum = xs: foldl' add 0 xs;
    in
    foldl' max 0 (map sum parsed);

  # part 2
  part2Answer = input:
    let
      parsed = parseInput input;
      sum = xs: foldl' add 0 xs;
      summed = map sum parsed;
      sorted = lists.sort (a: b: a > b) summed;
    in
    sum (take 3 sorted);
in
{
  part1 = part1Answer ./input;
  part2 = part2Answer ./input;
}
