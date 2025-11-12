# res://scripts/SpaceChunkSpawner.gd
# FINAL VERSION: Accepts dynamic object counts from LevelGenerator and applies density control.
extends Node3D

# --- REQUIRED TEMPLATE SCENES (Must be set in the Inspector) ---
@export var orb_scene: PackedScene = preload("res://scenes/Orb3D.tscn")
@export var rock_scene: PackedScene = preload("res://scenes/Rock.tscn")

# --- CUSTOMIZATION PARAMETERS (Define the Spawning Volume) ---
# NOTE: Orb/Rock counts are now controlled by the LevelGenerator.gd script.
@export var rock_min_scale: float = 0.5   # Smallest rock size
@export var rock_max_scale: float = 2.0   # Largest rock size

@export var spawn_volume_x: float = 10.0   # Left/right spread
@export var spawn_volume_y: float = 8.0    # Up/down spread
@export var spawn_volume_z: float = 180.0  # Length along the flight path

# NEW: Defines where in the chunk (along Z-axis, as a percentage) to start spawning orbs.
# e.g., 0.3 means rocks spawn in the first 30%, and orbs start after 30%.
@export var orb_z_start: float = 0.3 

# --- CORE FUNCTIONALITY ---

func _ready():
    # The LevelGenerator will now call spawn_objects() directly after instantiation,
    # so we remove the call from _ready to avoid double spawning.
    pass 

# This function is now called directly by LevelGenerator.gd with calculated counts.
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
    
    # 2. Generate random position coordinates
    var rand_x = randf_range(-spawn_volume_x, spawn_volume_x)
    var rand_y = randf_range(-spawn_volume_y, spawn_volume_y)
    
    # 3. Calculate Z-coordinate based on density rules
    var start_z_range = 0.0
    var end_z_range = spawn_volume_z
    
    # NEW LOGIC: DELAY THE ROCKS, NOT THE ORBS
    if scene == rock_scene:
        # Rocks only spawn after the defined start point (e.g., after 30% of the chunk)
        start_z_range = end_z_range * orb_z_start # Reusing orb_z_start to define the rock delay
    
    # Orbs will spawn in the full range (start_z_range remains 0.0 for orbs)
    
    # Random position along the length of the allowed range (Note: using negative for Z)
    var rand_z = randf_range(-end_z_range, -start_z_range) 
    
    # 4. Position and add the node
    instance.position = Vector3(rand_x, rand_y, rand_z)
    
    add_child(instance)
