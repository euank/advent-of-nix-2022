{ lib, pkgs }:
with lib; with pkgs.lib;
let
  input = fileContents ./input;

  parseLine = line:
    let
      chars = (strings.stringToCharacters line);
      parseInt = chars:
        let
          f = num: chars:
            let c = head chars; in
            if c == "," then { int = num; rest = chars; }
            else if c == "]" then { int = num; rest = chars; }
            else f (10 * num + (strings.toInt c)) (tail chars);
        in
        f 0 chars;

      f = cur: rest:
        if length rest == 0 then { out = cur; rest = [ ]; }
        else
          let
            h = head rest;
          in
          if h == "[" then let el = f [ ] (tail rest); after = f [ ] el.rest; in { out = cur ++ [ el.out ] ++ after.out; rest = after.rest; }
          else if h == "]" then { out = cur; rest = tail rest; }
          else if h == "," then let n = (f [ ] (tail rest)); in { out = cur ++ n.out; rest = n.rest; }
          else let p = parseInt rest; in f (cur ++ [ p.int ]) p.rest;
    in
    head (f [ ] chars).out;

  pairs = map (s: map parseLine (strings.splitString "\n" s)) (strings.splitString "\n\n" input);

  cmp = lhs: rhs:
    if builtins.isInt lhs && builtins.isInt rhs then trivial.compare lhs rhs
    else if builtins.isList lhs && builtins.isList rhs then
      let icmp = foldl' (acc: el: if acc == 0 then (cmp el.fst el.snd) else acc) 0 (zipLists lhs rhs); in
      if icmp != 0 then icmp else trivial.compare (length lhs) (length rhs)
    else if builtins.isInt lhs then cmp [ lhs ] rhs
    else cmp lhs [ rhs ];

  isRightOrder = lhs: rhs: (cmp lhs rhs) < 0;

  part1Answer = foldl' (acc: pair: if (isRightOrder pair.lhs pair.rhs) then acc + pair.idx else acc) 0 (lists.imap1 (i: v: { idx = i; lhs = lists.head v; rhs = lists.last v; }) pairs);

in
# part2
let
  div1 = [ [ 2 ] ];
  div2 = [ [ 6 ] ];
  p2Pairs = (lib.lists.flatten1 pairs) ++ [ div1 div2 ];

  sorted = builtins.sort (lhs: rhs: (cmp lhs rhs) < 0) p2Pairs;
  idx1 = head (lists.remove null (lists.imap1 (idx: el: if el == div1 then idx else null) sorted));
  idx2 = head (lists.remove null (lists.imap1 (idx: el: if el == div2 then idx else null) sorted));
in
{
  inherit part1Answer;
  part2Answer = idx1 * idx2;
}
