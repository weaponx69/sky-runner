## Manages the procedural generation of the game level, including spawning chunks, handling game state, and managing UI elements.
#
# This script is responsible for creating an infinitely scrolling level by spawning and despawning chunks of the level.
# It also manages the game's state, such as pausing and game over, and controls the visibility of UI elements.
# The difficulty of the game is also managed by this script, which increases the chance of spawning ghosts over time.
extends Node3D

# --- GAME STATE ---
## The speed at which the level scrolls.
## The distance the player has traveled.
var distance: float = 0.0
## A boolean value that is true if the game is currently running, and false otherwise.
var is_game_running: bool = false
# Variable for the green debug web lines
var debug_draw_imm: ImmediateMesh

# --- SCENE REFERENCES ---
@export var scroll_speed: float = 30.0
@export var show_debug_web: bool = false
@export_group("Scene Management")
## An array of `PackedScene`s that represent the different chunks of the level.
@export var chunk_scenes: Array[PackedScene]
## The scene for the orbs that the player collects.
@export var orb_scene: PackedScene
## The scene for the obstacles that the player must avoid.
@export var obstacle_scene: PackedScene
## The scene for the ghosts that the player must avoid.
@export var ghost_scene: PackedScene

# --- CHUNK CONFIG ---
## The number of chunks to spawn at the beginning of the game.
@export var initial_chunk_count: int = 4
## The distance at which chunks are despawned.
@export var despawn_distance: float = 50.0
## The distance at which new chunks are spawned.
@export var spawn_trigger_distance: float = 100.0

# --- DYNAMIC DIFFICULTY ---
## The initial chance (from 0.0 to 1.0) that an orb will be replaced by a ghost.
@export var initial_ghost_chance: float = 0.05
## The maximum chance that an orb will be replaced by a ghost.
@export var max_ghost_chance: float = 0.3
## How much the ghost chance increases per chunk.
@export var difficulty_ramp: float = 0.01

# --- VARIABLES ---
## The script that is attached to each chunk.
const ChunkSpawnerScript = preload("res://scripts/SpaceChunkSpawner.gd")
## A reference to the player node.
var player_node: Node3D
## A reference to the end of the last spawned chunk.
var last_chunk_end: Marker3D = null
## An array of the currently spawned chunks.
var spawned_chunks: Array[Node3D] = []
## The number of chunks that have been spawned.
var chunks_spawned: int = 0

# --- UI VARIABLES ---
@export_group("UI References")
@export var pause_menu: Control
@export var game_over_label: Label
var last_spawned_chunk: Node3D = null


## Called when the node is added to the scene. Initializes the level generator, sets up the UI, and starts the game in a paused state.
func _ready():
    # CRITICAL: Allow this node to run while the tree is paused
    process_mode = Node.PROCESS_MODE_ALWAYS

    add_to_group("level_manager")
    randomize()

    # --- SETUP DEBUG LINES ---
    var mesh_instance = MeshInstance3D.new()
    debug_draw_imm = ImmediateMesh.new()
    mesh_instance.mesh = debug_draw_imm
    mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    
    # Green unshaded material
    var mat = StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(0, 1, 0) # GREEN LINES
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh_instance.material_override = mat
    
    add_child(mesh_instance)
    # -------------------------
    player_node = get_tree().get_first_node_in_group("player")
    if not player_node:
        push_error("LevelGenerator: Player node not found!")
        return

    initialize_world()

    # Bypass "start paused" for now. Game starts immediately running.
    get_tree().paused = false
    is_game_running = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
    GameStateEvents.game_over.connect(_game_over)
    GameStateEvents.toggle_pause_requested.connect(toggle_pause)


## Draws green lines between connected orbs to visualize the web.
func _draw_debug_web():
    if not debug_draw_imm: return
    
    debug_draw_imm.clear_surfaces()
    debug_draw_imm.surface_begin(Mesh.PRIMITIVE_LINES)
    
    for chunk in spawned_chunks:
        for child in chunk.get_children():
            # Check if it's an orb and has the 'neighbors' data
            if child.is_in_group("orbs") and "neighbors" in child:
                for neighbor in child.neighbors:
                    if is_instance_valid(neighbor):
                        # Draw line from Orb to Neighbor
                        debug_draw_imm.surface_add_vertex(child.global_position)
                        debug_draw_imm.surface_add_vertex(neighbor.global_position)
    
    debug_draw_imm.surface_end()


