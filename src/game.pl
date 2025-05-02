:- module(game, [game_loop/1, get_move/2, apply_move/3, switch_player/2, valid_moves/2, move/3, value/3]).

:- use_module(init).
:- use_module(display).
:- use_module(utils).
:- use_module(library(lists)).

% Game loop
% This is the main predicate of our game, where all predicates in this module are directly/indirectly called
% It is responsible for controlling the flow of the game, including verifying if the game is over, and ending it if it is the case, handle the piece movement during a given turn and switch turns
% The predicate starts by displaying our game, including our board and current score and value for each player
% Then, it checks if the game is over using check_game_over, where if it is a winner is announced and the player is given the choice to play again
% If the game is not over, the predicate gets the move from the current player using get_move, and then handles the move using handle_move, where if the move is (-1, -1, -1, -1, -1) (Special Move we designed specifically for when there are no moves) the turn is changed, storing changes in NextState
% Finally, game_loop is called to this NextState, advacing the game to the next turn
game_loop(State) :- 
    display_game(State),
    check_game_over(State).

% This predicate handles the case where the game is over, as well as progress the game correctly when it is not
% Uses game_over to check if the game is over
% If game_over successfully returns any of its cases, announce_winner is called to display the winner, followed by play_again, which gives the user the option to play again or go to the initial menu
check_game_over(State) :- game_over(State, Winner), 
    announce_winner(State, Winner), 
    play_again(State).

% If game_over fails, it means that another turn must occur, so get_move is called so that the player can choose what move to make next, move which is actually performed by handle_move
check_game_over(State) :- get_move(State, Move),
    handle_move(State, Move).

% This predicate deals with all of the steps of executing a selected move
% If Move is (-1,-1,-1,-1,-1) (Meaning there are no valid moves), the turn is skipped to next player using switch_player and the game advances to the next turn by calling game_loop with the updated NextState
handle_move(State, (-1, -1, -1, -1, -1)) :- 
    switch_player(State, NextState),
    game_loop(NextState).

% In any other case, move/3 applies the selected move, and once again switch_player switches the turn to the next player, and game_loop advances the game to this NextState
handle_move(State, Move) :- 
    move(State, Move, NewState),
    switch_player(NewState, NextState),
    game_loop(NextState).

% Checks if the game is over and identifies the winner
% If the length of the board is 8 and black has won 2 stacks, black is declared the winner
game_over(state(_, _, Board, _, [BlackWins, _]), Winner) :- 
    length(Board, 8),
    BlackWins >= 2,
    Winner = b.
% If the length of the board is 8 and white has won 2 stacks, white is declared the winner
game_over(state(_, _, Board, _, [_, WhiteWins]), Winner) :- 
    length(Board, 8),
    WhiteWins >= 2,
    Winner = w.
% If the length of the board is 10 and black has won 3 stacks, black is declared the winner
game_over(state(_, _, Board, _, [BlackWins, _]), Winner) :- 
    length(Board, 10),
    BlackWins >= 3,
    Winner = b.
% If the length of the board is 10 and white has won 3 stacks, white is declared the winner
game_over(state(_, _, Board, _, [_, WhiteWins]), Winner) :- 
    length(Board, 10),
    WhiteWins >= 3,
    Winner = w.

% This predicate simply announces the winner when the game is over
% If the length of the board is 8, black has won 2 stacks and the winner is black, the message 'Black wins!' is written, declaring black the winner
announce_winner(state(_, _, Board, _, [BlackWins, _]), b) :- 
    length(Board, 8),
    BlackWins >= 2,
    write('Black wins!'), nl.
% If the length of the board is 8, white has won 2 stacks and the winner is white, the message 'White wins!' is written, declaring white the winner
announce_winner(state(_, _, Board, _, [_, WhiteWins]), w) :- 
    length(Board, 8),
    WhiteWins >= 2,
    write('White wins!'), nl.
% If the length of the board is 10, black has won 3 stacks and the winner is black, the message 'Black wins!' is written, declaring black the winner
announce_winner(state(_, _, Board, _, [BlackWins, _]), b) :- 
    length(Board, 10),
    BlackWins >= 3,
    write('Black wins!'), nl.
