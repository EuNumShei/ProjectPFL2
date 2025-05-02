:- module(main, [play/0, initial_menu/0, handle_initial_choice/1, game_type_menu/1, handle_game_type_choice/2, difficulty_menu/2, handle_difficulty_choice/3, board_size_menu/0, handle_board_size_choice/1]).

:- use_module(library(lists)).
:- use_module(display).
:- use_module(game).
:- use_module(init).
:- use_module(utils).

% Game state representation:
% state(Board, CurrentPlayer, StacksWon)
% Board: List of lists representing stacks
% CurrentPlayer: b (black) or w (white)
% StacksWon: [BlackWins, WhiteWins]

% --- Main Game Predicates ---

% Main entry point
% This predicate is the beginning of the program, as mencioned in the README
% It introduces the player to the game, as well as use clear_screen to clean the terminal
% Finally, it calls the initial_menu predicate to start the game
play :- 
    clear_screen,
    write('Welcome to Byte!'), nl,
    write('----------------'), nl, nl,
    initial_menu.

% --- Menu Predicates ---

% Initial menu (Play/Exit)
% This predicate is the first menu that the player sees, giving him the choice of exiting the game or starting a new game
% After displaying the menu, it reads the player choice and calls the handle_initial_choice predicate to handle it
initial_menu :- 
    write('1. Play'), nl,
    write('2. Exit'), nl,
    write('Enter command: '),
    flush_output,
    read(Choice),
    handle_initial_choice(Choice).

% Handle initial menu choice
% This predicate handles the choice made by the player in the initial menu
% If the player chooses 1, it calls the board_size_menu predicate
handle_initial_choice(1) :- board_size_menu.

% If the player chooses 2, it writes a message thanking the player for playing and exits the game   
handle_initial_choice(2) :- 
    write('Thanks for playing!'), nl,
    flush_output.

% If the player chooses anything else, it writes a message asking the player to try again and calls the initial_menu predicate
handle_initial_choice(_) :- 
    write('Invalid command. Please try again.'), nl,
    flush_output,
    initial_menu.

% Board size menu
% This predicate is called when the player chooses to start a new game
% It asks the player to choose the board size (8x8 or 10x10) and calls the handle_board_size_choice predicate to handle the choice
board_size_menu :- 
    write('Select board size:'), nl,
    write('1. 8x8'), nl,
    write('2. 10x10'), nl,
    write('b. Back'), nl,
    write('Enter command: '),
    flush_output,
    read(Choice),
    handle_board_size_choice(Choice).

% Handle board size choice
% This predicate handles the choice made by the player in the board size menu
% If the player chooses 1, it calls the game_type_menu predicate with the board size 8
handle_board_size_choice(1) :- game_type_menu(8).

% If the player chooses 2, it calls the game_type_menu predicate with the board size 10
handle_board_size_choice(2) :- game_type_menu(10).

% If the player chooses b, it returns the user to the previous menu, the initial_menu predicate
handle_board_size_choice(b) :- initial_menu.

% If the player chooses anything else, it writes a message asking the player to try again and calls the board_size_menu predicate
handle_board_size_choice(_) :- 
    write('Invalid command. Please try again.'), nl,
    flush_output,
    board_size_menu.

% Game type menu
% This predicate is called after the player chooses the board size
% It asks the player to choose the game type (Human vs Human, Human vs PC (Human is White), PC vs Human (Human is Black), PC vs PC) and calls the handle_game_type_choice predicate to handle the choice
game_type_menu(BoardSize) :- 
    write('Select game type:'), nl,
    write('1. Human vs Human'), nl,
    write('2. Human vs PC'), nl,
    write('3. PC vs Human'), nl,
    write('4. PC vs PC'), nl,
    write('b. Back'), nl,
    write('Enter command: '),
    flush_output,
    read(Choice),
    handle_game_type_choice(Choice, BoardSize).

