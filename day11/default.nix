{ lib, pkgs }:
with lib; with pkgs.lib; let
  input = fileContents ./input;

  parseOperation = opLine:
    let
      matches = builtins.match "^new = old (.) (.*)$" opLine;
      op = lists.head matches;
      rhs' = lists.last matches;
    in
    {
      apply = old:
        let rhs = if rhs' == "old" then old else (strings.toInt rhs'); in
        if op == "+" then (old + rhs) else if op == "*" then (old * rhs) else builtins.throw "unreachable";
    };

  parseTests = lines:
    let
      matches = builtins.match "Test: divisible by ([0-9]+) .*If true: throw to monkey ([0-9]+) .*If false: throw to monkey ([0-9]+)" (strings.concatStringsSep " " lines);
      divBy = strings.toInt (head matches);
      ifMatch = strings.toInt (lists.elemAt matches 1);
      ifNotMatch = strings.toInt (lists.elemAt matches 2);
    in
    {
      num = divBy;
      apply = num: if (mod num divBy) == 0 then ifMatch else ifNotMatch;
    };

  parseMonkey = monkey:
    let
      lines = lists.map (strings.removePrefix " ") (lists.drop 1 (strings.splitString "\n" monkey));
      items = lists.map strings.toInt (strings.splitString ", " (strings.removePrefix "Starting items: " (trimSpace (head lines))));
      operation = parseOperation (strings.removePrefix "Operation: " (trimSpace (lists.elemAt lines 1)));
      tests = parseTests (lists.map (strings.removePrefix " ") (lists.sublist 2 4 lines));
    in
    {
      inherit items operation tests;
    };

  monkeys =
    let ss = strings.splitString "\n\n" input;
    in lists.map parseMonkey ss;

  worryLCM = foldl' (l: r: l * r) 1 (map (i: i.tests.num) monkeys);

  doMonkey = p2: state: idx:
    let
      curMonkey = lists.elemAt state.monkeys idx;
      inspections = lists.length curMonkey.items;
      newMonkeys = foldl'
        (monkeys: item:
          let
            monkey = (lists.elemAt monkeys idx);
            newItem = monkey.operation.apply item;
            newItem' = if p2 then (mod newItem worryLCM) else (newItem / 3);
            throwTarget = monkey.tests.apply newItem';
            newMonkeys = setlist throwTarget (let old = lists.elemAt monkeys throwTarget; in { items = old.items ++ [ newItem' ]; operation = old.operation; tests = old.tests; }) monkeys;
          in
          newMonkeys
        )
        state.monkeys
        curMonkey.items;
      newMonkeys' = setlist idx ({ items = [ ]; operation = curMonkey.operation; tests = curMonkey.tests; }) newMonkeys;
    in
    {
      monkeys = newMonkeys';
      inspections = setlist idx ((lists.elemAt state.inspections idx) + inspections) state.inspections;
    };

  playRound = p2: state: foldl' (doMonkey p2) state (builtins.genList trivial.id (length state.monkeys));

  initInspections = builtins.genList (i: 0) (length monkeys);
  endState = foldl' (ms: i: playRound false ms) { inherit monkeys; inspections = initInspections; } (builtins.genList trivial.id 20);
  monkeyBusiness = foldl' (acc: x: acc * x) 1 (lists.take 2 (builtins.sort (l: r: l > r) endState.inspections));

  endState2 = foldl' (ms: i: playRound true ms) { inherit monkeys; inspections = initInspections; } (builtins.genList trivial.id 10000);
  monkeyBusiness2 = foldl' (acc: x: acc * x) 1 (lists.take 2 (builtins.sort (l: r: l > r) endState2.inspections));

in
{
  part1 = monkeyBusiness;
  part2 = monkeyBusiness2;
}