## Toggles the game's paused state.
func toggle_pause():
    # 1. Prevent unpausing if the game actually ended (Game Over state)
    if not is_game_running and not get_tree().paused:
        return

    # 2. FIRST START FIX: If we are paused and not running, START the game.
    #    This logic is bypassed as the game starts immediately now.
    # if not is_game_running and get_tree().paused:
    #     start_game()
    #     return # RETURN here so we don't run the toggle logic below immediately

    # 3. Standard Toggle (Pause/Unpause during gameplay)
    var is_paused = !get_tree().paused
    get_tree().paused = is_paused

    if is_paused:
        # Paused
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        if pause_menu:
            pause_menu.visible = true
    else:
        # Unpaused
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        if pause_menu:
            pause_menu.visible = false

## Starts the game.
func start_game():
    is_game_running = true
    distance = 0.0

    get_tree().paused = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

    if pause_menu: pause_menu.visible = false
    if game_over_label: 
        game_over_label.visible = false
        game_over_label.text = ""

## Called every frame. Updates the game's state, spawns new chunks, and despawns old chunks.#
# - `delta`: The time since the last frame.
func _process(delta):
    # Don't run logic if paused or player missing
    if get_tree().paused or not is_instance_valid(player_node):
        return

    if is_game_running:
        # 1. Update Distance
        distance += scroll_speed * delta

        # 2. Spawn Check
        if is_instance_valid(last_chunk_end):
            if player_node.global_position.z > last_chunk_end.global_position.z + spawn_trigger_distance:
                spawn_new_chunk(last_chunk_end.global_position, last_chunk_end.global_transform.basis)

        # 3. Despawn old chunks
        if spawned_chunks.size() > 0:
            var first = spawned_chunks[0]
            if player_node.global_position.z - first.global_position.z > despawn_distance:
                remove_chunk(first)


# --- CHUNK GENERATION ---

func initialize_world():
    # Clear old chunks
    for chunk in spawned_chunks: chunk.queue_free()
    spawned_chunks.clear()
    chunks_spawned = 0
    last_chunk_end = null

    # Spawn new chunks
    var pos = Vector3.ZERO
    var spawn_basis = Basis()
    for i in range(initial_chunk_count):
        spawn_new_chunk(pos, spawn_basis)
        if is_instance_valid(last_chunk_end):
            pos = last_chunk_end.global_position
            spawn_basis = last_chunk_end.global_transform.basis
            
    # --- NEW FIX: Force assign the first target ---
    # This ensures the player starts "Locked On" to the rail immediately
    if spawned_chunks.size() > 0:
        var first_chunk = spawned_chunks[0]
        # Look for the first node in the "orbs" group
        for child in first_chunk.get_children():
            if child.is_in_group("orbs"):
                if is_instance_valid(player_node):
                    player_node.current_orb_target = child
                break


## Spawns a new chunk at a given position and with a given basis.
## Spawns a new chunk at a given position and with a given basis.
func spawn_new_chunk(pos: Vector3, spawn_basis: Basis):
    if chunk_scenes.is_empty(): return
    chunks_spawned += 1

    var random_scene = chunk_scenes.pick_random()
    var new_chunk = random_scene.instantiate()

    if new_chunk.get_script() == null:
        new_chunk.set_script(ChunkSpawnerScript)

    add_child(new_chunk)
    new_chunk.global_position = pos
    new_chunk.global_transform.basis = spawn_basis
    spawned_chunks.append(new_chunk)

    # --- 1. CALCULATE DIFFICULTY ---
    # 0.0 = Start, 1.0 = Max Difficulty (reached at 50 chunks)
    var difficulty_factor = clampf(float(chunks_spawned) / 50.0, 0.0, 1.0)

    # Pass this factor to the spawner so it knows how dense to make rocks
    if new_chunk.has_method("set_chunk_difficulty"):
        new_chunk.set_chunk_difficulty(difficulty_factor)
    # -------------------------------

    # --- 2. WIRE THE ORBS ---
    _connect_orbs_in_chunk(new_chunk)
    
    if is_instance_valid(last_spawned_chunk):
        _connect_chunks(last_spawned_chunk, new_chunk)
        
    last_spawned_chunk = new_chunk
    
    # Update visual lines
    #_draw_debug_web() 
    # --------------------------

    # Calculate current ghost probability
    var current_ghost_chance = min(max_ghost_chance, initial_ghost_chance + (chunks_spawned * difficulty_ramp))

    if new_chunk.has_method("spawn_objects_with_difficulty"):
        new_chunk.spawn_objects_with_difficulty(current_ghost_chance)
    elif new_chunk.has_method("spawn_objects"):
        new_chunk.spawn_objects(0, 0)

    var end = new_chunk.find_child("EndAnchor", true, false)
    if end:
        last_chunk_end = end
        connect_orb_signals(new_chunk)


