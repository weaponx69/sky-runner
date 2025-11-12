# New file: res://scripts/RockManager.gd
extends Node

const ROCK_SCENES = [
    preload("res://scenes/Rock.tscn"),
    preload("res://scenes/ObstacleRock.tscn")
]

func _ready():
    # Example: spawn a random rock
    spawn_random_rock()

func spawn_random_rock(position: Vector3 = Vector3.ZERO) -> Node3D:
    if ROCK_SCENES.is_empty():
        push_error("No rock scenes available!")
        return null
    
    var random_scene = ROCK_SCENES.pick_random()
    var rock_instance = random_scene.instantiate()
    
    rock_instance.position = position
    add_child(rock_instance)
    
    return rock_instance

func spawn_rock_at_path(distance: float, lane: int = 0) -> Node3D:
    # Spawn rocks along the player's path
    var lane_width = 3.0
    var x_pos = lane * lane_width
    var z_pos = -distance  # Negative because player moves forward
    
    return spawn_random_rock(Vector3(x_pos, 0, z_pos))
