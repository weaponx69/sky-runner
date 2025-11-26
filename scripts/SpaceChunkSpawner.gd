## Manages the spawning of objects within a "chunk" of space in the game world.
#
# This script is responsible for procedurally placing orbs, obstacles, and ghosts
# within a defined volume. It includes logic to mix in ghosts with orbs based on a
# given probability, creating a "mixed stream" of collectibles and enemies.
extends Node3D

# --- EXTERNAL SCENES ---
## The `PackedScene` for the orb collectibles.
@export var orb_scene: PackedScene
## The `PackedScene` for the rock obstacles.
@export var obstacle_scene: PackedScene
## The `PackedScene` for the ghost enemies.
@export var ghost_scene: PackedScene

# --- SPAWN VOLUME ---
@export_group("Spawn Volume")
## The width of the spawn area on the X-axis.
@export var spawn_volume_x: float = 50.0
## The height of the spawn area on the Y-axis.
@export var spawn_volume_y: float = 50.0
## The length of the spawn area on the Z-axis, representing the length of the chunk.
@export var spawn_volume_z: float = 100.0

# --- SPACING SETTINGS (Distance) ---
@export_group("Linear Spacing")
## The spacing between orbs on their "rail".
@export var orb_spacing: float = 8.0
## The initial spacing between rocks.
@export var rock_spacing: float = 25.0
## The minimum spacing for rocks, ensuring they don't get too dense.
@export var min_rock_spacing: float = 10.0

# --- INTERNAL VARIABLES ---
## A reference to the level generator node.
var generator = null

## Called when the node enters the scene tree for the first time.
# Initializes the reference to the level generator.
func _ready():
    generator = get_tree().get_first_node_in_group("level_manager")

# --- PUBLIC METHOD CALLED BY LEVEL GENERATOR ---

## A legacy entry point for spawning objects, which defaults to a 0% ghost chance.
# - `_u1`: Unused parameter.
# - `_u2`: Unused parameter.
func spawn_objects(_u1, _u2):
    spawn_objects_with_difficulty(0.0)

## The main entry point for spawning objects, called by the `LevelGenerator`.
# Spawns a mixed stream of orbs and ghosts, and a separate stream of rocks.
# - `ghost_chance`: The probability (0.0 to 1.0) that an orb will be replaced by a ghost.
func spawn_objects_with_difficulty(ghost_chance: float):
    if not is_instance_valid(generator): return

    var orb_ref = generator.orb_scene
    var ghost_ref = generator.ghost_scene
    _spawn_mixed_linear_stream(orb_ref, ghost_ref, "orbs", orb_spacing, 0.0, ghost_chance)
    
    var rock_ref = generator.obstacle_scene
    var chunks = generator.chunks_spawned
    
    if chunks > 3:
        var current_rock_spacing = max(min_rock_spacing, rock_spacing - (chunks * 1.0))
        _spawn_linear_stream(rock_ref, "obstacles", current_rock_spacing, 15.0)

# --- SPAWNING LOGIC ---

## Spawns a stream of objects where some can be randomly replaced by an alternative.
# - `main_scene`: The primary `PackedScene` to spawn.
# - `alt_scene`: The alternative `PackedScene` to spawn.
# - `group`: The group to assign to the primary spawned objects.
# - `spacing`: The distance between objects in the stream.
# - `z_offset_start`: The starting offset on the Z-axis.
# - `alt_chance`: The probability of spawning the alternative scene.
func _spawn_mixed_linear_stream(main_scene: PackedScene, alt_scene: PackedScene, group: String, spacing: float, z_offset_start: float, alt_chance: float):
    if not is_instance_valid(main_scene): return
    
    var current_z = -z_offset_start
    
    while current_z > -spawn_volume_z:
        var scene_to_spawn = main_scene
        var final_group = group
        
        if is_instance_valid(alt_scene) and randf() < alt_chance:
            scene_to_spawn = alt_scene
            final_group = "ghosts"
            
        var ent = scene_to_spawn.instantiate()
        
        var rx = randf_range(-spawn_volume_x/2.0, spawn_volume_x/2.0)
        var ry = randf_range(-spawn_volume_y/2.0, spawn_volume_y/2.0)
        
        var z_jitter = randf_range(-2.0, 2.0) 
        var final_z = current_z + z_jitter
        final_z = clampf(final_z, -spawn_volume_z, 0.0)
        
        ent.position = Vector3(rx, ry, final_z)
        
        add_child(ent)
        ent.add_to_group(final_group)
        
        current_z -= spacing

## Spawns a stream of a single type of object, such as rocks.
# - `scene`: The `PackedScene` to spawn.
# - `group`: The group to assign to the spawned objects.
# - `spacing`: The distance between objects in the stream.
# - `z_offset_start`: The starting offset on the Z-axis.
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
