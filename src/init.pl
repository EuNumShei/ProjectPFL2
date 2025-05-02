:- module(init, [initial_state/2, initialize_board/2, play_again/1]).
:- use_module(main, [initial_menu/0, board_size_menu/0]).
:- use_module(game, [game_loop/1]).

% Set up initial game state
% This predicate initializes the game state with the given configuration, as well as setting the CurrentPlayer as white and the score as 0-0
% It also calls initialize_board in order to set up the game board
initial_state(config(_, Player1, Player2, BoardSize), state(Player1, Player2, Board, w, [0,0])) :- 
    write('Player 1: '), write(Player1), write(' Player 2: '), write(Player2), nl,
    initialize_board(BoardSize, Board).

% Initialize the game board
% This predicate initializes the game board with the given size
% This case is specific for a 8x8 board
initialize_board(8, Board) :- 
    Board = [
        [[], [], [], [], [], [], [], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [], [], [], [], [], [], []]
    ].

% This case is specific for a 10x10 board
initialize_board(10, Board) :- 
    Board = [
        [[], [], [], [], [], [], [], [], [], []],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], [], [piece(w,1)], []],
        [[], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)], [], [piece(b,1)]],
        [[], [], [], [], [], [], [], [], [], []]
    ].


% This predicate is responsible for the menu that appears when the game ends
% It asks the player if they want to play again, and handles the choice accordingly in handle_play_again_choice
play_again(InitialState) :- 
    write('Do you want to play again? (y/n): '),
    read(Choice),
    handle_play_again_choice(Choice, InitialState).

% Handle the choice of playing again
% If the player chooses y, it goes to board_size_menu to start a new game
handle_play_again_choice(Choice, _) :-
    Choice = 'y',
    main:board_size_menu.

% If the player chooses n, it thanks the player for playing and goes back to the initial menu
handle_play_again_choice(Choice, _) :-
    Choice = 'n',
    write('Thanks for playing!'), nl,
    main:initial_menu.

% If the player chooses an invalid option, it asks the player to enter y or n again in play_again
handle_play_again_choice(_, InitialState) :-
    write('Invalid choice. Please enter y or n.'), nl,
    play_again(InitialState).
