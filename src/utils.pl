:- module(utils, [clear_screen/0, player_pieces_in_board_coords/3, chebyshev_distance/3, min/3, get_min_from_list/2, remove_duplicates/2, closest_pieces/3, valid_coord/3, replace/4, between/3, my_random_member/2]).
:- use_module(library(lists)).
:- use_module(library(random)).

% Clear screen utility
% This predicate uses 2 ANSI escape codes ('\e[2J' and '\e[H') to clear the screen and move the cursor to the top left corner, respectively
clear_screen :- 
    write('\e[2J'),
    write('\e[H'),
    flush_output.

% Get player pieces in the board
% This function finds all the pieces of a given player on the board
% It uses findall to collect all the coordinates of the pieces by finding all stacks, and then verifying if the pieces of that stack are the players pieces
player_pieces_in_board_coords(Board, Player, Result) :- 
    findall((RowNum, ColNum, Height),
            (nth1(RowNum, Board, Row),
             nth1(ColNum, Row, Stack),
             member(piece(Player, Height), Stack)),
            Result).

% Calculate Chebyshev distance between two coordinates
% The Chebyshev distance is the maximum of the absolute differences between the coordinates
% This is used to calculate the distance between two pieces on the board, as these pieces travel diagonally, so Manhattan distance is not enough
chebyshev_distance((Row1, Col1), (Row2, Col2), Distance) :- 
    Distance is max(abs(Row1 - Row2), abs(Col1 - Col2)).

% Definition of a minimum predicate, that determines the minimum of two values
min(X, Y, X) :- X =< Y.
min(X, Y, Y) :- X > Y.

% Get the minimum element from a list
get_min_from_list(List1, List2):- get_min_from_list_helper(List1, 100, List2).

% Helper predicate for get_min_from_list
% This predicate iterates over the list, and finds the minimum element
% It ends when the list is empty, and returns the minimum element found
get_min_from_list_helper([], Acc, Acc).
get_min_from_list_helper([H|T], Acc, List2):- min(H, Acc, Acc1), get_min_from_list_helper(T, Acc1, List2).


% Remove duplicates from a list
% This predicate removes duplicates from a list, by iterating over the list and checking if the element is already in the list
% If it is a duplicate, it is not added to the result list, otherwise it is
remove_duplicates([], []).
remove_duplicates([H|T], [H|T1]) :- remove_duplicates(T, T1), \+(member(H, T1)).
remove_duplicates([H|T], T1) :- remove_duplicates(T, T1), member(H, T1).

% Find all pieces with the minimum Chebyshev distance to a given piece
% To do this, we first find all pieces on the board, then calculate the distance
% from the current piece to each of them, and finally we choose the ones with the minimum distance
% to the given piece
closest_pieces(Board, (Row, Col), ClosestPieces) :-
    all_piece_coordinates(Board, PieceCoordinates),
    exclude_current_piece((Row, Col), PieceCoordinates, OtherPieces),
    maplist(chebyshev_distance((Row, Col)), OtherPieces, Distances),
    get_min_from_list(Distances, MinDistance),
    findall((OtherRow, OtherCol),
            (nth1(Index, Distances, MinDistance),
             nth1(Index, OtherPieces, (OtherRow, OtherCol))),
            ClosestPieces).

% Precompute the coordinates of all pieces on the board
% To do this, we iterate over all rows and columns, and check if the stack at that position
% contains a piece. If it does, we add the coordinates to the list of piece coordinates
% We use findall to collect all the coordinates
all_piece_coordinates(Board, PieceCoordinates) :-
    findall((Row, Col),
            (nth1(Row, Board, RowList),
             nth1(Col, RowList, Stack),
             Stack \= [],
             member(piece(_, _), Stack)),
            PieceCoordinates).

% Manually filter out the current piece coordinates
% This predicate is used to filter out the current piece from the list of all pieces
% This is done by iterating over the list of pieces, and checking if the current piece is equal to the piece in the list
exclude_current_piece(_, [], []).
exclude_current_piece((Row, Col), [(Row, Col)|T], Result) :-
    exclude_current_piece((Row, Col), T, Result).
exclude_current_piece(Current, [H|T], [H|Result]) :-
    Current \= H,
    exclude_current_piece(Current, T, Result).

% Predicate to check if a coordinate is valid
% If the boardsize is 8, the coordinates must be between 1 and 8
valid_coord(8, Row, Col) :- 
    Row >= 1, Row =< 8, 
    Col >= 1, Col =< 8.

% If the boardsize is 10, the coordinates must be between 1 and 10
valid_coord(10, Row, Col) :-
    Row >= 1, Row =< 10,
    Col >= 1, Col =< 10.

% Replace an element in a list
% This predicate replaces the element at the given index in the list with the given element
replace([_|T], 1, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 1,
    I1 is I - 1,
    replace(T, I1, X, R).

% Tail-recursive random_member implementation
% This predicate generates a random index between 0 and the length of the list
my_random_member(Element, List) :-
    length(List, Length),
    Length > 0,
    MaxIndex is Length,
    random(0, MaxIndex, Index),
    % write(Index), nl,
    my_random_member_helper(List, Index, 0, Element).

% Helper predicate for my_random_member
% This predicate iterates over the list, and when the index is equal to the random index, it returns the element
my_random_member_helper([H|_], Index, Index, H).
my_random_member_helper([_|T], Index, CurrentIndex, Element) :-
    NextIndex is CurrentIndex + 1,
    my_random_member_helper(T, Index, NextIndex, Element).

