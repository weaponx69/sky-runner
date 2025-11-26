## Manages the loading and spawning of rock models in the game.
#
# This script loads 3D rock models from a specified folder, and provides
# functions to spawn individual rocks, rocks along a path, or clusters of rocks.
# It includes randomization for rotation and scale to create variety.
extends Node

## The file path to the folder containing the rock models (in `.glb` or `.gltf` format).
@export var rock_folder_path: String = "res://assets/rocks/"
## The distance at which rocks should be spawned.
@export var spawn_distance: float = 50.0
## The height at which rocks should be spawned.
@export var spawn_height: float = 0.0
## The width within which rocks can be spawned.
@export var spawn_width: float = 10.0
## The base scale of the spawned rocks.
@export var rock_scale: Vector3 = Vector3(1, 1, 1)

## An array to store the loaded rock models.
var rock_models: Array = []
## A random number generator for creating variety in spawned rocks.
var rng = RandomNumberGenerator.new()

## Called when the node enters the scene tree for the first time.
# Initializes the random number generator and loads the rock models.
func _ready():
    rng.randomize()
    load_rock_models()

## Loads all `.glb` and `.gltf` models from the `rock_folder_path`.
# If no models are found, it falls back to a default set of rock scenes.
func load_rock_models():
    rock_models.clear()
    
    var dir = DirAccess.open(rock_folder_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
                var full_path = rock_folder_path + file_name
                var model = load(full_path)
                if model:
                    rock_models.append(model)
                    print("Loaded rock model: " + file_name)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    else:
        push_warning("Could not open rock folder: " + rock_folder_path)
    
    if rock_models.is_empty():
        push_warning("No GLB models found, using fallback scenes")
        rock_models = [
            preload("res://scenes/Rock.tscn"),
            preload("res://scenes/ObstacleRock.tscn")
        ]

## Spawns a single, randomly selected rock at a given position.
# - `position`: The position where the rock will be spawned.
# Returns the spawned rock instance, or `null` if no models are available.
func spawn_random_rock(position: Vector3 = Vector3.ZERO) -> Node3D:
    if rock_models.is_empty():
        push_error("No rock models available!")
        return null
    
    var random_model = rock_models.pick_random()
    var rock_instance = random_model.instantiate()
    
    rock_instance.position = position
    
    rock_instance.rotation_degrees = Vector3(
        rng.randf_range(-15, 15),
        rng.randf_range(0, 360),
        rng.randf_range(-15, 15)
    )
    
    var scale_variation = rng.randf_range(0.8, 1.3)
    rock_instance.scale = rock_scale * scale_variation
    
    add_child(rock_instance)
    return rock_instance

## Spawns a rock at a specified distance along a path, with lane positioning.
# - `distance`: The distance along the path to spawn the rock.
# - `lane`: The lane in which to spawn the rock.
# Returns the spawned rock instance.
func spawn_rock_along_path(distance: float, lane: int = 0) -> Node3D:
    var lane_width = 3.0
    var x_pos = lane * lane_width + rng.randf_range(-1.0, 1.0)
    var z_pos = -distance
    
    var y_pos = rng.randf_range(-0.5, 0.5)
    
    return spawn_random_rock(Vector3(x_pos, y_pos, z_pos))

## Spawns a cluster of rocks around a central position.
# - `center_pos`: The central position for the cluster.
# - `count`: The number of rocks to spawn in the cluster.
# Returns an array containing the spawned rock instances.
func spawn_rock_cluster(center_pos: Vector3, count: int = 3) -> Array:
    var rocks = []
    
    for i in range(count):
        var offset = Vector3(
            rng.randf_range(-2, 2),
            0,
            rng.randf_range(-2, 2)
        )
        var rock = spawn_random_rock(center_pos + offset)
        if rock:
            rocks.append(rock)
    
    return rocks
