accumulate "../common".

kind result type.
type valid result.
type invalid int -> result.

pred validate-xmas-cypher i:int, i:list int, o:result.
validate-xmas-cypher Window Cypher Result :-
                     std.split-at Window Cypher Preamble Rest,
                     validate-xmas-cypher.aux Preamble Rest Result.

pred validate-xmas-cypher.aux i:list int, i:list int, o:result.
validate-xmas-cypher.aux _ [] valid.
validate-xmas-cypher.aux Preamble [N|_] (invalid N) :- not (valid Preamble N), !.
validate-xmas-cypher.aux [_|Preamble] [N|Ns] Result :-
                         std.append Preamble [N] Preamble',
                         validate-xmas-cypher.aux Preamble' Ns Result.

pred valid i:list int, i:int.
valid Ns N :-
      std.mem Ns X,
      std.mem Ns Y,
      not (X == Y),
      N is X + Y.

pred load-cypher i:string, o:list int.
load-cypher FileName Cypher :-
            io.read_input_to FileName (Str\Int\ Int is string_to_int Str) Cypher.

type solve-1, solve-2 list string -> prop.

solve-1 [WindowStr, FileName] :-
        Window is string_to_int WindowStr,
        load-cypher FileName Cypher,
        validate-xmas-cypher Window Cypher Result,
        print ">>> " Result.

solve-2 [NumStr, FileName] :-
        Num is string_to_int NumStr,
        load-cypher FileName Cypher,
        int.between 2 {std.length Cypher} Len,
        list.of-length Len Sub,
        list.sublist Cypher Sub,
        list.sum Sub Num,
        list.max Sub Max,
        list.min Sub Min,
        Answer is Max + Min,
        print ">>> " Answer.
