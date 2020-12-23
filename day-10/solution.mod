accumulate "../common".

pred adapter-can-connnect i:int, i:int, o:int.
adapter-can-connnect Output Adapter Difference :-
                     Difference is Adapter - Output,
                     0 =< Difference, Difference =< 3.

pred select-adapter i:list int, i:int, o:int, o:int, o:list int.
select-adapter Adapters Output Adapter Difference Rest :-
               list.select Adapters Adapter Rest,
               adapter-can-connnect Output Adapter Difference.

pred chain-adapters i:list int, o:list (pair int int).
chain-adapters Adapters Adaptations :- chain-adapters.aux Adapters 0 Adaptations.

pred chain-adapters.aux i:list int, i:int, o:list (pair int int).
chain-adapters.aux [] _ [].
chain-adapters.aux Adapters Output [pr Adapter Diff|Adaptations] :-
                   select-adapter Adapters Output Adapter Diff Adapters',
                   chain-adapters.aux Adapters' Adapter Adaptations.

type solve-1, solve-2 list string -> prop.

solve-1 [FileName] :-
        io.read_input_to FileName int.of-string Adapters,
        chain-adapters {std.rev {list.sort Adapters}} Differences,
        std.filter Differences ((=) (pr _ 3)) Diff3,
        std.filter Differences ((=) (pr _ 1)) Diff1,
        Answer is ({std.length Diff3} + 1) * {std.length Diff1},
        print ">>> " Answer.

namespace adapter {

% Propositions constructed and assumed at runtime
type have int -> prop.
type count int -> int -> prop.

pred all o:list int.
all Adapters :- std.map {std.findall (have A_)} (P\A\ P = have A) Adapters.

% [plugs-into A B] is true if [A] can plug into [B]
pred plugs-into o:int, o:int.
plugs-into Adapter Adapter' :-
         have Adapter, have Adapter',
         Adapter < Adapter',
         {calc (Adapter' - Adapter)} =< 3.

% [children A As] where [As] are all the adapters that can plug into [A].
pred children i:int, o:list int.
children Adapter Adapters :-
             std.findall (plugs-into Adapter A_) Props,
             std.map Props (P\A\ P = plugs-into _ A) Adapters.

% [chains-from Adapter Count] is the [Count] of the number of chains that could connect
% to our device starting from the [Adapter].
pred chains-from i:int, o:int.
chains-from Adapter Count :-
            children Adapter Children,
            if ([] = Children)
               (Count = 1)
               (list.sum {std.map Children count} Count).

% The number of chains that can be made using any adapters we have
% to connect our device.
pred count-chains o:int.
count-chains Count :-
             std.rev {list.sort {all}} Adapters,
             pi counter\ (
                (counter [] :- chains-from 0 Count) &
                pi A As C\
                (counter [A|As] :-
                         chains-from A C,
                         count A C => % Memoize the count for A
                         counter As)
             ) => counter Adapters.

} % adapter

solve-2 [FileName] :-
        io.read_input_to FileName int.of-string Adapters,
        std.map [0|Adapters] (N\P\ P = adapter.have N) AdapterProps,
        AdapterProps =>
        adapter.count-chains Count ,
        print ">>> Count " Count .
