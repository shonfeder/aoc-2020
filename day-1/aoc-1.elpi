pred read_lines_to_ints i:in_stream, o:list int.
read_lines_to_ints Strm [] :- eof Strm, !.
read_lines_to_ints Strm (Int :: Ints) :-
                   input_line Strm L,
                   Int is (string_to_int L),
                   read_lines_to_ints Strm Ints.

pred read_input i:string, o:list int.
read_input FileName Ints :-
           open_in FileName Strm,
           read_lines_to_ints Strm Ints,
           close_in Strm.

pred solve-1.
solve-1 :-
      read_input "input.txt" Expenses,
      std.mem Expenses E1,
      std.mem Expenses E2,
      2020 is E1 + E2,
      Answer is E1 * E2,
      print ">> Answer: "
      print Answer.

pred solve-2.
solve-2 :-
      read_input "input.txt" Expenses,
      std.mem Expenses E1,
      std.mem Expenses E2,
      std.mem Expenses E3,
      2020 is E1 + E2 + E3,
      Answer is E1 * E2 * E3,
      print ">> Answer: "
      print Answer.
