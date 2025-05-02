# Byte Game Implementation
## Group Information
- Group: T14_BYTE_7
  - up202208957 - Rafael Cunha (50%)
  - up202204875 - Guilherme Teixeira (50%)
 
Project Grade: 14.4

### Detailed Group Member Participation
- Both group members contributed actively to all phases of the project. Rafael primarily focused on the logic and development of the AI bots, while Guilherme concentrated on the menu flow and optimizing the game's algorithms. The implementation of game rules was approached using Pair Programming, allowing us to collaborate simultaneously. Additionally, both members engaged in extensive debugging.


## Installation and Execution
### Prerequisites
- SICStus Prolog 4.9
- Windows or Linux

### Running the Game
1. Linux:
   ```bash
   ./sicstus
   ?- consult('<PathToProjectFolder>/main.pl').
   ?- play.
   ```

2. Windows:
   - Open SICStus Prolog IDE
   - In SICStus, Consult -> Go to Project Folder -> Select file 'main.pl'
   - In the interpreter, type: `play.`

## Game Description
Byte is a strategic board game played on a checkerboard, invented by Mark Steere in 2005. The game involves:
- Players move checkers to form stacks of up to 8 pieces
- When a stack reaches 8 pieces, it's removed and awarded to the player owning the top piece
- Players must always move closer to the closest stacks in the board
- Players must always move pieces to a higher altitude, unless the piece's altitude is 1
- Victory is achieved by winning the majority of completed stacks (2/3 in 8x8, 3/5 in 10x10)

