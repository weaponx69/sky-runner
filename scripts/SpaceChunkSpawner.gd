# Space Chunk Spawner Script
# FIX: Switched from Timers to Linear Z-Placement loops.
# FIX: Objects are now spaced evenly by distance, not time.

extends Node3D

# --- SPAWN VOLUME ---
@export_group("Spawn Volume")
@export var spawn_volume_x: float = 50.0 
@export var spawn_volume_y: float = 50.0 
@export var spawn_volume_z: float = 100.0 # Length of the chunk

# --- SPACING SETTINGS (Distance in Meters) ---
@export_group("Linear Spacing")
@export var orb_spacing: float = 10.0  # One orb every 15 meters
@export var rock_spacing: float = 24.0 # One rock every 40 meters (starts sparse)
@export var min_rock_spacing: float = 20.0 # Max density for rocks

# --- INTERNAL VARIABLES ---
var generator = null 

func _ready():
    generator = get_tree().get_first_node_in_group("level_manager")

# --- PUBLIC METHOD CALLED BY LEVEL GENERATOR ---

func spawn_objects(_u1, _u2):
    # 1. Spawn Orbs (Evenly spaced stream)
    _spawn_linear_stream(generator.orb_scene, "orbs", orb_spacing, 0.0)
    
    # 2. Spawn Obstacles (Evenly spaced, with safe zone check)
    if is_instance_valid(generator):
        var chunks = generator.chunks_spawned
        
        # Safe Zone: No rocks for first 3 chunks
        if chunks > 3:
            # Calculate Dynamic Difficulty: Rocks get closer together over time
            # Reduce spacing by 1.0 meter per chunk, clamped to minimum
            var current_rock_spacing = max(min_rock_spacing, rock_spacing - (chunks * 1.0))
            
            _spawn_linear_stream(generator.obstacle_scene, "obstacles", current_rock_spacing, 20.0)

func _spawn_linear_stream(scene: PackedScene, group: String, spacing: float, z_offset_start: float):
    if not is_instance_valid(scene): return
    
    # Start spawning from the beginning of the chunk (0) to the end (-spawn_volume_z)
    var current_z = -z_offset_start # Optional offset to prevent clipping at start
    
    while current_z > -spawn_volume_z:
        var ent = scene.instantiate()
        
        # 1. Random X/Y (Lane Position)
        var rx = randf_range(-spawn_volume_x/2.0, spawn_volume_x/2.0)
        var ry = randf_range(-spawn_volume_y/2.0, spawn_volume_y/2.0)
        
        # 2. Fixed Z (Even Spacing) + small random jitter for natural look
        var z_jitter = randf_range(-2.0, 2.0) 
        var final_z = current_z + z_jitter
        
        # Ensure we don't spawn outside the chunk
        final_z = clampf(final_z, -spawn_volume_z, 0.0)
        
        ent.position = Vector3(rx, ry, final_z)
        
        add_child(ent)
        ent.add_to_group(group)
        
        # Move to next position
        current_z -= spacing
