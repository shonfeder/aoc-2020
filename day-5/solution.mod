% https://adventofcode.com/2020/day/5

accumulate "../common".

%          Spec          Row    Seat    ID
mode (seat o             o      o       o).
type seat list string -> int -> int  -> int -> prop.

mode (rows o).
type rows int -> prop.

mode (columns o).
type columns int -> prop.

kind partition-dir type.
type lower partition-dir.
type upper partition-dir.

pred seat-id i:prop, o:int.
seat-id (seat _ _ _ ID) ID.

pred partition i:partition-dir, i:(pair int int), o:(pair int int).
:if "DEBUG" partition Dir Rng _ :- print "> partition" Dir Rng, fail.
partition lower (pr Low High) (pr Low  High') :-
          H is Low + ((High - Low) div 2),
          if (H > Low) (High' = H) (High' = Low).
partition upper (pr Low High) (pr Low' High)  :-
          L is High - ((High - Low) div 2),
          if (L  < High) (Low' = L) (Low' = High).

pred spec-code_partition-dir i:string, o:partition-dir.
spec-code_partition-dir "F" lower.
spec-code_partition-dir "B" upper.
spec-code_partition-dir "L" lower.
spec-code_partition-dir "R" upper.

pred partition-spec i:list string, i:int, i:int, o:int.
:if "DEBUG" partition-spec Spec Low High Value :- print "> partition-spec" Spec Low High Value, fail.
partition-spec Spec Low High Value :-
         std.map Spec spec-code_partition-dir Dirs,
         ( std.fold Dirs (pr Low High) partition (pr Value Value)
         ; fatal-error "Failed to find value!" ).

pred parse i:string, o:prop.
:if "DEBUG" parse Str _ :- print "> parse" Str, fail.
parse Str (seat Spec Row Seat ID) :-
      str.explode Str Spec,
      std.take 7 Spec RowSpec,
      std.drop 7 Spec SeatSpec,
      rows R,
      partition-spec RowSpec 0 R Row,
      columns C,
      partition-spec SeatSpec 0 C Seat,
      ID is Row * 8 + Seat.

pred test-1 i:list A.
test-1 _ :-
       rows 127 => columns 7 =>
       io.read_input_to "test-1.txt" parse Seats,
       Seats =>
       if ( seat _ 44  5 357
          & seat _ 70  7 567
          & seat _ 14  7 119
          & seat _ 102 4 820 )
          (print "test-1 passed")
          (print "test-1 failed: " Seats).

pred solve-1 o:int.
solve-1 Answer :-
       rows 127 => columns 7 =>
       io.read_input_to "input.txt" parse Seats,
       std.map Seats seat-id IDs,
       std.fold IDs 0 std.max Answer.

pred solve-2 o:int.
solve-2 Answer :-
       rows 127 => columns 7 =>
       io.read_input_to "input.txt" parse Seats,
       % Assume all the seats into the database
       Seats =>
       % Find a seat ID with neighboring IDs but missing a
       % boarding pass in the database.
       ( seat _ _ _ N
       & Answer is N + 1 & not (seat _ _ _ Answer)
       & M is Answer + 1 & seat _ _ _ M ).

main :-
     solve-1 Answer,
     print "Part 1 solution:" Answer,
     solve-2 Answer2,
     print "Part 2 solution: " Answer2.