Sources:
- Official rules: [Mark Steere Games - Byte](http://www.marksteeregames.com/Byte_rules.pdf)

## Game Extensions
1. Variable Board Size:
   - Implemented both 8x8 (Standard) and 10x10 (International) variants, adapted win conditions (2/3 stacks for 8x8, 3/5 for 10x10)

### 2. AI Difficulty Levels  

- **Easy**: The AI selects moves randomly from the set of all valid moves, with no strategic considerations.  

- **Hard**: The AI employs a **Greedy Algorithm**, with the following decision-making approach:  
  - **Offensive Strategy**: Prioritizes moves that result in a new stack for itself, increasing its score.  
  - **Defensive Strategy**: Avoids moves that would create a new stack for the opponent, preventing them from scoring.
  - **Default**: Chooses a random valid move if no immediate impactful moves are available.  


3. Game Modes:
   - Human vs Human
   - Human vs Computer (Human plays white checkers)
   - Computer vs Human (Human plays black checkers)
   - Computer vs Computer

## Game Logic Implementation
### Game Configuration Representation
```prolog
config(GameType, Player1, Player2, BoardSize)
```
- GameType: hh (human-human), hc (human-computer), ch (computer-human), cc (computer-computer)
- PlayerLevel: 0 (human), 1 (easy AI), 2 (hard AI)
- BoardSize: 8 or 10

The player-chosen configuration is then used to set an initial game state, as follows:
```prolog
initial_state(config(_, Player1, Player2, BoardSize), state(Player1, Player2, Board, w, [0,0])) :- 
    write('Player 1: '), write(Player1), write(' Player 2: '), write(Player2), nl,
    initialize_board(BoardSize, Board).
````

### Internal Game State Representation  

```prolog
state(Player1, Player2, Board, CurrentPlayer, [BlackWins, WhiteWins])
```  

- **Player1** and **Player2**: Represent a Human or an AI player.  
- **Board**: A list of lists containing stacks (also lists), representing the checkerboard.  
  - **Stack representation**: `[piece(Color, Height), ...]`.  
  - Example: `piece(b,1)` represents a black piece at height 1.  
- **CurrentPlayer**: Indicates the player currently taking their turn, represented by their color (`b` for Black, `w` for White).  
- **BlackWins, WhiteWins**: The scores of Black and White players, respectively, indicating the number of stacks won by each player.  

---

#### Initial Game State - Example and Explanation  

```prolog
state(2, 1, Board, w, [0, 0])
```  
- **Players**:  
  - Player1 (`2`): Hard AI bot.  
  - Player2 (`1`): Easy AI bot.
  - Althought not represented here, `0` indicates a human player
- **Board**: The board is in its starting configuration.  
- **CurrentPlayer**: White (`w`) begins the game.
- **Scores**: Neither player has scored yet (`[0, 0]`).  

This represents the game state at the very beginning, where both players are ready to play, and no stacks have been won yet.  

---

#### Intermediate Game State - Example and Explanation  

```prolog
state(0, 2, Board, b, [0, 2])
```  
- **Players**:  
  - Player1 (`0`): A human player.  
  - Player2 (`2`): A hard AI bot.  
- **Board**: The board reflects some gameplay progress.
- **CurrentPlayer**: Black (`b`) is about to make a move.  
- **Scores**: White has won 2 stacks, while Black has not scored yet (`[1, 2]`).  

This represents a middle phase in a 10x10 board game where White is leading with two stacks won, and Black is trying to catch up.  

---

#### Endgame State - Example and Explanation  

```prolog
state(1, 0, Board, w, [1, 3])
```  
- **Players**:  
  - Player1 (`1`): An easy AI bot.  
  - Player2 (`0`): A human player.  
- **Board**: The board is in a state where only a few moves are left, and critical stacks may determine the winner.  
- **CurrentPlayer**: White (`w`) is taking their turn.  
- **Scores**: Black has won 1 stack, and White has won 3 stacks (`[1, 3]`).  

This represents the end of a game where White has won for a game played in a 10x10 board.

### Move Representation
To represent a move, we use the source and destination board locations, as well as the piece or stack being moved. Internally, moves are represented as a tuple:

`(SourceRow, SourceCol, Height, DestRow, DestCol)`

Each element in this tuple is defined as follows:
- **SourceRow** and **SourceCol**: Coordinates of the piece or stack's current location on the board.
- **Height**: Current height of the piece to move.
- **DestRow** and **DestCol**: Coordinates of the target location on the board.

### How Moves Are Used
1. **Validation**: Moves are validated using the `valid_moves/2` predicate, which generates all legal moves for the current game state.

2. **Application**: The `apply_move/3` predicate updates the game state by executing a move. This involves:
   - Removing the moved pieces from the source stack.
   - Adjusting the heights of the pieces being moved.
   - Adding these pieces to the destination stack.
   - Checking if the destination stack's height reaches a winning condition (e.g., height of 8).

3. **Execution**: The `move/3` predicate combines validation and application, ensuring a move is legal before modifying the game state.

### Integration in `move/3`
The `move/3` predicate ensures:
- **Validation**: The proposed move is checked against the list of valid moves.
- **State Update**: The game state is updated using `apply_move/3`.
- **Post-Move Adjustments**: Winning conditions and stack updates are recalculated.

### Code
````prolog
move(State, Move, NewState) :-
    apply_move(State, Move, TempState),
    update_game_state(TempState, NewState).
````

### Supporting Predicates
- **`valid_moves/2`**: Generates legal moves based on the game state.
- **`update_stacks_won/5`**: Updates the score when a stack reaches the winning height.
- **`check_moves_empty/2`**: Determines if there are no valid moves, allowing for a turn skip.

### Usage by Players and Bots
- **Human Players**: Input moves interactively, with validation providing feedback.
- **AI Players**: Bots use predefined strategies (e.g., random or heuristic-based) to select from valid moves.

### User Interaction
- Menu-driven interface with clear options
- Move selection:
  1. Choose source piece from valid options
  2. Select destination from available moves
  3. Input validation with error handling, any invalid input will cause the system to ask for input again
- Visual board representation with stack heights

## Conclusions
### Achievements
- Successfully implemented game rules with flexible board sizes (8 and 10), robust move validation, and two AI difficulty levels.

### Known Limitations
- Rare but existent delays in move-finding, basic AI strategy, and limited undo/redo functionality.

### Future Improvements
- Possible improvements include optimizing move-finding algorithms, integrating deeper AI strategies with minimax, and adding game state saving/loading capabilities.

## Bibliography
1. Mark Steere Games. (2005). Byte Rules. Retrieved from marksteeregames.com
2. SICStus Prolog Documentation (4.9)

## AI Tools Used
- Github Co-Pilot (GPT 4o): Assisted in debugging Prolog syntax (e.g., placing debug prints and detecting small issues), optimizing move validation algorithms, and structuring README documentation.
