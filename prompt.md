You are an expert Godot developer. Your task is to implement a path selection mechanic in an existing Godot project.

Here is a summary of the project and the desired functionality:

**Project Overview:**

The game is a 3D endless runner where the player character, the "Angel," flies through space along a pre-defined but dynamically generated path of "orbs." The player's speed is a resource that needs to be managed by collecting these orbs.

**Core Gameplay Loop:**

1.  The player arrives at an "orb" (a `PathNode`).
2.  The game pauses the player's movement (`is_traveling = false`).
3.  The player is presented with one or more choices for the next orb to travel to. These choices are visualized as "beams" pointing to the neighboring orbs.
4.  The player uses "ui_left", "ui_right", or "ui_up" to select one of the paths. The selected path is highlighted.
5.  Once a path is selected, the player automatically travels along a rail (a `Path3D` curve) to the chosen orb.
6.  The cycle repeats.

**Key Scripts and Scenes:**

*   **`scenes/Angel.tscn` (script: `scripts/Angel.gd`):** This is the player character, a `CharacterBody3D`.
    *   It contains a `Path3D` node (`path_track`) and a `PathFollow3D` node (`path_follow`) to move along the generated path.
    *   It has a state machine controlled by the `is_traveling` boolean.
    *   It uses `@export var beam_scene: PackedScene` to instance the visual beams.
    *   It handles player input for path selection via `_handle_input_buffering()` which sets the `intended_lane_choice` variable.

*   **`scripts/PathNode.gd`:** This is an `Area3D` that serves as the base class for all nodes in the path (like orbs).
    *   It contains a `neighbors` array, which holds references to the `PathNode`s it is connected to.

*   **`scenes/Beam.tscn` (script: `scenes/beam.gd`):** A simple `Node3D` used to visualize the paths.
    *   It has a `show_path(start_point: Vector3, end_point: Vector3)` function that scales and rotates the beam to connect the two points.
    *   It has a `set_color(color: Color)` function to change the beam's color.

*   **`scripts/LevelGenerator.gd`:** This script procedurally generates the level by spawning chunks containing orbs and connecting their `neighbors`.

**Desired Functionality:**

The goal is to implement the visualization of the path choices. The `scripts/Angel.gd` file already has some of the logic for this, but the implementation is incomplete.

Here are the specific requirements:

1.  **In `scripts/Angel.gd`, modify the `_update_steering_beams()` function.**
    *   This function is called when the player is at a junction (`is_traveling == false`).
    *   It should first clear any existing beams using `_clear_steering_beams()`.
    *   Then, for each `neighbor` in the `current_orb.neighbors` array, it should:
        *   Instantiate a `beam_scene`.
        *   Add it as a child of the Angel.
        *   Call the beam's `show_path()` function to draw a line from the Angel's current position to the neighbor's position.
        *   Store the beam instance in the `spawned_beams` array.

2.  **Highlight the selected path.**
    *   Inside `_update_steering_beams()`, after getting the list of neighbors, determine which neighbor is currently selected based on the `intended_lane_choice` variable. You can use the existing `_pick_node_from_choice()` function for this.
    *   When instantiating the beams, use the beam's `set_color()` function to give it a default color (e.g., `Color.CYAN`).
    *   If a beam points to the *selected* neighbor, give it a different, highlighted color (e.g., `Color.GREEN`).

3.  **Clean up the beams.**
    *   The `_clear_steering_beams()` function should iterate through the `spawned_beams` array and `queue_free()` each beam.
    *   This function is already called when the player starts traveling, which is the correct behavior.

By implementing these changes, the player will be able to see the available paths at each junction and get clear visual feedback on their current selection before committing to a path.
