## Manages the spawning of objects within a "chunk" of space in the game world.
#
# This script is responsible for procedurally placing orbs, obstacles, and ghosts
# within a defined volume. It includes logic to mix in ghosts with orbs based on a
# given probability, creating a "mixed stream" of collectibles and enemies.
extends Node3D

@export_group("Debug Path Visuals")
@export var show_path_debug: bool = true
@export var path_debug_color: Color = Color(0.1, 0.8, 0.1) # Green path line

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
    
func _draw_path_debug(all_nodes: Array[Node3D]):
    if not show_path_debug: return
    if all_nodes.is_empty(): return
    
    var debug_mesh = ImmediateMesh.new()
    var mesh_instance = MeshInstance3D.new()
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = path_debug_color
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.mesh = debug_mesh
    mesh_instance.material_override = mat
    mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    
    add_child(mesh_instance)
    
    debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    
    # Draw a line from each node to its designated 'next_node'
    for node in all_nodes:
        if is_instance_valid(node) and node.next_node != null:
            debug_mesh.surface_add_vertex(node.global_position)
            debug_mesh.surface_add_vertex(node.next_node.global_position)

    debug_mesh.surface_end()


## The main entry point for spawning objects, called by the `LevelGenerator`.
# Spawns a mixed stream of orbs and ghosts, and a separate stream of rocks.
# - `ghost_chance`: The probability (0.0 to 1.0) that an orb will be replaced by a ghost.
func spawn_objects_with_difficulty(ghost_chance: float):
    if not is_instance_valid(generator): return

    # 1. Spawn The Rail (Orbs mixed with Ghosts)
    var orb_ref = generator.orb_scene
    var ghost_ref = generator.ghost_scene
    var rail_nodes = _spawn_mixed_linear_stream(orb_ref, ghost_ref, "orbs", orb_spacing, 0.0, ghost_chance)
    
    # 2. Spawn Rocks (Scattered obstacles)
    var rock_ref = generator.obstacle_scene
    var chunks = generator.chunks_spawned
    
    if chunks > 3:
        var current_rock_spacing = max(min_rock_spacing, rock_spacing - (chunks * 1.0))
        var _rock_nodes = _spawn_linear_stream(rock_ref, "obstacles", current_rock_spacing, 15.0)
    
    # 3. CRITICAL: Link the generated nodes now that all nodes are present
    _link_chunk_nodes(rail_nodes)
    
    # 4. NEW: Draw the resulting connected path
    _draw_path_debug(rail_nodes)

# --- SPAWNING LOGIC ---

## Spawns a stream of objects where some can be randomly replaced by an alternative.
# - `main_scene`: The primary `PackedScene` to spawn.
# - `alt_scene`: The alternative `PackedScene` to spawn.
# - `group`: The group to assign to the primary spawned objects.
# - `spacing`: The distance between objects in the stream.
# - `z_offset_start`: The starting offset on the Z-axis.
# - `alt_chance`: The probability of spawning the alternative scene.
func _spawn_mixed_linear_stream(main_scene: PackedScene, alt_scene: PackedScene, group: String, spacing: float, z_offset_start: float, alt_chance: float) -> Array[Node3D]:
    if not is_instance_valid(main_scene): return []
    
    var created_nodes: Array[Node3D] = [] # NEW: Array to hold all PathNodes
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
        
        # NEW: Add the created entity to the array
        created_nodes.append(ent)
        
        current_z -= spacing
        
    return created_nodes # NEW: Return the list of nodes

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
## Links all PathNodes in the current chunk based on closest forward distance.
func _link_chunk_nodes(all_nodes: Array[Node3D]):
    if all_nodes.is_empty(): return
    
    # Iterate through every PathNode in the chunk
    for node in all_nodes:
        if not node.has_method("get_instance_id"): continue # Skip non-PathNodes

        var nearest_node = null
        var min_forward_dist = INF
        
        # Check every other node as a potential candidate for the 'next_node'
        for candidate in all_nodes:
            if node == candidate: continue
            
            # The candidate must be forward of the current node
            var diff_z = candidate.global_position.z - node.global_position.z
            
            # We only look for nodes that are significantly forward (negative Z difference)
            if diff_z < -1.0:
                var dist = node.global_position.distance_to(candidate.global_position)
                
                # Check if this candidate is closer than the current 'nearest'
                if dist < min_forward_dist:
                    min_forward_dist = dist
                    nearest_node = candidate

        # Assign the closest forward node as the next in the path
        if nearest_node:
            node.next_node = nearest_node