% Handle game type choice
% This predicate handles the choice made by the player in the game type menu
% If the player chooses 1, it calls the game_loop predicate with the initial state of a human vs human game
handle_game_type_choice(1, BoardSize) :- 
    initial_state(config(hh, 0, 0, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 2, it calls the difficulty_menu predicate with the context human_white
handle_game_type_choice(2, BoardSize) :- 
    write('Human is White, PC is Black'), nl,
    difficulty_menu(human_white, BoardSize).

% If the player chooses 3, it calls the difficulty_menu predicate with the context pc_white
handle_game_type_choice(3, BoardSize) :- 
    write('PC is White, Human is Black'), nl,
    difficulty_menu(pc_white, BoardSize).

% If the player chooses 4, it calls the difficulty_menu predicate with the context pc1
handle_game_type_choice(4, BoardSize) :- 
    write('Select difficulty for PC1:'), nl,
    difficulty_menu(pc1, BoardSize).

% If the player chooses b, it returns the user to the previous menu, the board_size_menu predicate
handle_game_type_choice(b, _) :- 
    board_size_menu.

% If the player chooses anything else, it writes a message asking the player to try again and calls the game_type_menu predicate
handle_game_type_choice(_, BoardSize) :- 
    write('Invalid command at game type. Please try again.'), nl,
    flush_output,
    game_type_menu(BoardSize).

% Difficulty menu
% This predicate is called after the player chooses a game type that involves PC(s)
% It asks the player to choose the difficulty of the PC(s) (Easy or Hard) and calls the handle_difficulty_choice predicate to handle the choice
difficulty_menu(Context, BoardSize) :- 
    write('Select difficulty:'), nl,
    write('1. Easy'), nl,
    write('2. Hard'), nl,
    write('b. Back'), nl,
    write('Enter command: '),
    flush_output,
    read(Choice),
    handle_difficulty_choice(Choice, Context, BoardSize).

% Handle difficulty choice
% This predicate handles the choice made by the player in the difficulty menu
% If the player chooses 1 and the context is human_white, it calls the game_loop predicate with the initial state of a game between a human and an easy PC
handle_difficulty_choice(1, human_white, BoardSize) :- 
    initial_state(config(hc, 0, 1, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 2 and the context is human_white, it calls the game_loop predicate with the initial state of a game between a human and a hard PC
handle_difficulty_choice(2, human_white, BoardSize) :- 
    initial_state(config(hc, 0, 2, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 1 and the context is pc_white, it calls the game_loop predicate with the initial state of a game between an easy PC and a human
handle_difficulty_choice(1, pc_white, BoardSize) :- 
    initial_state(config(ch, 1, 0, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 2 and the context is pc_white, it calls the game_loop predicate with the initial state of a game between a hard PC and a human
handle_difficulty_choice(2, pc_white, BoardSize) :- 
    initial_state(config(ch, 2, 0, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 1 and the context is pc1, it calls the difficulty_menu to select the difficulty of the second PC with the context of pc2_easy
handle_difficulty_choice(1, pc1, BoardSize) :- 
    write('Select difficulty for PC2:'), nl,
    difficulty_menu(pc2_easy, BoardSize).

% If the player chooses 2 and the context is pc1, it calls the difficulty_menu to select the difficulty of the second PC with the context of pc2_hard
handle_difficulty_choice(2, pc1, BoardSize) :- 
    write('Select difficulty for PC2:'), nl,
    difficulty_menu(pc2_hard, BoardSize).

% If the player chooses 1 and the context is pc2_easy, it calls the game_loop predicate with the initial state of a game between an easy PC and another easy PC
handle_difficulty_choice(1, pc2_easy, BoardSize) :- 
    initial_state(config(cc, 1, 1, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 2 and the context is pc2_easy, it calls the game_loop predicate with the initial state of a game between an easy PC and a hard PC
handle_difficulty_choice(2, pc2_easy, BoardSize) :- 
    initial_state(config(cc, 1, 2, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 1 and the context is pc2_hard, it calls the game_loop predicate with the initial state of a game between a hard PC and an easy PC
handle_difficulty_choice(1, pc2_hard, BoardSize) :- 
    initial_state(config(cc, 2, 1, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses 2 and the context is pc2_hard, it calls the game_loop predicate with the initial state of a game between a hard PC and another hard PC
handle_difficulty_choice(2, pc2_hard, BoardSize) :- 
    initial_state(config(cc, 2, 2, BoardSize), InitialState),
    game_loop(InitialState).

% If the player chooses b, it returns the user to the previous menu, the handle_game_type_choice predicate, which will make him select the difficulty of the first PC
handle_difficulty_choice(b, pc2_easy, BoardSize) :- 
    handle_game_type_choice(4, BoardSize).

% If the player chooses b, it returns the user to the previous menu, the handle_game_type_choice predicate, which will make him select the difficulty of the first PC
handle_difficulty_choice(b, pc2_hard, BoardSize) :-
    handle_game_type_choice(4, BoardSize).

% If the player chooses b with any other predicate, it returns the user to the previous menu, the game_type_menu predicate
handle_difficulty_choice(b, _, BoardSize) :- 
    game_type_menu(BoardSize).

% If the player chooses anything else, it writes a message asking the player to try again and calls the difficulty_menu predicate
handle_difficulty_choice(_, Context, BoardSize) :- 
    write('Invalid command. Please try again.'), nl,
    flush_output,
    difficulty_menu(Context, BoardSize).
