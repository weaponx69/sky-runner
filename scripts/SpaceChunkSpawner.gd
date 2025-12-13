extends Node3D

@export_group("Maze Generation")
@export var maze_width: int = 5
@export var maze_depth: int = 10
@export var cell_size: float = 10.0

@export_group("Debug Path Visuals")
@export var show_path_debug: bool = false
@export var path_debug_color: Color = Color(0.1, 0.8, 0.1) # Green path line
@export var show_debug_walls: bool = true

# --- EXTERNAL SCENES ---
@export var orb_scene: PackedScene
@export var obstacle_scene: PackedScene
@export var ghost_scene: PackedScene

# --- SPAWN VOLUME ---
@export_group("Spawn Volume")
@export var spawn_volume_x: float = 50.0
@export var spawn_volume_y: float = 50.0
@export var spawn_volume_z: float = 100.0

# --- SPACING SETTINGS (Distance) ---
@export_group("Linear Spacing")
@export var orb_spacing: float = 28.0
@export var rock_spacing: float = 25.0
@export var min_rock_spacing: float = 10.0

# --- CUBE MAZE SETTINGS ---
@export var cube_size: float = 3.0
@export var gap: float = 2.0
@export var grid_width: int = 10
@export var grid_depth: int = 20

var generator = null

func _ready():
    generator = get_tree().get_first_node_in_group("level_manager")
    randomize()

func spawn_objects(_u1, _u2):
    spawn_objects_with_difficulty(0.0)

func set_chunk_difficulty(factor: float):
    pass # Not used in this simplified version

func spawn_objects_with_difficulty(ghost_chance: float):
    if not is_instance_valid(generator): return

    _spawn_box_maze() # Spawn the physical maze first

    # 1. Spawn The Rail (Orbs mixed with Ghosts) - now relative to the path
    var orb_ref = generator.orb_scene
    var ghost_ref = generator.ghost_scene
    var rail_nodes = _spawn_mixed_linear_stream(orb_ref, ghost_ref, "orbs", orb_spacing, 0.0, ghost_chance)
    
    # 2. Spawn Rocks (Scattered obstacles)
    var rock_ref = generator.obstacle_scene
    var chunks = 0 # In this simplified version, chunks_spawned is not incremented, so hardcode 0
    
    if chunks > 3: # This condition might never be met with fixed chunks = 0
        var current_rock_spacing = max(min_rock_spacing, rock_spacing) # Simplified rock spacing
        var _rock_nodes = _spawn_linear_stream(rock_ref, "obstacles", current_rock_spacing, 15.0)
    
    # 3. CRITICAL: Link the generated nodes now that all nodes are present
    _link_chunk_nodes(rail_nodes)
    
    # 4. Draw the resulting connected path
    _draw_path_debug(rail_nodes)


func _spawn_box_maze():
    for x in range(grid_width):
        for z in range(grid_depth):
            # Carve out a simple path with a wider passage
            if (x > 1 and x < grid_width - 2): # This creates a central path 3 cubes wide
                if (z % 2 == 0): # Skip every other row in the path to create a simple winding
                    continue

            var wall_pos = Vector3(
                (x * (cube_size + gap)) - (grid_width * (cube_size + gap) / 2.0) + (cube_size + gap) / 2.0, # Center cell
                0,
                -(z * (cube_size + gap)) - (cube_size + gap) / 2.0 # Center cell
            )
            # Randomize cube size while maintaining spacing
            var random_size_factor = randf_range(0.5, 1.0) # Cubes will be between 0.5 and 1.0 times base size
            var current_cube_size = cube_size * random_size_factor
            _spawn_wall_box(wall_pos, Vector3(current_cube_size, current_cube_size, current_cube_size))


func _spawn_wall_box(position: Vector3, size: Vector3):
    var static_body = StaticBody3D.new()
    add_child(static_body)
    static_body.position = position
    static_body.collision_layer = 1
    static_body.collision_mask = 1

    var collision_shape = CollisionShape3D.new()
    static_body.add_child(collision_shape)
    
    var box_shape = BoxShape3D.new()
    box_shape.size = size
    collision_shape.shape = box_shape

    if show_debug_walls:
        var mesh_instance = MeshInstance3D.new()
        static_body.add_child(mesh_instance)
        var box_mesh = BoxMesh.new()
        box_mesh.size = size
        mesh_instance.mesh = box_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.2, 0.3, 0.8, 0.4) # Blueish color
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mesh_instance.material_override = mat