% If the length of the board is 10, white has won 3 stacks and the winner is white, the message 'White wins!' is written, declaring white the winner
announce_winner(state(_, _, Board, _, [_, WhiteWins]), w) :- 
    length(Board, 10),
    WhiteWins >= 3,
    write('White wins!'), nl.

% This predicate is responsible for giving the player the option of which piece to move and to where, as well as recording that choice so that move can execute it
% player_type is a predicate that determines the type of player (human or bot) and its level, providing it to choose_move which then invokes different types of move predicates depending on the type of player
get_move(state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins]), Move) :- 
    player_type(CurrentPlayer, Player1, Player2, Level),
    choose_move(state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins]), Level, Move).

% This predicate is responsible for determining the type
% If the current player is white, the predicate returns the value of Player1
player_type(w, Player1, _, Player1).

% If the current player is black, the predicate returns the value of Player2
player_type(b, _, Player2, Player2).

% This predicate is responsible for dealing with the moves of different types of players
% It simply sends the state and move to a predicate adapted to their level (human_move for 0(Human), easy_bot_move for 1(Easy Bot) and hard_bot_move for 2(Hard Bot))
choose_move(State, 0, Move) :- human_move(State, Move).
choose_move(State, 1, Move) :- easy_bot_move(State, Move).
choose_move(State, 2, Move) :- hard_bot_move(State, Move).

% Easy bot move
% This is the predicate responsible for the movement of the easy bot 
% It starts by getting the list of valid moves for every piece of the player using valid_moves
% Then, it checks if the list of moves is empty, and if not continues the flow of the predicate
easy_bot_move(state(Player1, Player2, Board, CurrentPlayer, _), (SourceRow, SourceCol, Height, DestRow, DestCol)) :- 
    valid_moves(state(Player1, Player2, Board, CurrentPlayer, _), ListOfMoves), nl,
    check_moves_empty_easy_bot(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol)).


% Check if the list of moves is empty
% If it is, the move is skipped and the function is called again
% If it is not, a random move is selected from the list of valid moves
% (-1, -1, -1, -1, -1) is our placeholder for when there are no valid moves
% Helper predicate of easy_bot_move
% Check if the list of moves is empty using all_moves_empty
% If it is, the move is atributed the value (-1,-1,-1,-1,-1) which is recognized in handle_move as having no moves
check_moves_empty_easy_bot(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol)) :- all_moves_empty(ListOfMoves),
    write('Move skipped due to lack of valid moves'), nl,
    SourceRow is -1, SourceCol is -1, Height is -1, DestRow is -1, DestCol is -1.

% If not, select_valid_move is called, progressing the flow of easy_bot_move
check_moves_empty_easy_bot(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol)) :- select_valid_move(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol)).

% Selects a random move for the easy bot
% Uses my random member to find a random piece to be moved, and if that piece has valid moves my_random_member is used again to find a random destination
% If the list of moves is empty, the function fails
% If the list of moves is not empty, a random move is selected from the list of valid moves
select_valid_move(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol)) :-
    my_random_member((SourceRow, SourceCol, Height, ValidMoves), ListOfMoves),
    ValidMoves \= [],
    write('Selected piece: '), write((SourceRow, SourceCol, Height)), nl,
    my_random_member((DestRow, DestCol), ValidMoves),
    write('Selected destination: '), write((DestRow, DestCol)), nl, nl.

% Hard bot move
% This predicate is responsible for the hard bot move,
% where it gathers the valid moves for the current player and
% then selects the best move from the list of valid moves
% The best move is selected based on the value of the game state after the move
% The value of the game state is calculated based on the number of stacks won by the player
% The bot will try to maximize the number of stacks won
% If the bot cannot find a move that increases the number of stacks won, it will try to minimize the number of stacks won by the opponent
% If no moves change the game, the bot will select a random move from the list of valid moves
hard_bot_move(State, Move) :-
    write('Hard bot going to move'), nl,
    valid_moves(State, ListOfMoves), nl,
    check_moves_empty_hard_bot(ListOfMoves, Move, State).

