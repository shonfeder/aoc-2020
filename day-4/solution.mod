accumulate "../common".

pred required-fields o:list string.
required-fields ["byr",  "iyr",  "eyr",  "hgt",  "hcl",  "ecl",  "pid"]. %  "cid" is optional

pred parse-field i:string, o:(pair string string).
parse-field Str (pr Name Value) :-
            rex_split ":" Str [Name, Value] .

pred parse-entry i:string, o:list (pair string string).
parse-entry String Entry :-
            rex_split "\\(\n\\| \\)" String Fields,
            std.map Fields parse-field Entry.

pred entry-has-field i:(list (pair string string)), i:string.
entry-has-field Entry FName :- std.mem Entry (pr FName _).

pred field-valid i:(pair string string).
field-valid (pr Name Value) :- field-valid.aux Name Value.

pred field-valid.aux i:string, i:string.
:if "DEBUG" field-valid.aux Name Value :- print "validating field" Name Value, fail.
field-valid.aux "byr" Year :-
            YearInt = string_to_int Year,
            1920 =< YearInt, YearInt =< 2002.
field-valid.aux "iyr" Year :-
            YearInt = string_to_int Year,
            2010 =< YearInt, YearInt =< 2020.
field-valid.aux "eyr" Year :-
            YearInt = string_to_int Year,
            2020 =< YearInt, YearInt =< 2030.
field-valid.aux "hcl" Color :-
            7 is size Color,
            rex_match "^#[0-9a-f]+$" Color.
field-valid.aux "ecl" Color :-
            std.mem ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"] Color.
field-valid.aux "pid" PassportID :-
            9 is size PassportID,
            rex_match "^[0-9]+$" PassportID.
field-valid.aux "hgt" Height :-
            rex_match "^[1-9][0-9]+in$" Height,
            rex_split "in" Height [InStr],
            In is string_to_int InStr,
            59 =< In, In =< 76.
field-valid.aux "hgt" Height :-
            rex_match "^[1-9][0-9]+cm$" Height,
            rex_split "cm" Height [CmStr],
            Cm is string_to_int CmStr,
            150 =< Cm, Cm =< 193.
field-valid.aux "cid" _. %ignored, missing or not.

pred valid-entry i:list (pair string string).
valid-entry Entry :-
            std.forall {required-fields} (entry-has-field Entry).

pred entry-fields-valid i:(list (pair string string)).
:if "DEBUG" entry-fields-valid Entry :- print "validating entry" Entry, fail.
entry-fields-valid Entry :-
                   valid-entry Entry,
                   std.forall Entry field-valid.

pred parse-entries i:string, o:list (list (pair string string)).
parse-entries FileName Entries :-
     io.read_all FileName Raw,
     rex_split "\n\n" Raw RawEntries,
     std.map RawEntries parse-entry Entries.

pred test-1.
test-1 :- solve-1 "test-1.txt" 2.

pred solve-1 i:string, o:int.
solve-1 FileName Answer :-
     parse-entries FileName Entries,
     std.filter Entries valid-entry ValidEntries,
     std.length ValidEntries Answer.

pred test-2-valid.
test-2-valid :-
             parse-entries "test-2-valid.txt" Entries,
             std.forall Entries entry-fields-valid.

pred test-2-invalid.
test-2-invalid :-
              parse-entries "test-2-invalid.txt" Entries,
              (std.forall Entries (E\ not (entry-fields-valid E))).

solve-2 Answer :-
        parse-entries "input.txt" Entries,
        std.filter Entries entry-fields-valid Valid,
        std.length Valid Answer.

main :-
     test-1, print ">>> Test 1 passed",
     solve-1 "input.txt" Answer1,
     print "Part 1 Solution: " Answer1,
     test-2-valid, print ">>> Test 2 Valid passed",
     test-2-invalid, print ">>> Test 2 Invalid passed",
     solve-2 Answer2,
     print "Part 2 Solution: " Answer2.