## Spawns a stream of objects where some can be randomly replaced by an alternative.
# - `main_scene`: The primary `PackedScene` to spawn.
# - `alt_scene`: The alternative `PackedScene` to spawn.
# - `group`: The group to assign to the primary spawned objects.
# - `spacing`: The distance between objects in the stream.
# - `z_offset_start`: The starting offset on the Z-axis.
# - `alt_chance`: The probability of spawning the alternative scene.
func _spawn_mixed_linear_stream(main_scene: PackedScene, alt_scene: PackedScene, group: String, spacing: float, z_offset_start: float, alt_chance: float) -> Array[Node3D]:
    if not is_instance_valid(main_scene): return []
    
    var created_nodes: Array[Node3D] = []
    var current_z = -z_offset_start
    
    while current_z > -spawn_volume_z:
        var scene_to_spawn = main_scene
        var final_group = group
        
        if is_instance_valid(alt_scene) and randf() < alt_chance:
            scene_to_spawn = alt_scene
            final_group = "ghosts"
            
        var ent = scene_to_spawn.instantiate()
        
        # Position within the carved path (center X of the path)
        var rx = randf_range(-1 * ((cube_size + gap) / 2.0), 1 * ((cube_size + gap) / 2.0)) # Random X within central path
        var ry = randf_range(-spawn_volume_y/2.0, spawn_volume_y/2.0)
        
        var z_jitter = randf_range(-2.0, 2.0) 
        var final_z = current_z + z_jitter
        final_z = clampf(final_z, -spawn_volume_z, 0.0)
        
        ent.position = Vector3(rx, ry, final_z)
        
        add_child(ent)
        ent.add_to_group(final_group)
        
        created_nodes.append(ent)
        
        current_z -= spacing
        
    return created_nodes

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
        
        # Position within the carved path (center X of the path)
        var rx = randf_range(-1 * ((cube_size + gap) / 2.0), 1 * ((cube_size + gap) / 2.0)) # Random X within central path
        var ry = randf_range(-spawn_volume_y/2.0, spawn_volume_y/2.0)
        
        var z_jitter = randf_range(-2.0, 2.0) 
        var final_z = current_z + z_jitter
        final_z = clampf(final_z, -spawn_volume_z, 0.0)
        
        ent.position = Vector3(rx, ry, final_z)
        
        add_child(ent)
        ent.add_to_group(group)
        
        current_z -= spacing
        

## Links all PathNodes in the current chunk based on forward distance.
func _link_chunk_nodes(all_nodes: Array[Node3D]):
    if all_nodes.is_empty(): return
    
    for node in all_nodes:
        if not "neighbors" in node: continue

        node.neighbors.clear()
        
        for candidate in all_nodes:
            if node == candidate: continue
            
            var diff_z = candidate.global_position.z - node.global_position.z
            
            var dist = node.global_position.distance_to(candidate.global_position)
            
            if diff_z < -1.0 and dist < 40.0:
                node.neighbors.append(candidate)
                
                _spawn_hazards_on_link(node, candidate)


## Spawns obstacles directly on the path between two nodes to force dodging.
func _spawn_hazards_on_link(node_a: Node3D, node_b: Node3D):
    var start = node_a.global_position
    var end = node_b.global_position
    var dist = start.distance_to(end)
    
    var rock_count = int(dist / 45.0) 
    
    if rock_count < 1: return

    for i in range(1, rock_count + 1):
        if randf() > 0.4: 
            continue

        var t = float(i) / (rock_count + 1)
        
        if t < 0.1 or t > 0.9:
            continue
            
        var spawn_pos = start.lerp(end, t)
        
        var rock = generator.obstacle_scene.instantiate()
        add_child(rock)
        rock.global_position = spawn_pos
        rock.add_to_group("obstacles")
        
        var offset_dir = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0).normalized()
        rock.global_position += offset_dir * randf_range(1.0, 3.0)

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
    
    # Draw lines from each node to ALL its neighbors
    for node in all_nodes:
        if is_instance_valid(node) and "neighbors" in node:
            for neighbor in node.neighbors:
                if is_instance_valid(neighbor):
                    debug_mesh.surface_add_vertex(node.global_position)
                    debug_mesh.surface_add_vertex(neighbor.global_position)

    debug_mesh.surface_end()