% Check if the list of moves is empty
% If it is, the move is skipped
% If it is not, the best move is selected from the list of valid moves
% (-1, -1, -1, -1, -1) is our placeholder for when there are no valid moves
check_moves_empty_hard_bot(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), _) :- all_moves_empty(ListOfMoves),
    write('Move skipped due to lack of valid moves'), nl, nl,
    SourceRow is -1, SourceCol is -1, Height is -1, DestRow is -1, DestCol is -1.

% if the list of moves is not empty, but there are empty moves, filter them out
% then transform the Source-Destination lists into actual moves and find the best move
check_moves_empty_hard_bot(ListOfMoves, Move, State) :- filter_empty_moves(ListOfMoves, FilteredMoves),
    transform_moves(FilteredMoves, TransformedMoves),
    find_best_move(State, TransformedMoves, Move).

% Hard bot move
% Predicate to transform the filtered moves into a list of sources and destinations
% This is necessary to be able to evaluate the best move based on the value of the game state after the move
transform_moves([], []).
transform_moves([(SrcX, SrcY, Value, Destinations) | Rest], TransformedMoves) :-
    transform_single_move(SrcX, SrcY, Value, Destinations, TransformedSingleMove),
    transform_moves(Rest, TransformedRestMoves),
    append(TransformedSingleMove, TransformedRestMoves, TransformedMoves).

% Helper predicate to transform a single move with multiple destinations
transform_single_move(_, _, _, [], []).
transform_single_move(SrcX, SrcY, Value, [(DestX, DestY) | RestDestinations], [(SrcX, SrcY, Value, DestX, DestY) | TransformedRestDestinations]) :-
    transform_single_move(SrcX, SrcY, Value, RestDestinations, TransformedRestDestinations).

% Iterate through the list of moves and apply the functions
% to find the best move based on the value of the game state
find_best_move(State, Moves, BestMove) :-
    copy_term(Moves, OldMoves),
    find_best_move_helper(State, Moves, 0, none, TempBestMove, OldMoves),
    check_best_move(TempBestMove, BestMove, OldMoves).

% if no best move is found, select a random move from the list of valid moves
% Moves that would worsen the game state are only considered if no other moves are available
check_best_move(none, (SourceRow, SourceCol, Height, DestRow, DestCol), OldMoves) :- 
    my_random_member((SourceRow, SourceCol, Height, DestRow, DestCol), OldMoves),
    write('No best move found, selecting random move: '), write((SourceRow, SourceCol, Height)), write(' -> '), write((DestRow, DestCol)), nl, nl.

% if a best move is found, select it
% if a best move is found, select it
check_best_move(TempBestMove, (SourceRow, SourceCol, Height, DestRow, DestCol), _) :- (SourceRow, SourceCol, Height, DestRow, DestCol) = TempBestMove,
    write('Best move found: '), write((SourceRow, SourceCol, Height)), write(' -> '), write((DestRow, DestCol)), nl, nl.

% Helper predicate to find the best move
% Iterate through the list of moves and apply the functions
% to find the best move based on the value of the game state
find_best_move_helper(_, [], _, BestMove, BestMove, _) :-
    write('No more moves to evaluate'), nl.
find_best_move_helper(State, [(SrcX, SrcY, Value, DestX, DestY) | RestMoves], BestValue, CurrentBestMove, BestMove, OldMoves) :-
    simulate_move(State, (SrcX, SrcY, Value, DestX, DestY), MoveValue),
    check_move_value(MoveValue, State, [(SrcX, SrcY, Value, DestX, DestY) | RestMoves], BestValue, CurrentBestMove, BestMove, OldMoves).

% Helper predicate to check the value of a move
% If the value is worse than 0, the move is removed from the list of moves
check_move_value(MoveValue, State, [_ | RestMoves], BestValue, CurrentBestMove, BestMove, OldMoves) :- MoveValue < 0,
    OldMoves = RestMoves,
    find_best_move_helper(State, RestMoves, BestValue, CurrentBestMove, BestMove, OldMoves).

