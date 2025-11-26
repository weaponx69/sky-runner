## Manages the spawning of different types of rocks in the game.
#
# This script holds references to various rock scenes and provides utility functions
# to spawn them either randomly at a specific position or at a calculated position along a path.
extends Node

## An array of `PackedScene`s for the different rock types that can be spawned.
const ROCK_SCENES = [
    preload("res://scenes/Rock.tscn"),
    preload("res://scenes/ObstacleRock.tscn")
]

## Called when the node enters the scene tree for the first time.
# Spawns a single random rock at the default position as an example.
func _ready():
    spawn_random_rock()

## Spawns a randomly selected rock from `ROCK_SCENES` at a given position.
# - `position`: The `Vector3` position where the rock will be spawned.
# Returns the instance of the spawned rock as a `Node3D`, or `null` if no rock scenes are available.
func spawn_random_rock(position: Vector3 = Vector3.ZERO) -> Node3D:
    if ROCK_SCENES.is_empty():
        push_error("No rock scenes available!")
        return null
    
    var random_scene = ROCK_SCENES.pick_random()
    var rock_instance = random_scene.instantiate()
    
    rock_instance.position = position
    add_child(rock_instance)
    
    return rock_instance

## Spawns a random rock at a specific distance and lane along the player's path.
# - `distance`: The forward distance from the origin to spawn the rock.
# - `lane`: The horizontal lane to spawn the rock in.
# Returns the instance of the spawned rock as a `Node3D`.
func spawn_rock_at_path(distance: float, lane: int = 0) -> Node3D:
    var lane_width = 3.0
    var x_pos = lane * lane_width
    var z_pos = -distance
    
    return spawn_random_rock(Vector3(x_pos, 0, z_pos))
