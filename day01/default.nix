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
in
{
  part1 = part1Answer ./input;
}