% if the value is better than the current best value, the move is selected as the best move
% and the value is updated
% if the value is better than the current best value, the move is selected as the best move
% and the value is updated
check_move_value(MoveValue, _, [(SrcX, SrcY, Value, DestX, DestY) | _], BestValue, _, BestMove, _) :- MoveValue > BestValue,
    BestMove = (SrcX, SrcY, Value, DestX, DestY).

% if the value is the same as the current best value, the move is ignored
% and the function is called again with the next move
% but the move is not removed from the list of moves to evaluate if no better moves are found
check_move_value(_, State, [_ | RestMoves], BestValue, CurrentBestMove, BestMove, OldMoves) :- NewBestValue = BestValue,
    NewBestMove = CurrentBestMove,
    find_best_move_helper(State, RestMoves, NewBestValue, NewBestMove, BestMove, OldMoves).

% Simulate a move and calculate the value of the game state after the move
% Creates a copy of the state, applies the move to the copy and calculates the value of the game state after the move
% Simulate a move and calculate the value of the game state after the move
% Creates a copy of the state, applies the move to the copy and calculates the value of the game state after the move
simulate_move(State, (SrcX, SrcY, Value, DestX, DestY), MoveValue) :-
    copy_state(State, TempState),
    move(TempState, (SrcX, SrcY, Value, DestX, DestY), state(Player1, Player2, Board, CurrentPlayer, StacksWon)),
    simulate_value(TempState, state(Player1, Player2, Board, CurrentPlayer, StacksWon), CurrentPlayer, MoveValue).

% Calculates the value of the game state after the move
% this case is for partically the Black player, where the value is calculated based on the number of stacks won by the Black player
% Calculates the value of the game state after the move
% this case is for partically the Black player, where the value is calculated based on the number of stacks won by the Black player
simulate_value(state(_, _, _, _, [BlackWins, WhiteWins]), state(_, _, _, _, [NewBlackWins, NewWhiteWins]), b, Value) :-  
    Compare_White is NewWhiteWins - WhiteWins,
    Compare_Black is NewBlackWins - BlackWins,
    Value is Compare_Black - Compare_White.

% Calculates the value of the game state after the move
% this case is for partically the White player, where the value is calculated based on the number of stacks won by the White player
% Calculates the value of the game state after the move
% this case is for partically the White player, where the value is calculated based on the number of stacks won by the White player
simulate_value(state(_, _, _, _, [BlackWins, WhiteWins]), state(_, _, _, _, [NewBlackWins, NewWhiteWins]), w, Value) :- 
    Compare_White is NewWhiteWins - WhiteWins,
    Compare_Black is NewBlackWins - BlackWins,
    Value is Compare_White - Compare_Black.

% Predicate to copy the state
% Creates a copy of the state
% Predicate to copy the state
% Creates a copy of the state
copy_state(state(Player1, Player2, Board, CurrentPlayer, StacksWon), state(Player1Copy, Player2Copy, BoardCopy, CurrentPlayerCopy, StacksWonCopy)) :-
    copy_term(Player1, Player1Copy),
    copy_term(Player2, Player2Copy),
    copy_term(Board, BoardCopy),
    copy_term(CurrentPlayer, CurrentPlayerCopy),
    copy_term(StacksWon, StacksWonCopy).

% Predicate filter the empty moves
% Removes the moves that have no valid destinations
filter_empty_moves([], []).
filter_empty_moves([(_, _, _, []) | Rest], FilteredMoves) :-
    filter_empty_moves(Rest, FilteredMoves).
filter_empty_moves([(SourceRow, SourceCol, Height, ValidMoves) | Rest], [(SourceRow, SourceCol, Height, ValidMoves) | RestFilteredMoves]) :-
    ValidMoves \= [],
    filter_empty_moves(Rest, RestFilteredMoves).

