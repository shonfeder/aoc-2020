% Code shared between solutions

namespace io {

%% [read_lines_to_i Strm Parse List] is the list of terms produced by applying
%% parsing each line with [Parse], which takes the current index of the line as
%% its first argument.
pred read_lines_to_i i:in_stream, i:(int -> string -> A -> o), o:list A.
read_lines_to_i Strm Parse Terms :- read_lines_to_i.aux Strm 0 Parse Terms.

pred read_lines_to_i.aux i:in_stream, i:int, i:(int -> string -> A -> o), o:list A.
read_lines_to_i.aux Strm _ _ [] :- eof Strm, !.
read_lines_to_i.aux Strm N Parse (Term :: Terms) :-
                    input_line Strm L,
                    Parse N L Term,
                    N' is N + 1,
                    read_lines_to_i.aux Strm N' Parse Terms.

pred read_lines_to i:in_stream, i:(string -> A -> o), o:list A.
read_lines_to Strm Parse Terms :-
              read_lines_to_i Strm (_Int \ Parse) Terms.

pred read_input_to_i i:string, i:(int -> string -> A -> o), o:list A.
read_input_to_i FileName Parse Terms :-
                Reader = (Strm \ read_lines_to_i Strm Parse Terms),
                read_from_file FileName Reader.

pred read_input_to i:string, i:(string -> A -> o), o:list A.
read_input_to FileName Parse Terms :-
              read_input_to_i FileName (_Int \ Parse) Terms.

pred read_from_file i:string, i:(in_stream -> prop).
read_from_file FileName Reader :-
               open_in FileName Strm,
               Reader Strm,
               close_in Strm,
               !.
}

namespace str {

pred explode i:string, o:list string.
explode S Ss :-
        Len is size S,
        explode.aux 0 Len S Ss.

explode.aux Len Len _ [].
explode.aux Idx Len S (X :: Ss) :-
            Idx < Len,
            X is substring S Idx 1,
            Idx' is Idx + 1,
            explode.aux Idx' Len S Ss.

% `split_on Str SubStr (pr Front Back)` is true when Front and Back are the
% respective substrings of Str that are separated by SubStr. If SubStr doesn't
% occur within Str, then Back = "" and Front = Str.
pred split_on i:string, i:string, o:pair string string.
split_on Str SubStr Split :-
        Len    is size Str,
        SubLen is size SubStr,
        split_on.aux Len SubLen 0 Str SubStr Split.

split_on.aux Len _      Len Str _      (pr Str   "").
split_on.aux Len SubLen Idx Str SubStr (pr Front Back) :-
    SubStr  is substring Str Idx SubLen,
    Front   is substring Str 0   Idx,
    Idx'    is Idx + SubLen,
    BackLen is Len - Idx',
    Back    is substring Str Idx' BackLen.
split_on.aux Len SubLen Idx Str SubStr Split :-
    Idx' is Idx + 1,
    split_on.aux Len SubLen Idx' Str SubStr Split.
}
