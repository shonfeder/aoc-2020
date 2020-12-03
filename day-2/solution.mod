accumulate "../common".

% [count-chars Char Str Chars] is true when [Chars] is the number of times
% [Char] occurrs in [Str].
%
% Char must be a single character string
pred count-chars i:string, i:string, o:int.
count-chars Char Str Count :-
            str.explode Str Chars,
            std.filter Chars ((=) Char) Matching,
            std.length Matching Count.

kind password type.
type pwd int -> int -> string -> string -> password.

pred pwd.parse i:string, o:password.
pwd.parse Str Pred :-
      rex_split " " Str [Range, CharColon, Pwd],
      rex_split "-" Range [MinStr, MaxStr],
      Min is string_to_int MinStr,
      Max is string_to_int MaxStr,
      rex_split ":" CharColon [Char],
      Pred = (pwd Min Max Char Pwd).

pred count-valid-pwds i:(password -> o), o:int.
count-valid-pwds Validity Count :-
                 io.read_input_to "input.txt" pwd.parse Pwds,
                 std.filter Pwds Validity Valid,
                 std.length Valid Count.

pred valid-old i:password.
valid-old (pwd Min Max Char Pwd) :-
          count-chars Char Pwd N,
          Min =< N, N =< Max,
          !.

pred solve-1 o:int.
solve-1 Answer :- count-valid-pwds valid-old Answer.

pred valid-new i:password.
valid-new (pwd I J Char Pwd) :-
          IChar is substring Pwd (I - 1) 1,
          JChar is substring Pwd (J - 1) 1,
          ( Char = IChar, not (Char = JChar)
          ; Char = JChar, not (Char = IChar) ).

pred solve-2 o:int.
solve-2 Answer :- count-valid-pwds valid-new Answer.