% predicate responsible for handling the movement of a human player 
% It starts by getting the list of valid moves for every piece of the player using valid_moves
% Then, it checks if the list of moves is empty, and if not continues the flow of the predicate
human_move(state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins]), (SourceRow, SourceCol, Height, DestRow, DestCol)) :- 
    valid_moves(state(Player1, Player2, Board, CurrentPlayer, _), ListOfMoves), nl,
    check_moves_empty_human(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins])).

% Helper predicate of human_move
% Check if the list of moves is empty using all_moves_empty
% If it is, the move is atributed the value (-1,-1,-1,-1,-1) which is recognized in handle_move as having no moves
check_moves_empty_human(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), _) :- all_moves_empty(ListOfMoves),
    write('Move skipped due to lack of valid moves'), nl, nl,
    SourceRow is -1, SourceCol is -1, Height is -1, DestRow is -1, DestCol is -1.

% If not, the pieces of the player are displayed and the player is asked to choose a piece to move, which is then handled by handle_piece_choice
check_moves_empty_human(ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins])) :- write('Player '), write(CurrentPlayer), write(', choose a piece to move:'), nl,
    display_pieces(ListOfMoves, 1),
    read(PieceChoice),
    handle_piece_choice(PieceChoice, ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins])).

% predicate that verifies if the input is valid, and if it is  find_selected_move is called to find the selected move
handle_piece_choice(PieceChoice, ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), State) :- integer(PieceChoice),
    find_selected_move(PieceChoice, ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), State).

% If the input is invalid, the player is asked to choose a piece again, returning to human_move
handle_piece_choice(_, _, Move, State) :- write('Invalid input. Please enter an integer.'), nl,
    display_game(State),
    human_move(State, Move).

% predicate that fetches the move selected by the player
% Firstly it uses nth1 to get the PieceChoice-th piece from the list of moves, which is the desired piece
% Then it displays the valid destinations for that piece with display_destinations, and then choose_destination is called to handle the destination choice process 
find_selected_move(PieceChoice, ListOfMoves, (SourceRow, SourceCol, Height, DestRow, DestCol), State) :- 
    nth1(PieceChoice, ListOfMoves, (SourceRow, SourceCol, Height, ValidMoves)),
    choose_destination(State, (SourceRow, SourceCol, Height, DestRow, DestCol), ValidMoves, ListOfMoves, PieceChoice).

% If no PieceChoice-th piece is found in ListOfMoves the player is asked to choose a piece again, returning to human_move
find_selected_move(_, _, Move, State) :- write('Invalid piece choice. Please try again.'), nl,
    display_game(State),
    human_move(State, Move).

% This predicate is responsible for handling the destination choice process
% It starts by asking the player to choose a destination, and then handle_dest_choice is called to verify if the input is valid
% If that input is valid the flow of choose_destination is continued
choose_destination(State, (SourceRow, SourceCol, Height, DestRow, DestCol), ValidMoves, ListOfMoves, PieceChoice) :-
    write('Valid moves for the selected piece: '), nl,
    display_destinations(ListOfMoves, PieceChoice, 1),
    write('Enter the destination (row and column): '), nl,
    read(DestChoice),
    handle_dest_choice(DestChoice, State, (SourceRow, SourceCol, Height, DestRow, DestCol), ValidMoves, ListOfMoves, PieceChoice).

% predicate that verifies if the input is valid, and if it is  find_selected_dest is called to find the selected destination
handle_dest_choice(DestChoice, State, (SourceRow, SourceCol, Height, DestRow, DestCol), ValidMoves, ListOfMoves, PieceChoice) :- integer(DestChoice),
    find_selected_dest(DestChoice, State, (SourceRow, SourceCol, Height, DestRow, DestCol), ValidMoves, ListOfMoves, PieceChoice).

% If the input is invalid, the player is asked to choose a destination again, returning to choose_destination
handle_dest_choice(_, State, Move, ValidMoves, ListOfMoves, PieceChoice) :- write('Invalid input. Please enter an integer.'), nl,
    display_game(State),
    choose_destination(State, Move, ValidMoves, ListOfMoves, PieceChoice).

