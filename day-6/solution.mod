accumulate "../common".

pred list-to-set i:list string, o:std.string.set.
list-to-set Lst Set :-
       std.fold Lst {std.string.set.empty} std.string.set.add Set.

pred read-entries i:string, o:list string.
read-entries FileName RawEntries :-
       io.read_all FileName Raw,
       rex_split "\n\n" Raw RawEntries.

pred solve-1 i:string, o:int.
solve-1 FileName Answer :-
       read-entries FileName RawEntries,
       std.map RawEntries (rex_replace "\n" "") StrEntries,
       std.map StrEntries str.explode Entries,
       std.map Entries list-to-set SetEntries,
       std.map SetEntries std.string.set.cardinal EntryCardinalities,
       std.fold EntryCardinalities 0 (A\B\C\ C is A + B) Answer.

pred count-common-elements i:list string, i:int.
count-common-elements StrEntry Count :-
                      std.map StrEntry str.explode CharEntry,
                      std.map CharEntry list-to-set (E::Es),
                      std.fold Es E std.string.set.inter Common,
                      std.string.set.cardinal Common Count.

pred solve-2 i:string, o:int.
solve-2 FileName Answer :-
        read-entries FileName RawEntries,
        std.map RawEntries (rex_split "\n") StrEntries,
        std.map StrEntries count-common-elements Counts,
        std.fold Counts 0 (A\B\C\ C is A + B) Answer.
        % std.map StrEntries (pi E E'\ std.map E str.explode E) Entries,
        % std.map Entries (pi E E'\ std.map E list-to-set E') SetEntries,

pred main.
main :-
     solve-1 "test-1.txt" 11,
     print "Test 1 passed",
     solve-1 "input.txt" Answer,
     print "Part 1 solution: " Answer,
     solve-2 "test-1.txt" Test2,
     (Test2 = 6, print "Test 2 passed"; print "Test 2 Failed with" Test2),
     solve-2 "input.txt" Answer2,
     print "Part 2 solution: " Answer2.
