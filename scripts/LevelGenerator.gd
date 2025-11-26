## Manages the procedural generation of the game level, including spawning chunks, handling game state, and managing UI elements.
#
# This script is responsible for creating an infinitely scrolling level by spawning and despawning chunks of the level.
# It also manages the game's state, such as pausing and game over, and controls the visibility of UI elements.
# The difficulty of the game is also managed by this script, which increases the chance of spawning ghosts over time.
extends Node3D

# --- GAME STATE ---
## The speed at which the level scrolls.
@export var scroll_speed: float = 30.0
## The distance the player has traveled.
var distance: float = 0.0
## A boolean value that is true if the game is currently running, and false otherwise.
var is_game_running: bool = false

# --- SCENE REFERENCES ---
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
## A reference to the pause menu.
var pause_menu: Control
## A reference to the game over label.
var game_over_label: Label

## Called when the node is added to the scene. Initializes the level generator, sets up the UI, and starts the game in a paused state.
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

## Handles unhandled input events for pausing the game.
#
# - `event`: The input event to handle.
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		toggle_pause()

## Toggles the game's paused state.
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

## Starts the game.
func start_game():
	print("Game Started!")
	is_game_running = true
	distance = 0.0

	# Unpause and Capture Mouse
	get_tree().paused = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if pause_menu: pause_menu.visible = false
	if game_over_label: game_over_label.text = ""

## Called every frame. Updates the game's state, spawns new chunks, and despawns old chunks.
#
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
			var dist = player_node.global_position.distance_to(last_chunk_end.global_position)
			if dist < spawn_trigger_distance:
				spawn_new_chunk(last_chunk_end.global_position, last_chunk_end.global_transform.basis)

		# 3. Despawn old chunks
		if spawned_chunks.size() > 0:
			var first = spawned_chunks[0]
			if player_node.global_position.z - first.global_position.z > despawn_distance:
				remove_chunk(first)

# --- UI HELPERS ---

## Initializes the references to the UI elements.
func _init_ui_references():
	var root = get_tree().root.get_child(0)
	if root:
		pause_menu = root.find_child("PauseMenu", true, false)
		game_over_label = root.find_child("GameOverLabel", true, false)
		if not pause_menu:
			print("LevelGenerator: 'PauseMenu' node not found (UI will not show).")

# --- CHUNK GENERATION ---

## Initializes the world by spawning the initial chunks.
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

## Spawns a new chunk at a given position and with a given basis.
#
# - `pos`: The position at which to spawn the chunk.
# - `spawn_basis`: The basis to use for the chunk's transform.
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

## Called when an orb is collected. Increases the player's speed and distance.
#
# - `_orb`: The orb that was collected.
# - `speed_amount`: The amount to increase the player's speed by.
func _on_orb_collected_bridge(_orb, speed_amount):
	distance += 50.0
	if is_instance_valid(player_node) and player_node.has_method("increase_speed"):
		player_node.increase_speed(speed_amount)

## Ends the game and displays the game over screen.
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
