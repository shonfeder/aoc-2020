accumulate "../common".

typeabbrev state (pair int int).

kind op type.
type nop int -> op.
type acc int -> op.
type jmp int -> op.

pred instr o:int, o:op.

pred execute i:int, i:int, o:int, o:int.
execute Line Acc Line' Acc :-
        instr Line (nop _),
        Line' is Line + 1.
execute Line Acc Line' Acc' :-
        instr Line (acc N),
        Acc' is Acc + N,
        Line' is Line + 1.
execute Line Acc Line' Acc :-
        instr Line (jmp N),
        Line' is Line + N.

pred str-op i:string, o:(int -> op).
str-op "nop" nop.
str-op "acc" acc.
str-op "jmp" jmp.

pred parse i:int, i:string, o:prop.
parse I Str Prop :-
      rex_split " " Str [OpName, SignNumStr],
      str-op OpName Op,
      Sign is substring SignNumStr 0 1,
      NumStr is substring SignNumStr 1 (size SignNumStr - 1),
      Num' is string_to_int NumStr,
      if (Sign = "+") (Num = Num') (Num = (~ Num')),
      Prop = instr I (Op Num).

pred load i:string, o:list prop.
load FileName Program :-
     io.read_input_to_i FileName parse Program.

type seen int -> prop.

pred find-loop o:int.
find-loop Acc :- find-loop.aux 0 0 Acc.

pred find-loop.aux i:int, i:int, o:int.
find-loop.aux Line Acc Acc :- seen Line, !.
find-loop.aux Line Acc' Acc :-
              execute Line Acc' Line' Acc'',
              seen Line =>
              find-loop.aux Line' Acc'' Acc.


pred solve-1 i:list A.
solve-1 [FileName] :-
        load FileName Program,
        Program =>
        find-loop Answer,
        print ">>>" Answer.

pred solve-2 i:list A.
solve-2 [FileName] :-
        load FileName Program,
        list.replace-nth _ fix-instr Program Program',
        run Program' (finished Answer),
        print ">>>" Answer.

pred fix-instr i:prop, o:prop.
fix-instr (instr Ln (jmp N)) (instr Ln (nop N)).
fix-instr (instr Ln (nop N)) (instr Ln (jmp N)).
fix-instr (instr Ln (acc N)) (instr Ln (acc N)).

kind result type.
type finished int -> result.
type loop     result.

pred run i:list prop, o:result.
run Program Result :-
    std.length Program Final,
    Program => run.aux Final 0 0 Result.

pred run.aux i:int, i:int, i:int, o: result.
run.aux Final Final Acc Result :- Result = finished Acc.
run.aux _ Line _ loop :- seen Line.
run.aux Final Line  Acc Result :-
        not (seen Line),
        (seen Line =>
        ( execute Line Acc Line' Acc'
        & run.aux Final Line' Acc' Result)).
