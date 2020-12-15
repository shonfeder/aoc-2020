accumulate "../common".

%% Represenation

namespace bag {
  kind t type.
  type v string -> bag.t.

  pred compare i:t, i:t, o:cmp.
  compare (v S) (v S') Cmp :- cmp_term S S' Cmp.

  pred set.empty o:std.set bag.t.
  set.empty Set :- std.set.make compare Set.
}


%% Parsing

pred parse-container-bag i:string, o:bag.t.
parse-container-bag Str Bag :-
                    rex_split " bags" Str [Color],
                    Bag = bag.v Color.

pred parse-contained-bag i:string, o:pair int bag.t.
parse-contained-bag Str (pr Num Bag) :-
                    rex_split " " Str (NumStr::Color1::Color2::Bag_::[]),
                    Num is string_to_int NumStr,
                    Color is Color1 ^ " " ^ Color2,
                    Bag = bag.v Color.

pred parse-contained-bags i:string, o:list (pair int bag.t).
parse-contained-bags "no other bags" [].
parse-contained-bags Str NumBags :-
                     rex_split ", " Str BagsStr,
                     std.map BagsStr parse-contained-bag NumBags.

pred make-contains i:bag.t, i:list (pair int bag.t), o:list prop.
make-contains _Bag [] [].
make-contains Bag  (pr Num CBag :: Bags) (contains Bag Num CBag::Props) :-
              make-contains Bag Bags Props.

pred parse-rule i:string, o:list prop.
:if "DEBUG" parse-rule Str _ :- print ">> parse-rule" Str, fail.
parse-rule Str Props :-
           rex_split "\\." Str [Str'],
           rex_split " contain " Str' (BagStr::ContainedBagsStr::[]),
           parse-container-bag BagStr Bag,
           parse-contained-bags ContainedBagsStr ContainedBags,
           make-contains Bag ContainedBags Props.

pred parse-rules i:string, o:list prop.
parse-rules FileName Props :-
            io.read_input_to FileName parse-rule PropsList,
            std.flatten PropsList Props.

%% Logic

%                Bag      Num    ContainedBag
mode (contains  o        o      o           ).
type  contains  bag.t -> int -> bag.t -> prop.

pred can-contain o:bag.t, o:int, i:bag.t.
can-contain Bag Num ContainedBag :-
            can-contain.aux Bag Num ContainedBag {bag.set.empty}.

pred can-contain.aux o:bag.t, o:int, o:bag.t, o:std.set bag.t.
can-contain.aux Bag Num ContainedBag Seen :-
                % The graph of bag containments might contain cycles, so we protect.
                not (std.set.mem ContainedBag Seen),
                contains Bag Num ContainedBag.
can-contain.aux Bag Num ContainedBag Seen :-
           contains Bag Num' Bag',
           % The [Num] of [ContainedBag]s that [Bag] can contain is
           % determined by multiplying the [Num'] of intermediate [Bag']s
           % it contain contain by the [Num''] of [ContainedBag]s the latter
           % can contain.
           declare_constraint (Num is Num' * Num'') [Num''],
           not (std.set.mem Bag' Seen),
           std.set.add Bag' Seen Seen',
           can-contain.aux Bag' Num'' ContainedBag Seen'.

pred solve-1 i:string, o:int.
solve-1 FileName Answer :-
        parse-rules FileName Rules,
        (Rules =>
         std.findall (can-contain Bag_ N_ (bag.v "shiny gold")) Containers,
         std.map Containers (Prop\Bag\ (can-contain Bag _ _ = Prop)) Bags,
         std.set.cardinal {set.of-list Bags} Answer).

pred solve-2 i:string, o:int.
solve-2 FileName Answer :-
        parse-rules FileName Rules,
        (Rules =>
         std.findall (can-contain (bag.v "shiny gold") N_ Bag_) Containers,
         print ">>>" Containers,
         std.map Containers (Prop\Num\ (can-contain _ Num _ = Prop)) Counts,
         std.fold Counts 0 (A\B\C\ C is A + B) Answer).

pred main.
main :-
     solve-2 "input.txt" Answer,
     print "Part 2 solution " Answer.

%% TESTS

pred test.run i:list any.
test.run _ :-
         test.parse-container-bag,
         test.parse-contained-bag,
         test.part-1,
         test.part-2.

pred test.parse-container-bag.
test.parse-container-bag :-
                         parse-container-bag "light red bags" Result,
                         ( Result = bag.v "light red"
                         ; std.fatal-error "parse-container-bag.test failed" ).

pred test.parse-contained-bag.
test.parse-contained-bag :-
                         ( parse-contained-bag "1 bright white bag"  (pr 1 (bag.v "bright white"))
                         , parse-contained-bag "3 bright white bags" (pr 3 (bag.v "bright white"))
                         , parse-contained-bag "4 muted yellow bags" (pr 4 (bag.v "muted yellow")))
                         ; std.fatal-error "parse-contained-bag.test failed".


pred test.part-1.
test.part-1 :-
            solve-1 "test.txt" Answer,
            ( Answer = 4
            ; print "Expected" 4 "found" Answer,
              std.fatal-error "test.part-1 failed").

pred test.part-2.
test.part-2 :-
            solve-2 "test.txt" Answer,
            ( Answer = 32
            ; print "Expected" 32 "found" Answer,
              std.fatal-error "test.part-2 failed" ).