% predicate that fetches the destination selected by the player
% Firstly it uses nth1 to get the DestChoice-th destination from the list of valid moves, and the resultant (DestRow, DestCol) are returned to the calling predicate
find_selected_dest(DestChoice, _, (_, _, _, DestRow, DestCol), ValidMoves, _, _) :- 
nth1(DestChoice, ValidMoves, (DestRow, DestCol)), nl, nl.

% If no DestChoice-th destination is found in ValidMoves the player is asked to choose a destination again, returning to choose_destination
find_selected_dest(_, State, Move, ValidMoves, ListOfMoves, PieceChoice) :- write('Invalid destination choice. Please try again.'), nl,
    display_game(State),
    choose_destination(State, Move, ValidMoves, ListOfMoves, PieceChoice).

% Check if all elements in ListOfMoves have no valid moves
all_moves_empty([]).
all_moves_empty([(_, _, _, []) | Rest]) :- 
    all_moves_empty(Rest).

% Move validation and execution
% This predicate is responsible for executing a given move, as well as update the state of the game with the repercussions of that move
% It starts by using move_piece to execute the move on the board, and update the characteristics of the pieces if they changed, such as their height
% update_stacks_won is then called so that if a stack reached 8 pieces, the score is then updated given the winner of that stack, as well as the board is updated to not keep the stack anymore
move(state(Player1, Player2, Board, CurrentPlayer, StacksWon), (SourceRow, SourceCol, Height, DestRow, DestCol), state(Player1, Player2, NewBoard, CurrentPlayer, NewStacksWon)) :-
    move_piece(Board, SourceRow, SourceCol, Height, DestRow, DestCol, NewDestStack, TempBoard, DestRow, DestCol),
    update_stacks_won(NewDestStack, TempBoard, StacksWon, NewStacksWon, NewBoard, DestRow, DestCol).

% Move a piece on the board, including all pieces above it
% This predicate starts by fetching the stack of the source piece (SourceStack) and the stack of the destination piece (DestStack), and then the source piece from the SourceStack
% Then, split_stack is called to separate the pieces from SourceStack into pieces that will remain in that stack (RemainingStack) and the pieces that will be moved (PiecesToMove)
% Afterwards, the height of the new DestStack is calculated, and is given to update_pieces_height to update the height of the pieces of PiecesToMove
% After updating the pieces of PiecesToMove, the new DestStack is created by appending the updated pieces to the old DestStack
% Finally, we have a series of replaces that update the SourceStack and the DestStack
move_piece(Board, SourceRow, SourceCol, Height, DestRow, DestCol, NewDestStack, NewBoard, DestRow, DestCol) :- 
    nth1(SourceRow, Board, SourceRowList),
    nth1(SourceCol, SourceRowList, SourceStack),
    nth1(DestRow, Board, DestRowList),
    nth1(DestCol, DestRowList, DestStack),
    nth1(Height, SourceStack, piece(Player, Height)),
    split_stack(SourceStack, piece(Player, Height), PiecesToMove, RemainingStack),
    length(DestStack, DestHeight),
    update_pieces_height(PiecesToMove, DestHeight, UpdatedPieces, 1),
    append(DestStack, UpdatedPieces, NewDestStack),
    replace(DestRowList, DestCol, NewDestStack, NewDestRowList),
    replace(Board, DestRow, NewDestRowList, TempBoard),
    replace(SourceRowList, SourceCol, RemainingStack, NewSourceRowList),
    replace(TempBoard, SourceRow, NewSourceRowList, NewBoard).

% This predicate is responsible for separating the pieces that will be moved from the pieces that will remain in the stack
% When the head of the list is the piece to be moved, the predicate adds it and all pieces forward to PiecestoMove and ends the predicate
% Until then, all pieces are added to RemainingStack
split_stack([piece(Player, Height)|Rest], piece(Player, Height), [piece(Player, Height)|Rest], []) :- !.
split_stack([H|T], piece(Player, Height), PiecesToMove, [H|RemainingStack]) :-
    split_stack(T, piece(Player, Height), PiecesToMove, RemainingStack).

