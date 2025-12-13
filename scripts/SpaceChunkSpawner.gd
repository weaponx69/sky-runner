## Manages the spawning of objects within a "chunk" of space in the game world.
#
# This script is responsible for procedurally placing orbs, obstacles, and ghosts
# within a defined volume. It includes logic to mix in ghosts with orbs based on a
# given probability, creating a "mixed stream" of collectibles and enemies.
extends Node3D

@export_group("Maze Generation")
## The number of cells for the maze grid's width (X-axis).
@export var maze_width: int = 5
## The number of cells for the maze grid's depth (Z-axis).
@export var maze_depth: int = 10
## The size of each maze cell in world units.
@export var cell_size: float = 10.0

@export_group("Debug Path Visuals")
@export var show_path_debug: bool = false
@export var path_debug_color: Color = Color(0.1, 0.8, 0.1) # Green path line
@export var show_debug_walls: bool = true

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
@export var orb_spacing: float = 28.0
## The initial spacing between rocks.
@export var rock_spacing: float = 25.0
## The minimum spacing for rocks, ensuring they don't get too dense.
@export var min_rock_spacing: float = 10.0

# --- INTERNAL VARIABLES ---
## A reference to the level generator node.
var generator = null
# Tracks the current difficulty level (0.0 to 1.0)
var current_difficulty: float = 0.0

var grid = [] # Stores the maze data
var stack = []

## Called when the node enters the scene tree for the first time.
# Initializes the reference to the level generator.
func _ready():
    generator = get_tree().get_first_node_in_group("level_manager")
    randomize()

# --- PUBLIC METHOD CALLED BY LEVEL GENERATOR ---

## A legacy entry point for spawning objects, which defaults to a 0% ghost chance.
# - `_u1`: Unused parameter.
# - `_u2`: Unused parameter.
func spawn_objects(_u1, _u2):
    spawn_objects_with_difficulty(0.0)

## Sets the difficulty for this specific chunk. Called by LevelGenerator.
func set_chunk_difficulty(factor: float):
    current_difficulty = factor

## The main entry point for spawning objects, called by the `LevelGenerator`.
# Spawns a mixed stream of orbs and ghosts, and a separate stream of rocks.
# - `ghost_chance`: The probability (0.0 to 1.0) that an orb will be replaced by a ghost.
func spawn_objects_with_difficulty(ghost_chance: float):
    if not is_instance_valid(generator): return

    _generate_maze_structure() # NEW: Generate the maze grid
    _create_maze_colliders()   # NEW: Create physical colliders from the grid

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

# --- MAZE GENERATION (Randomized DFS) ---

func _generate_maze_structure():
    # 1. Initialize Grid
    grid.resize(maze_width)
    for x in range(maze_width):
        grid[x] = []
        grid[x].resize(maze_depth)
        for z in range(maze_depth):
            # Each cell has [Top, Right, Bottom, Left] walls and a visited flag
            grid[x][z] = { "walls": [true, true, true, true], "visited": false }

    # 2. Start DFS traversal
    var current_x = 0
    var current_z = 0
    grid[current_x][current_z].visited = true
    stack.append(Vector2i(current_x, current_z))

    while not stack.is_empty():
        var current_cell_pos = stack.pop_back()
        current_x = current_cell_pos.x
        current_z = current_cell_pos.y

        var neighbors = _get_unvisited_neighbors(current_x, current_z)
        if not neighbors.is_empty():
            stack.append(current_cell_pos)

            var chosen_neighbor = neighbors.pick_random()
            var nx = chosen_neighbor.x
            var nz = chosen_neighbor.y

            # Knock down walls between current cell and chosen neighbor
            if nx == current_x + 1: # Right neighbor
                grid[current_x][current_z].walls[1] = false
                grid[nx][nz].walls[3] = false
            elif nx == current_x - 1: # Left neighbor
                grid[current_x][current_z].walls[3] = false
                grid[nx][nz].walls[1] = false
            elif nz == current_z + 1: # Bottom neighbor
                grid[current_x][current_z].walls[2] = false
                grid[nx][nz].walls[0] = false
            elif nz == current_z - 1: # Top neighbor
                grid[current_x][current_z].walls[0] = false
                grid[nx][nz].walls[2] = false

            grid[nx][nz].visited = true
            stack.append(Vector2i(nx, nz))
            
    # 3. Second pass to remove dead ends
    for x in range(maze_width):
        for z in range(maze_depth):
            var cell = grid[x][z]
            # if a cell has a wall in front of it (wall at index 0) and also walls on both sides (left and right), I will remove the front wall. This will prevent U-shaped traps.
            if cell.walls[0] and cell.walls[1] and cell.walls[3]:
                grid[x][z].walls[0] = false;
                # Also remove the corresponding wall from the neighbor
                if z > 0:
                    grid[x][z-1].walls[2] = false