## Connects the `collected` signal of all orbs in a chunk to the `_on_orb_collected_bridge` function.
#
# - `chunk`: The chunk to connect the orb signals from.
func connect_orb_signals(chunk):
    for child in chunk.get_children():
        if child.is_in_group("orbs") and child.has_signal("collected"):
            child.collected.connect(_on_orb_collected_bridge)


## Removes a chunk from the scene.
#
# - `chunk`: The chunk to remove.
func remove_chunk(chunk):
    spawned_chunks.erase(chunk)
    chunk.queue_free()


## Called when an orb is collected. Increases speed AND updates navigation.
# - `_orb`: The orb node that was just hit (contains the neighbors data).
# - `speed_amount`: How much speed to give.
func _on_orb_collected_bridge(_orb, speed_amount):
    
    distance += 50.0
    
    if is_instance_valid(player_node):
        if player_node.has_method("increase_speed"):
            player_node.increase_speed(speed_amount)
            
        if player_node.has_method("find_next_target_from_neighbors"):
            # Pass the orb to the player so they can find the next path
            player_node.find_next_target_from_neighbors(_orb)


## Ends the game and displays the game over screen.
func _game_over():
    if not is_game_running: return
    # Stop Gameplay
    is_game_running = false
    set_process(false)

    # Ensure the scene is frozen and mouse is released
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if pause_menu:
        pause_menu.visible = false
    if game_over_label:
        game_over_label.visible = true
        game_over_label.text = "GAME OVER\nDistance: " + str(int(distance))

# --- WIRING LOGIC ---

## 1. Internal Wiring: Connects orbs INSIDE the same chunk to each other.
func _connect_orbs_in_chunk(chunk: Node3D):
    var orbs = []
    # Find all orbs
    for child in chunk.get_children():
        if child.is_in_group("orbs"):
            # Initialize the neighbor array if it doesn't exist
            if not "neighbors" in child:
                child.set_meta("neighbors", []) # Fallback using metadata if script missing
                # OR ideally your orb script has 'var neighbors = []'
            orbs.append(child)

    # Brute force check: If Orb B is ahead of Orb A and close, connect them.
    for source in orbs:
        for target in orbs:
            if source == target: continue
            
            # Check Direction: Is target ahead? (Assuming -Z is forward)
            var is_ahead = target.global_position.z < source.global_position.z
            
            # Check Distance: Is it reachable? (e.g. 60 units)
            var dist = source.global_position.distance_to(target.global_position)
            
            if is_ahead and dist < 60.0:
                # Add to neighbors list
                if "neighbors" in source:
                    source.neighbors.append(target)

## 2. External Stitching: Connects the END of the old chunk to the START of the new one.
func _connect_chunks(prev_chunk: Node3D, next_chunk: Node3D):
    var prev_orbs = []
    var next_orbs = []
    
    # Get orbs
    for child in prev_chunk.get_children():
        if child.is_in_group("orbs"): prev_orbs.append(child)
    for child in next_chunk.get_children():
        if child.is_in_group("orbs"): next_orbs.append(child)
        
    # Connect gaps
    for p_orb in prev_orbs:
        for n_orb in next_orbs:
            var dist = p_orb.global_position.distance_to(n_orb.global_position)
            # Allow a slightly larger gap between chunks (e.g. 80 units)
            if dist < 80.0:
                if "neighbors" in p_orb:
                    p_orb.neighbors.append(n_orb)