% Update the heights of the pieces to be moved
% This predicate starts by updating the height of the first piece, and then recursively updates the height of the rest of the pieces, by changing the values of index and DestHeight
% The predicate ends when there are no more pieces to update
update_pieces_height([], _, [], _).
update_pieces_height([piece(Player, _)|Rest], DestHeight, [piece(Player, NewHeight)|UpdatedRest], Index) :-
    Index1 is Index + 1,
    NewHeight is Index + DestHeight,
    update_pieces_height(Rest, DestHeight, UpdatedRest, Index1).

% Update the stacks won
% This predicate is responsible for updating the score of the game, as well as the board, when a stack is won
% It calls update_wins_if_needed, giving the height of the stack as an argument
update_stacks_won(DestStack, Board, [BlackWins, WhiteWins], [NewBlackWins, NewWhiteWins], NewBoard, DestRow, DestCol) :- 
    length(DestStack, NewHeight),
    update_wins_if_needed(NewHeight, DestStack, BlackWins, WhiteWins, NewBlackWins, NewWhiteWins, Board, NewBoard, DestRow, DestCol).

% Update the wins if the stack height is 8
% If the height of the stack is 8, the winner of the stack is obtained with get_stack_winner, and update_wins is used to add a point to the winner of the stack 
% Then, we find the square of the finished stack and replace it with an empty list, so that it is no longer considered in the game
update_wins_if_needed(8, DestStack, BlackWins, WhiteWins, NewBlackWins, NewWhiteWins, Board, NewBoard, DestRow, DestCol) :- 
    get_stack_winner(DestStack, Winner),
    write('Stack: '), write(DestStack), write(' Winner: '), write(Winner), nl,
    update_wins(Winner, BlackWins, WhiteWins, NewBlackWins, NewWhiteWins),
    nth1(DestRow, Board, RowList),
    replace(RowList, DestCol, [], NewRowList),
    replace(Board, DestRow, NewRowList, NewBoard).

% If the stack height is not 8, the board is not updated
update_wins_if_needed(Height, _, BlackWins, WhiteWins, BlackWins, WhiteWins, Board, NewBoard, _, _) :- 
    Height \= 8,
    NewBoard = Board.

% Determine the winner of a stack (the owner of the highest piece)
get_stack_winner(Stack, Winner) :- 
    last(Stack, piece(Winner, _)).

% Update the wins based on the winner
% If the winner is black, BlackWins is incremented by 1
update_wins(b, BlackWins, WhiteWins, NewBlackWins, WhiteWins) :- 
    NewBlackWins is BlackWins + 1.

% If the winner is white, WhiteWins is incremented by 1
update_wins(w, BlackWins, WhiteWins, BlackWins, NewWhiteWins) :- 
    NewWhiteWins is WhiteWins + 1.

% If there is no winner nothing occurs
update_wins(_, BlackWins, WhiteWins, BlackWins, WhiteWins). 

% Switch the current player
% This predicate simply replaces the atribute CurrentPlayer of the state with the other player
switch_player(state(Player1, Player2, Board, b, StacksWon), state(Player1, Player2, Board, w, StacksWon)).
switch_player(state(Player1, Player2, Board, w, StacksWon), state(Player1, Player2, Board, b, StacksWon)).

% Predicate to get valid moves for a player
% This predicate is responsible for getting all the valid moves for a given player
% It starts by getting all the pieces of the player in the board using player_pieces_in_board_coords
% Then, it uses valid_moves_helper to get the valid moves for each piece, and append them to a list of valid moves
valid_moves(state(_, _, Board, Player, _), ListOfMoves) :- 
    player_pieces_in_board_coords(Board, Player, Pieces),
    valid_moves_helper(Board, Pieces, [], ListOfMoves).