func _get_unvisited_neighbors(x: int, z: int) -> Array:
    var neighbors = []
    # Check top
    if z > 0 and not grid[x][z - 1].visited:
        neighbors.append(Vector2i(x, z - 1))
    # Check right
    if x < maze_width - 1 and not grid[x + 1][z].visited:
        neighbors.append(Vector2i(x + 1, z))
    # Check bottom
    if z < maze_depth - 1 and not grid[x][z + 1].visited:
        neighbors.append(Vector2i(x, z + 1))
    # Check left
    if x > 0 and not grid[x - 1][z].visited:
        neighbors.append(Vector2i(x - 1, z))
    return neighbors

func _create_maze_colliders():
    var half_cell = cell_size / 2.0
    
    for x in range(maze_width):
        for z in range(maze_depth):
            var cell = grid[x][z]
            var cell_pos_x = (x * cell_size) - (maze_width * cell_size / 2.0) + half_cell
            var cell_pos_z = -(z * cell_size) - half_cell

            # Top wall (runs parallel to X axis)
            if cell.walls[0]:
                var wall_pos = Vector3(cell_pos_x, 0, cell_pos_z + half_cell)
                var wall_size = Vector3(cell_size + 0.5, 1.0, 0.5) 
                _spawn_collider_wall(wall_pos, wall_size)
            # Right wall (runs parallel to Z axis)
            if cell.walls[1]:
                var wall_pos = Vector3(cell_pos_x + half_cell, 0, cell_pos_z)
                var wall_size = Vector3(0.5, 1.0, cell_size + 0.5)
                _spawn_collider_wall(wall_pos, wall_size)
            # Draw bottom-most and left-most outer walls
            if z == maze_depth - 1 and cell.walls[2]:
                var wall_pos = Vector3(cell_pos_x, 0, cell_pos_z - half_cell)
                var wall_size = Vector3(cell_size + 0.5, 1.0, 0.5)
                _spawn_collider_wall(wall_pos, wall_size)
            if x == 0 and cell.walls[3]:
                var wall_pos = Vector3(cell_pos_x - half_cell, 0, cell_pos_z)
                var wall_size = Vector3(0.5, 1.0, cell_size + 0.5)
                _spawn_collider_wall(wall_pos, wall_size)

func _spawn_collider_wall(pos: Vector3, size: Vector3):
    var static_body = StaticBody3D.new()
    add_child(static_body)
    static_body.position = pos
    static_body.collision_layer = 1 # Wall is on Layer 1
    static_body.collision_mask = 1  # Wall looks for things on Layer 1 (Player)
    
    var collision_shape = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    
    box_shape.size = size
    collision_shape.shape = box_shape
    static_body.add_child(collision_shape)

    if show_debug_walls:
        var mesh_instance = MeshInstance3D.new()
        var box_mesh = BoxMesh.new()
        box_mesh.size = size
        mesh_instance.mesh = box_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(1, 0, 0, 0.3) # Semi-transparent red
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mesh_instance.material_override = mat
        static_body.add_child(mesh_instance)

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
        

## Links all PathNodes in the current chunk based on forward distance.
func _link_chunk_nodes(all_nodes: Array[Node3D]):
    if all_nodes.is_empty(): return
    
    # Iterate through every PathNode in the chunk
    for node in all_nodes:
        # Check if the node has the 'neighbors' array (from PathNode.gd)
        if not "neighbors" in node: continue

        # Clear old neighbors to be safe
        node.neighbors.clear()
        
        # Check every other node as a potential connection
        for candidate in all_nodes:
            if node == candidate: continue
            
            # 1. Forward Check: Candidate must be ahead of us (Negative Z)
            var diff_z = candidate.global_position.z - node.global_position.z
            
            # 2. Distance Check: Connect anything within range (Creating a Web)
            # We use a wider range (e.g. 40.0) so you have multiple options (Left/Right)
            var dist = node.global_position.distance_to(candidate.global_position)
            
            if diff_z < -1.0 and dist < 40.0:
                node.neighbors.append(candidate)
                
                # NEW: Populate this specific path with danger
                _spawn_hazards_on_link(node, candidate)


## Spawns obstacles directly on the path between two nodes to force dodging.
func _spawn_hazards_on_link(node_a: Node3D, node_b: Node3D):
    var start = node_a.global_position
    var end = node_b.global_position
    var dist = start.distance_to(end)
    
    # 1. REDUCE DENSITY: Increased spacing from 20.0 to 45.0
    var rock_count = int(dist / 45.0) 
    
    if rock_count < 1: return

    for i in range(1, rock_count + 1):
        # 2. RANDOM CHANCE: Only spawn 40% of potential rocks
        if randf() > 0.4: 
            continue

        # Calculate position
        var t = float(i) / (rock_count + 1)
        
        # 3. SAFETY BUFFER: Don't spawn rocks within 10% of the start or end orb
        if t < 0.1 or t > 0.9:
            continue
            
        var spawn_pos = start.lerp(end, t)
        
        # Instantiate Rock
        var rock = generator.obstacle_scene.instantiate()
        add_child(rock)
        rock.global_position = spawn_pos
        rock.add_to_group("obstacles")
        
        # Offset Logic (Keep this so they aren't perfectly centered)
        var offset_dir = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0).normalized()
        rock.global_position += offset_dir * randf_range(1.0, 3.0)
