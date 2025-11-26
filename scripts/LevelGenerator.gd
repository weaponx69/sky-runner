# LevelGenerator.gd
# FIX: Corrected 'toggle_pause' logic so it doesn't immediately re-pause after starting.
# FIX: Re-added UI visibility toggling (showing/hiding the menu).

extends Node3D

# --- GAME STATE ---
@export var scroll_speed: float = 30.0 
var distance: float = 0.0
var is_game_running: bool = false

# --- SCENE REFERENCES ---
@export_group("Scene Management")
@export var chunk_scenes: Array[PackedScene] 
@export var orb_scene: PackedScene          
@export var obstacle_scene: PackedScene
@export var ghost_scene: PackedScene

# --- CHUNK CONFIG ---
@export var initial_chunk_count: int = 4
@export var despawn_distance: float = 50.0
@export var spawn_trigger_distance: float = 100.0

# --- DYNAMIC DIFFICULTY ---
# Chance (0.0 to 1.0) that an Orb spot becomes a Ghost
@export var initial_ghost_chance: float = 0.05 
@export var max_ghost_chance: float = 0.3
@export var difficulty_ramp: float = 0.01 # How much ghost chance increases per chunk

# --- VARIABLES ---
const ChunkSpawnerScript = preload("res://scripts/SpaceChunkSpawner.gd")
var player_node: Node3D
var last_chunk_end: Marker3D = null 
var spawned_chunks: Array[Node3D] = [] 
var chunks_spawned: int = 0 

# --- UI VARIABLES ---
var pause_menu: Control
var game_over_label: Label

func _ready():
    # CRITICAL: Allow this node to run while the tree is paused
    process_mode = Node.PROCESS_MODE_ALWAYS
    
    add_to_group("level_manager")
    randomize()
    
    _init_ui_references()
    
    player_node = get_tree().get_first_node_in_group("player") 
    if not player_node:
        push_error("LevelGenerator: Player node not found!")
        return
        
    initialize_world()
    
    # Start in PAUSED state
    print("Level Generator: Ready. Press Space to Start.")
    get_tree().paused = true
    is_game_running = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    # Show menu initially
    if pause_menu: pause_menu.visible = true

func _unhandled_input(event):
    if event.is_action_pressed("ui_accept"):
        toggle_pause()

func toggle_pause():
    # 1. Prevent unpausing if the game actually ended (Game Over state)
    if not is_game_running and not get_tree().paused:
        return 
    
    # 2. FIRST START FIX: If we are paused and not running, START the game.
    if not is_game_running and get_tree().paused:
        start_game()
        return # RETURN here so we don't run the toggle logic below immediately

    # 3. Standard Toggle (Pause/Unpause during gameplay)
    var is_paused = !get_tree().paused
    get_tree().paused = is_paused
    
    if is_paused:
        # Paused
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        if pause_menu: pause_menu.visible = true
        print("Game Paused")
    else:
        # Unpaused
        #Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        if pause_menu: pause_menu.visible = false
        print("Game Resumed")

func start_game():
    print("Game Started!")
    is_game_running = true
    distance = 0.0
    
    # Unpause and Capture Mouse
    get_tree().paused = false
    #Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
    if pause_menu: pause_menu.visible = false
    if game_over_label: game_over_label.text = ""

func _process(delta):
    # Don't run logic if paused or player missing
    if get_tree().paused or not is_instance_valid(player_node): 
        return
        
    if is_game_running:
        # 1. Update Distance
        distance += scroll_speed * delta 
        
        # 2. Spawn Check
        if is_instance_valid(last_chunk_end):
            var dist = player_node.global_position.distance_to(last_chunk_end.global_position)
            if dist < spawn_trigger_distance:
                spawn_new_chunk(last_chunk_end.global_position, last_chunk_end.global_transform.basis)

        # 3. Despawn old chunks
        if spawned_chunks.size() > 0:
            var first = spawned_chunks[0]
            if player_node.global_position.z - first.global_position.z > despawn_distance:
                remove_chunk(first)

# --- UI HELPERS ---

func _init_ui_references():
    var root = get_tree().root.get_child(0)
    if root:
        pause_menu = root.find_child("PauseMenu", true, false)
        game_over_label = root.find_child("GameOverLabel", true, false)
        if not pause_menu:
            print("LevelGenerator: 'PauseMenu' node not found (UI will not show).")

# --- CHUNK GENERATION ---

func initialize_world():
    for chunk in spawned_chunks: chunk.queue_free()
    spawned_chunks.clear()
    chunks_spawned = 0
    last_chunk_end = null
    
    var pos = Vector3.ZERO
    var spawn_basis = Basis()
    for i in range(initial_chunk_count):
        spawn_new_chunk(pos, spawn_basis)
        if is_instance_valid(last_chunk_end):
            pos = last_chunk_end.global_position
            spawn_basis = last_chunk_end.global_transform.basis


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
    
    # Calculate current ghost probability
    var current_ghost_chance = min(max_ghost_chance, initial_ghost_chance + (chunks_spawned * difficulty_ramp))
    
    # Pass difficulty info to Spawner
    if new_chunk.has_method("spawn_objects_with_difficulty"):
        # We pass the calculated chance for the spawner to use
        new_chunk.spawn_objects_with_difficulty(current_ghost_chance)
    elif new_chunk.has_method("spawn_objects"):
        # Fallback to base call if difficulty logic is disabled
        new_chunk.spawn_objects(0, 0)
    
    var end = new_chunk.find_child("EndAnchor", true, false)
    if end: 
        last_chunk_end = end
        connect_orb_signals(new_chunk)


func connect_orb_signals(chunk):
    for child in chunk.get_children():
        if child.is_in_group("orbs") and child.has_signal("collected"):
            child.collected.connect(_on_orb_collected_bridge)


func remove_chunk(chunk):
    spawned_chunks.erase(chunk)
    chunk.queue_free()

func _on_orb_collected_bridge(_orb, speed_amount):
    distance += 50.0
    if is_instance_valid(player_node) and player_node.has_method("increase_speed"):
        player_node.increase_speed(speed_amount)

func _game_over():
    if not is_game_running: return
    print("--- GAME ENDED --- Final Distance: ", int(distance))
    
    # Stop Gameplay
    is_game_running = false
    set_process(false)
    
    # Ensure the scene is frozen and mouse is released
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    if pause_menu: pause_menu.visible = true
    if game_over_label: 
        game_over_label.text = "GAME OVER\nDistance: " + str(int(distance))
