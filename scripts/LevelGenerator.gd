## Manages the procedural generation of the game level.
#
# This script is responsible for creating an infinitely scrolling level by spawning
# and despawning chunks of the maze.
extends Node3D

# --- GAME STATE ---
## The speed at which the level scrolls.
## The distance the player has traveled.
var distance: float = 0.0
## A boolean value that is true if the game is currently running, and false otherwise.
var is_game_running: bool = false

# --- SCENE REFERENCES ---
@export var scroll_speed: float = 30.0

@export_group("Debugging")
@export var show_debug_walls: bool = true

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
@export var initial_chunk_count: int = 5
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


## Called when the node is added to the scene. Initializes the level generator.
func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    add_to_group("level_manager")

    player_node = get_tree().get_first_node_in_group("player")
    if not player_node:
        push_error("LevelGenerator: Player node not found!")
        return

    initialize_world()

    # Bypass "start paused" for now. Game starts immediately running.
    get_tree().paused = false
    is_game_running = true
    
    GameStateEvents.game_over.connect(_game_over)
    GameStateEvents.toggle_pause_requested.connect(toggle_pause)


## Toggles the game's paused state.
func toggle_pause():
    # Prevent unpausing if the game actually ended (Game Over state)
    if not is_game_running and not get_tree().paused:
        return

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

## Called every frame. Updates the game's state, spawns new chunks, and despawns old chunks.
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
                spawn_new_chunk(last_chunk_end.global_position, Basis.IDENTITY)

        # 3. Despawn old chunks
        var current_chunk = get_player_chunk()
        if is_instance_valid(current_chunk):
            var current_index = spawned_chunks.find(current_chunk)
            # We want to keep 1 chunk behind the current one.
            # Chunks are ordered by spawn time, so older chunks (larger z) are at the front.
            if current_index > 0:
                var chunks_to_remove_count = current_index - 1
                for i in range(chunks_to_remove_count):
                    remove_chunk(spawned_chunks[0]) # Repeatedly remove the oldest chunk


# --- CHUNK GENERATION ---
func initialize_world():
    # Clear old chunks
    for chunk in spawned_chunks: chunk.queue_free()
    spawned_chunks.clear()
    chunks_spawned = 0
    last_chunk_end = null

    # Spawn new chunks
    var pos = Vector3.ZERO
    for i in range(initial_chunk_count):
        spawn_new_chunk(pos, Basis.IDENTITY)
        if is_instance_valid(last_chunk_end):
            pos = last_chunk_end.global_position

func get_player_chunk() -> Node3D:
    if not is_instance_valid(player_node): return null
            
    # Fallback: Check player's physical position against all chunk bounds
    for chunk in spawned_chunks:
        var chunk_len_variant = chunk.get("spawn_volume_z")
        if chunk_len_variant == null:
            continue

        var chunk_len : float = chunk_len_variant
        var start_z = chunk.global_position.z
        var end_z = start_z - chunk_len
        
        # Check if player is within the Z bounds of this chunk
        if player_node.global_position.z <= start_z and player_node.global_position.z > end_z:
            return chunk
            
    return null # Player is not in any known chunk








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

    if new_chunk.has_method("set_chunk_difficulty"):
        new_chunk.set_chunk_difficulty(difficulty_factor)
        
    if new_chunk.has_method("set_orb_scene"):
        new_chunk.set_orb_scene(orb_scene)
        
    if new_chunk.has_method("set_debug_wall_visibility"):
        new_chunk.set_debug_wall_visibility(show_debug_walls)
    # -------------------------------

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


## Connects the `collected` signal of all orbs in a chunk.
func connect_orb_signals(chunk):
    for child in chunk.get_children():
        if child.is_in_group("orbs") and child.has_signal("collected"):
            child.collected.connect(_on_orb_collected_bridge)


## Removes a chunk from the scene.
func remove_chunk(chunk):
    spawned_chunks.erase(chunk)
    chunk.queue_free()


## Called when an orb is collected to grant a speed boost.
func _on_orb_collected_bridge(_orb, _speed_amount):
    if is_instance_valid(player_node) and player_node.has_method("add_speed_boost"):
        player_node.add_speed_boost()


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
