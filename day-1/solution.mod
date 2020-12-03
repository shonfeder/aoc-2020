accumulate "../common".

pred parser i:string, o:int.
parser S I :- I is string_to_int S.

pred solve-1.
solve-1 :-
      io.read_input_to "input.txt" parser Expenses,
      std.mem Expenses E1,
      std.mem Expenses E2,
      2020 is E1 + E2,
      Answer is E1 * E2,
      print ">> Answer: " Answer.

pred solve-2.
solve-2 :-
      io.read_input_to "input.txt" parser Expenses,
      std.mem Expenses E1,
      std.mem Expenses E2,
      std.mem Expenses E3,
      2020 is E1 + E2 + E3,
      Answer is E1 * E2 * E3,
      print ">> Answer: " Answer.
