accumulate "../common".

kind obj type.
type tree obj.

pred string-obj i:string, o:option obj.
string-obj "#" (some tree).
string-obj "." none.

% Make a conditoinal proposition of the form [coord N Y Obj],
% which we will later assume into memory for querying.
pred make-coord i:int, i:int, i:int, i:string, o:prop.
make-coord Width Y X ObjStr Coord :-
           string-obj ObjStr Obj,
           % We construct a conditional proposition, using modulus to
           % capture the repetition of the grid.
           Coord = (coord N Y Obj :- X is N mod Width).

% Parse a line into a list of [coord] predicates
pred parse i:int, i:string, o:list prop.
parse Y Str Coords :-
      Width is size Str,
      MakeCoord = make-coord Width Y,
      str.explode Str Chars,
      std.map-i Chars MakeCoord Coords.

% Increment a pair of coords given an assumed slope.
pred incr-coords i:pair int int, o:pair int int.
incr-coords (pr X Y) (pr X' Y') :-
            slope M N,
            X' is X + M,
            Y' is Y + N.

pred count-trees-in-slope o:int.
count-trees-in-slope Total :-
                     % Start searching from the upper left corner
                     X = 0, Y = 0,
                     Count = 0,
                     count-trees-in-slope.aux X Y Count Total.

pred count-trees-in-slope.aux i:int, i:int, i:int, o:int.
count-trees-in-slope.aux X Y Total Total :- not (coord X Y _), !.     % If there are no more coords, we're at the bottom
count-trees-in-slope.aux X Y Count Accum :-
                         coord X Y Obj,                               % Lookup the coordinate at X Y
                         ( (Obj = none       , Count' = Count)        % no tree
                         ; (Obj = (some tree), Count' is Count + 1)), % count the ree
                         incr-coords (pr X Y) (pr X' Y'),
                         count-trees-in-slope.aux X' Y' Count' Accum.

pred solve-for-slope i:int, i:int, i:list prop, o:int.
solve-for-slope M N Coords Answer :-
                % Assume the slope for use in incrementing coordinates
                slope M N =>
                % Assume all the coord propositions (using N-ary implication: https://github.com/LPCIC/elpi/blob/master/ELPI.md#n-ary-implication)
                % This is building the map.
                Coords =>
                count-trees-in-slope Answer.

pred solve-1 i:int, i:int, o:int.
solve-1 X Y Answer :-
        io.read_input_to_i "input.txt" parse Coords',
        std.flatten Coords' Coords,
        solve-for-slope X Y Coords Answer.

pred solve-2 o:int.
solve-2 Answer :-
        Answer is {solve-1 1 1} *
                  {solve-1 3 1} *
                  {solve-1 5 1} *
                  {solve-1 7 1} *
                  {solve-1 1 2} .

% FIXME: This is prefered, so we don't need to reparse file but it gives an incorrect answer! WHY?
% pred solve-2 o:int.
% solve-2 Answer :-
%         io.read_input_to_i "input.txt" parse Coords',
%         std.flatten Coords' Coords,
%         Answer is {solve-for-slope 1 1 Coords} *
%                   {solve-for-slope 3 1 Coords} *
%                   {solve-for-slope 5 1 Coords} *
%                   {solve-for-slope 7 1 Coords} *
%                   {solve-for-slope 1 2 Coords} .
