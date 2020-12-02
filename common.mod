% Code shared between solutions

namespace io {

pred read_lines_to i:in_stream, i:(string -> A -> o), o:list A.
read_lines_to Strm _ [] :- eof Strm, !.
read_lines_to Strm Parse (Term :: Terms) :-
              input_line Strm L,
              Parse L Term,
              read_lines_to Strm Parse Terms.

pred read_input_to i:string, i:(string -> A -> o), o:list A.
read_input_to FileName Parse Terms :-
           open_in FileName Strm,
           read_lines_to Strm Parse Terms,
           close_in Strm.

}
