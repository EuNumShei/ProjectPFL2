:- module(display, [display_game/1, display_pieces/2, display_destinations/3]).
:- use_module(library(lists)).
:- use_module(game).

% Tail-recursive between predicate
% This predicate generates all the integers between two given integers
% It uses an accumulator to keep track of the current value, and generates the next value by incrementing the current value
between(Start, End, Value) :-
    between_helper(Start, End, Start, Value).
between_helper(Current, End, _, Current) :-
    Current =< End.
between_helper(Current, End, Start, Value) :-
    Current < End,
    Next is Current + 1,
    between_helper(Next, End, Start, Value).

% Display the game state
% This is the main predicate for displaying the game
% It displays the current player, the number of stacks won by each player, the board, and the current situation for the player
% This predicate is specifically designed for the white player
display_game(state(_, _, Board, w, [BlackWins, WhiteWins])) :- 
    write('DISPLAYING GAME STATE'), nl,
    write('Current Player: '), 
    (write('White')), nl,
    write('Stacks Won - Black: '), write(BlackWins),
    write(' White: '), write(WhiteWins), nl,
    length(Board, BoardSize),
    write('   '), % Extra space for alignment
    nl, nl,
    display_column_headers(BoardSize),
    reverse(Board, ReversedBoard),
    display_board(ReversedBoard, BoardSize),
    value(state(_, _, Board, w, [BlackWins, WhiteWins]), w, Value),
    write('Current situation for '), 
    write('White'), 
    write(': '), situation_message(Value, Message), write(Message), nl.

% Display the game state
% This predicate is specifically designed for the black player
display_game(state(_, _, Board, b, [BlackWins, WhiteWins])) :- 
    write('DISPLAYING GAME STATE'), nl,
    write('Current Player: '), 
    write('Black'), nl,
    write('Stacks Won - Black: '), write(BlackWins),
    write(' White: '), write(WhiteWins), nl,
    length(Board, BoardSize),
    write('   '), % Extra space for alignment
    nl, nl,
    display_column_headers(BoardSize),
    reverse(Board, ReversedBoard),
    display_board(ReversedBoard, BoardSize),
    value(state(_, _, Board, b, [BlackWins, WhiteWins]), b, Value),
    write('Current situation for '), 
    write('Black'), 
    write(': '), situation_message(Value, Message), write(Message), nl.

% This predicate associates the value of the game state for the player with a positive or negative message
situation_message(0, 'Neutral').
situation_message(1, 'Good').
situation_message(2, 'Very Good').
situation_message(3, 'Victory').
situation_message(-1, 'Bad').
situation_message(-2, 'Very Bad').
situation_message(-3, 'Defeat').

% Display column headers with proper spacing
display_column_headers(Size) :-
    write('   '),
    print_column_numbers(Size),
    write(''), nl,
    write('  +'),
    display_column_borders(Size).

% This predicate prints the column numbers with proper spacing
% We use findall and the previously defined between predicate to generate a list of numbers from 1 to Size
% We then map over the list and print each number with proper padding
print_column_numbers(Size) :-
    findall(N, between(1, Size, N), Headers),
    maplist(write_padded_header, Headers).

% Helper predicate to print a single column number with proper padding
% We use format directives to center-align the number and add padding
write_padded_header(Header) :-
    format('    ~w     ', [Header]).

write_padded_header(Header) :-
    format('~|~t~w~t~9+', [Header]).  % Center-aligned, 9 spaces wide

% This predicate displays the column borders with proper spacing
% We use a recursive predicate to print the column borders for each column
display_column_borders(0) :- nl.
display_column_borders(Size) :-
    Size > 0,
    write('---------+'),
    NextSize is Size - 1,
    display_column_borders(NextSize).

% Display board rows with proper spacing
% We reverse the board to display it from top to bottom like the assignment says 
% To display the board, we iterate over each row and display the row number, followed by the row itself
% With format directives, we can center-align the row number and stack pieces
display_board([], _).
display_board([Row|Rest], RowNum) :- 
    format('~|~t~w~t~2+', [RowNum]), % We use a slash as divisor, t is the tabulation, the w is the word, and 2 is the width in spaces
    write('|'),
    display_row(Row), % displaying the row with format directives
    nl,
    write('  +'), % Extra space for alignment
    length(Row, Size),
    display_column_borders(Size),
    NextRow is RowNum - 1,
    display_board(Rest, NextRow).

% Display single row 
% We recursively display the stack with display_stack, only ending when the row is empty
display_row([]).
display_row([Stack|Rest]) :- 
    display_stack(Stack),
    display_row(Rest).

% Stack display with fixed-width formatting
display_stack([]) :- 
    write('    .    |').
display_stack([piece(Color, Height)|Rest]) :- 
    stack_to_string([piece(Color, Height)|Rest], String),
    format('~|~t~w~t~9+', [String]), % Center-aligned, 9 spaces wide to be able to display all 8 pieces
    write('|').

% Convert stack to compact string representation
% To be able to display it
stack_to_string(Stack, String) :-
    stack_to_string_helper(Stack, [], Chars),
    concat_atoms(Chars, String).

stack_to_string_helper([], Acc, Acc).
stack_to_string_helper([piece(Color, _)|Rest], Acc, Result) :-
    append(Acc, [Color], Acc1),
    stack_to_string_helper(Rest, Acc1, Result).

% Concatenate a list of atoms into a single atom
% In order to display the stack
concat_atoms([Atom], Atom).
concat_atoms([Atom1, Atom2|Rest], Result) :-
    atom_concat(Atom1, Atom2, Temp),
    concat_atoms([Temp|Rest], Result).

% Display pieces with indices
% Used for listing the pieces the player can choose from
% We display the pieces with their coordinates and height
display_pieces([], _).
display_pieces([(Row, Col, Height, _)|Rest], Index) :- 
    write(Index), write('. ('), write(Row), write(','), write(Col), write(','), write(Height), write(')'), nl,
    NextIndex is Index + 1,
    display_pieces(Rest, NextIndex).

% Display destinations with indices
% Used for listing the destinations the player can choose from
% We display the destinations with their coordinates
% After the piece choice
% The function is called with the list of valid moves for the chosen piece
% And the index of the chosen piece
% And the helper prints the index, the coordinates and a newline
display_destinations(ListOfMoves, PieceChoice, Index) :- 
    nth1(PieceChoice, ListOfMoves, (_, _, _, ValidMoves)),
    display_destinations(ValidMoves, Index).

display_destinations([], _).
display_destinations([(Row, Col)|Rest], Index) :- 
    write(Index), write('. ('), write(Row), write(','), write(Col), write(')'), nl,
    NextIndex is Index + 1,
    display_destinations(Rest, NextIndex).