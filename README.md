# Breakout 2.5D

A **Breakout**-style game built in **Godot 4.6**. Gameplay runs on a 2D playfield (paddle, bricks, walls), while the ball is rendered as a **3D sphere** in a viewport and rolls to match its 2D motion—hence the “2.5D” look.

## How to play

- **Move the paddle:** **A** / **D** or **Left** / **Right** arrow keys.
- **Launch the ball:** **Space** (the ball starts stuck to the paddle until you launch).
- **Goal:** Break all bricks. The HUD shows **lives**, **remaining bricks**, and a short control hint.
- **Losing a life:** If the ball falls into the death zone at the bottom, you lose a life; the ball returns to the paddle. At **0 lives**, the run ends.
- **Win:** Clear every brick.
- **After win or game over:** Press **R** to play again (full restart: lives and brick grid reset).

The paddle affects the ball’s angle when it hits—hitting toward the edges sends it more sideways than a center hit.

## How to run the game

1. Install **[Godot 4.6](https://godotengine.org/download)** (this project targets Godot **4.6** with the **GL Compatibility** renderer; **Jolt Physics** is used for 3D).

2. Open the project:
   - Launch the Godot editor and use **Import** / **Open** and choose this folder (the one containing `project.godot`), **or**
   - From a terminal (if `godot` is on your `PATH`):

     ```bash
     godot --path /path/to/breakout-2-5d
     ```

3. Run the game:
   - In the editor, press **F5** (run project) or click **Run Project**, **or**
   - From the command line:

     ```bash
     godot --path /path/to/breakout-2-5d
     ```

   The main scene is set in `project.godot` as the run scene, so the editor run button starts the game directly.

## Project layout (short)

- `main_scene.tscn` — entry scene.
- `scenes/game/` — level logic (bricks, lives, win/lose, input map setup).
- `scenes/player/` — paddle.
- `scenes/ball/` — ball physics and 3D ball visual.
- `scenes/brick/` — brick behavior.
