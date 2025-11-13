# res://scripts/SpaceChunkSpawner.gd
# FINAL VERSION: Applies uniform probability reduction for sparse content across the entire chunk.
extends Node3D

# --- REQUIRED TEMPLATE SCENES (Must be set in the Inspector) ---
@export var orb_scene: PackedScene = preload("res://scenes/Orb3D.tscn")
@export var rock_scene: PackedScene = preload("res://scenes/Rock.tscn")

# --- CUSTOMIZATION PARAMETERS ---
# NOTE: Orb/Rock counts are controlled by the LevelGenerator.gd script.
@export var rock_min_scale: float = 0.5   # Smallest rock size
@export var rock_max_scale: float = 2.0   # Largest rock size

@export var spawn_volume_x: float = 10.0   # Left/right spread
@export var spawn_volume_y: float = 8.0    # Up/down spread
@export var spawn_volume_z: float = 180.0  # Length along the flight path

# This variable is now the probability of DELETION across the ENTIRE CHUNK (0.95 = 95% empty space)
@export var content_free_zone_reduction: float = 0.95 
# The orb_z_start logic is now defunct and has been removed from the function.

# --- CORE FUNCTIONALITY ---

func _ready():
    # The LevelGenerator calls spawn_objects() directly after instantiation.
    pass 

# This function is called directly by LevelGenerator.gd with calculated counts.
func spawn_objects(orb_count_to_spawn: int, rock_count_to_spawn: int):
    # Stop if objects are already spawned
    if get_child_count() > 2: # Root + EndAnchor
        return

    # Spawn Orbs using the passed-in count
    for i in range(orb_count_to_spawn):
        spawn_object(orb_scene)
        
    # Spawn Rocks using the passed-in count
    for i in range(rock_count_to_spawn):
        spawn_object(rock_scene)


func spawn_object(scene: PackedScene):
    var instance = scene.instantiate()
    
    # 1. Apply Random Scaling (Only to Rocks)
    if scene == rock_scene:
        var random_scale_factor = randf_range(rock_min_scale, rock_max_scale)
        instance.scale = Vector3(random_scale_factor, random_scale_factor, random_scale_factor)
        
    # 2. Calculate Z-coordinate across the ENTIRE chunk length
    var end_z_range = spawn_volume_z
    
    # Random position calculation
    var rand_x = randf_range(-spawn_volume_x, spawn_volume_x)
    var rand_y = randf_range(-spawn_volume_y, spawn_volume_y)
    
    # Z is now random across the full length (from -end_z_range to 0)
    var rand_z = randf_range(-end_z_range, 0.0) 

    # --- CRITICAL LOGIC: Apply Density Reduction Uniformly Across Chunk ---
    # This check now governs the sparseness for ALL objects across 100% of the volume.
    if randf() < content_free_zone_reduction:
        instance.queue_free() # Delete the instance with a 95% probability
        return 
    # ------------------------------------------------------------------------
    
    # 3. Position and add the node
    instance.position = Vector3(rand_x, rand_y, rand_z)
    
    # Make the new node a child of the SpaceChunk root Node3D
    add_child(instance)