% Helper of Valid Moves
% This predicate starts by calling valid_moves_for_piece_helper for the head of Pieces
% Then, it simply adds the result to the accumulator and prints the ValidMoves for the piece
% The predicate does this for all pieces
valid_moves_helper(Board, [(Row, Col, Height)|Rest], Acc, ListOfMoves) :- 
    valid_moves_for_piece_helper(Board, Row, Col, Height, ValidMoves),
    write('Valid Moves for Piece: '), write((Row, Col, Height)), write(' - '), write(ValidMoves),
    append(Acc, [(Row, Col, Height, ValidMoves)], NewAcc),
    valid_moves_helper(Board, Rest, NewAcc, ListOfMoves).

% The predicate ends when there are no more pieces
valid_moves_helper(_, [], Acc, Acc).

% Precompute the offsets and valid moves
offsets([(1,1), (-1,-1), (1,-1), (-1,1)]).

% This predicate is a helper of valid_moves which computes the valid moves for a single piece
% This function is responsible for calculating the valid moves for a given piece
% It calculates the closest pieces to the current piece and then calculates the valid moves 
% The function uses the Chebyshev distance to calculate the distance between the current piece and the closest pieces
% It then calculates the distance between the current piece and the possible moves, and if the distance is less than the distance to the closest piece, the move is considered valid
% It also checks if the move is valid based on the altitude constraint
% The altitude constraint is that the height of the destination stack must be greater than the height of the current stack
% unless the destination stack is empty and the height of the current stack is 1
% It also limits the height of the destination stack to 8
% Translation for the findall to English: 
valid_moves_for_piece_helper(Board, Row, Col, Height, ValidMoves) :- 
    closest_pieces(Board, (Row, Col), ClosestPieces),
    nth1(Row, Board, BoardRow), % Get the row at the current position
    nth1(Col, BoardRow, CurrentStack), % Get the stack at the current position
    length(CurrentStack, CurrentStackHeight), % Get the height of the current stack
    length(Board, BoardSize),
    PiecesAbove is CurrentStackHeight - Height, % Calculate the number of pieces above the current piece
    
    findall((NewRow, NewCol),
            (member((ClosestRow, ClosestCol), ClosestPieces), % For each closest piece
             chebyshev_distance((Row, Col), (ClosestRow, ClosestCol), CurrentDistance), % Calculates the distance to the piece
             offsets(Offsets), % Limits the possible moves to the 4 diagonal directions
             member((RowOffset, ColOffset), Offsets), % Verifies that the Offset is inside of the board limits
             NewRow is Row + RowOffset, % Calculates the new row
             NewCol is Col + ColOffset, % Calculates the new column
             valid_coord(BoardSize, NewRow, NewCol), % Verifies that the new position is inside of the board limits
             nth1(NewRow, Board, NewBoardRow), % Gets the row at the new position
             nth1(NewCol, NewBoardRow, NewStack), % Gets the stack at the new position
             length(NewStack, NewHeight), % Gets the height of the new stack
             (NewHeight + 1 + PiecesAbove) < 9, % Ensures the new height does not exceed 9 with the new piece and the pieces above it
             valid_altitude_move(Height, NewHeight, NewStack), % Ensures the altitude constraint is met
             chebyshev_distance((NewRow, NewCol), (ClosestRow, ClosestCol), NewDistance), % Gets the distance to the closest pieces if we move to the new position
                NewDistance < CurrentDistance), % Ensures the new distance is less than the current distance
            ValidMovesList), % Collect all valid moves
    remove_duplicates(ValidMovesList, ValidMoves), nl. % Remove duplicate moves

% This predicate forces the constraint of the game where a piece can only be moved to a stack with a height greater than its own
% Allow move if destination stack is empty
valid_altitude_move(1, _, []) :- !. 

% Allow move if destination height is higher than the source height
valid_altitude_move(CurrentHeight, DestHeight, _) :-
    DestHeight >= CurrentHeight.

% Calculate the value of the game state for a given player
% If the player is black, the value is the difference between the number of stacks won by black and white
value(state(_, _, _, _, [BlackWins, WhiteWins]), b, Value) :-  
    Value is BlackWins - WhiteWins.

% If the player is white, the value is the difference between the number of stacks won by white and black
value(state(_, _, _, _, [BlackWins, WhiteWins]), w, Value) :- 
    Value is WhiteWins - BlackWins.