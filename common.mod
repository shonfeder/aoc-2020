% Code shared between solutions

namespace std {

pred min i:A, i:A, o:A.
min N M N :- N =< M, !.
min _ M M.

pred add i:A, i:A, o:A.
add A B C :- C is A + B.
}
}

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

% TODO Fix implementation
% We shouldn't read a whole list to memory then reinsert line endeings.
pred read_all i:string, o:string.
read_all FileName Content :-
         read_input_to FileName (X\Y\ X = Y) Lines,
         std.fold Lines "" (A\B\C\ C is A ^ "\n" ^ B) Content.


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

namespace int {

% See https://stackoverflow.com/a/18338089/1187277
pred between i:int, i:int, o:int.
between N M K :- N =< M, K = N.
between N M K :- N == M, !, K = N.
between N M K :- N <  M, N1 is N + 1, between N1 M K.

}

namespace set {

% Only works for ground terms
pred of-list i:list A, o:std.set A.
of-list List Set :-
        std.set.make cmp_term Empty,
        std.fold List Empty std.set.add Set.
}

% Differene lists
namespace dl {

kind t type -> type.
type v list A -> list A -> t A.

% Where
%   - PL is a partial list like [1,2,3|FV]
%   - FV is an unbound variable
pred of-list i:list A, o:t A.
of-list L (v PL FV) :- std.append L FV PL.

pred to-list i:t A, o:list A.
to-list (v PL FV) PL :- FV = [].

}

namespace list {
% Convert a list of prpos into a conjuction of the same props.
pred to-conj i:list prop, o:prop.
to-conj [] true.
to-conj (P::Ps) (P & Conj) :- list.to-conj Ps Conj.

% [of-length N L] [L] is a list of length [N].
pred of-length i:int, o:list A.
of-length 0 [] :- !.
of-length N (X_::Xs) :- N > 0, of-length {calc (N - 1)} Xs.

pred replace-nth o:int, i:(A -> B -> prop), i:list A, o:list A.
replace-nth N P As Bs :- var N,
            Max is {std.length As} - 1,
            int.between 0 Max N,
            replace-nth N P As Bs.
replace-nth N P [A|Xs] [B|Xs] :- not (var N), N = 0, P A B, !.
replace-nth N P [X|Xs] [X|Bs] :-
            not (var N),
            N' is N - 1,
            replace-nth N' P Xs Bs.
replace-nth _ _ [] _ :- std.fatal-error "replace-nth out of elements".

% [select List X Rest] succeeds when [X] is an element selectef rom [List]
% and [Rest] is the list of reminaing elements.
pred select i:list A, o:A, o:list A.
select List X Rest :-
       std.appendR Pre Suffix List,
       std.appendR [X] Post Suffix,
       std.append Pre Post Rest.
select [] _ _ :- std.fatal-error "list.select called on empty list".

% Enumerates all sublists on backtracking
pred sublist o:list A, o:list A.
sublist _List [].
sublist List Sublist :-
        int.between 1 {std.length List} Len,
        list.of-length Len Sublist,
        std.appendR _Pre Suffix List,
        std.appendR Sublist _Post Suffix.

pred sum i:list int, o:int.
pred sum i:list float, o:float.
sum Ls I :- std.fold Ls 0 (A\B\C\ C is A + B) I.

pred max i:list A, o:A.
max [X|Xs] M :- std.fold Xs X std.max M, !.
max _ _ :- std.fatal-error "invalid arguments to list.max".

pred min i:list A, o:A.
min [X|Xs] M :- std.fold Xs X std.min M.
min _ _ :- std.fatal-error "invalid arguments to list.min".
}

% A partial and broken implementation of DCGs
namespace dcg {

pred appl-ios i:list (A -> B -> prop), i:A, o:B, o:list prop.
appl-ios [] _ _ [] :- !.
appl-ios [P] I O [PIO] :- PIO = P I O, !.
appl-ios (P::Ps) I O (P I O'::IOPs) :- appl-ios Ps O' O IOPs.

pred foo i:A, o:O.
foo A B :- B is A + 1.

pred phrase o:(list A -> list A -> prop), o:list A.
phrase P Ls :- P Ls [].

pred parse i:list A, i:(list B -> dcg A), o:list B.
parse In Parser Out :-
      std.length In Len,
      list.of-length Len Out,
      phrase (Parser Out) In,
      !.
}

pred seq o:list A, o:list A, o:list A.
macro @seq Ls I O :- std.appendR Ls O I.

% type rl (t A -> prop) -> list (t A -> prop) -> prop.
macro @rl Head Body :-
      (Head I O :-
            dcg.appl-ios Body I O Props,
            list.to-conj Props Conj,
            Conj).

typeabbrev (dcg A) (list A -> list A -> prop).

% Example
%
type sentence, noun_phrase, verb_phrase, det, noun, verb dcg string.
@rl sentence    [noun_phrase, verb_phrase].

@rl noun_phrase [det, noun].
@rl verb_phrase [verb, noun_phrase].

@rl det  [@seq ["the"]].
@rl det  [@seq ["a"]].

@rl noun  [@seq ["cat"]].
@rl noun  [@seq ["bat"]].

@rl verb  [@seq ["eats"]].

% Example of translating
type num int -> dcg string.
@rl (num 1) [@seq ["one"]].
@rl (num 2) [@seq ["two"]].

type nums list int -> dcg string.
@rl (nums []) [].
@rl (nums (N::Ns))
    [ num N
    , nums Ns
    ].
