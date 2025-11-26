# Space Chunk Spawner Script
# FEATURE: "Pac-Man" Style: Ghosts occasionally replace Orbs on the rail (Mixed Stream).

extends Node3D

# --- EXTERNAL SCENES ---
@export var orb_scene: PackedScene 
@export var obstacle_scene: PackedScene 
@export var ghost_scene: PackedScene # NEW: The enemy that appears on the rail

# --- SPAWN VOLUME ---
@export_group("Spawn Volume")
@export var spawn_volume_x: float = 50.0 
@export var spawn_volume_y: float = 50.0 
@export var spawn_volume_z: float = 100.0 # Length of the chunk

# --- SPACING SETTINGS (Distance) ---
@export_group("Linear Spacing")
@export var orb_spacing: float = 8.0   # The "Rail" density
@export var rock_spacing: float = 25.0 # Obstacles on the side
@export var min_rock_spacing: float = 10.0 # Max density for rocks

# --- INTERNAL VARIABLES ---
var generator = null 

func _ready():
    generator = get_tree().get_first_node_in_group("level_manager")

# --- PUBLIC METHOD CALLED BY LEVEL GENERATOR ---

func spawn_objects(_u1, _u2):
    # Default to 0% ghost chance if called without difficulty info
    spawn_objects_with_difficulty(0.0)

# New Entry Point: Called by LevelGenerator with difficulty info
func spawn_objects_with_difficulty(ghost_chance: float):
    if not is_instance_valid(generator): return

    # 1. Spawn The Rail (Orbs mixed with Ghosts)
    var orb_ref = generator.orb_scene
    var ghost_ref = generator.ghost_scene
    
    _spawn_mixed_linear_stream(orb_ref, ghost_ref, "orbs", orb_spacing, 0.0, ghost_chance)
    
    # 2. Spawn Rocks (Scattered obstacles)
    var rock_ref = generator.obstacle_scene
    var chunks = generator.chunks_spawned
    
    if chunks > 3:
        var current_rock_spacing = max(min_rock_spacing, rock_spacing - (chunks * 1.0))
        _spawn_linear_stream(rock_ref, "obstacles", current_rock_spacing, 15.0)


# --- SPAWNING LOGIC ---

# Spawns a stream that can swap items based on chance
func _spawn_mixed_linear_stream(main_scene: PackedScene, alt_scene: PackedScene, group: String, spacing: float, z_offset_start: float, alt_chance: float):
    if not is_instance_valid(main_scene): return
    
    var current_z = -z_offset_start
    
    while current_z > -spawn_volume_z:
        var scene_to_spawn = main_scene
        var final_group = group
        
        # THE GHOST ROLL: If the dice roll is lower than the chance, swap to Ghost!
        if is_instance_valid(alt_scene) and randf() < alt_chance:
            scene_to_spawn = alt_scene
            final_group = "ghosts"
            
        var ent = scene_to_spawn.instantiate()
        
        # 1. Random X/Y (Lane Position)
        var rx = randf_range(-spawn_volume_x/2.0, spawn_volume_x/2.0)
        var ry = randf_range(-spawn_volume_y/2.0, spawn_volume_y/2.0)
        
        # 2. Fixed Z (Even Spacing) + small random jitter
        var z_jitter = randf_range(-2.0, 2.0) 
        var final_z = current_z + z_jitter
        final_z = clampf(final_z, -spawn_volume_z, 0.0)
        
        ent.position = Vector3(rx, ry, final_z)
        
        add_child(ent)
        ent.add_to_group(final_group)
        
        current_z -= spacing

# Standard function for single-type streams (Rocks)
func _spawn_linear_stream(scene: PackedScene, group: String, spacing: float, z_offset_start: float):
    if not is_instance_valid(scene): return
    
    var current_z = -z_offset_start 
    
    while current_z > -spawn_volume_z:
        var ent = scene.instantiate()
        
        var rx = randf_range(-spawn_volume_x/2.0, spawn_volume_x/2.0)
        var ry = randf_range(-spawn_volume_y/2.0, spawn_volume_y/2.0)
        
        var z_jitter = randf_range(-2.0, 2.0) 
        var final_z = current_z + z_jitter
        final_z = clampf(final_z, -spawn_volume_z, 0.0)
        
        ent.position = Vector3(rx, ry, final_z)
        
        add_child(ent)
        ent.add_to_group(group)
        
        current_z -= spacing
