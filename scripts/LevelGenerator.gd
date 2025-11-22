# LevelGenerator.gd
# FIX: Game Over stops gameplay logic but keeps the engine running (No Pause).
# FIX: Manages global difficulty (chunks_spawned) for the spawners.

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

# --- CHUNK CONFIG ---
@export var initial_chunk_count: int = 4
@export var despawn_distance: float = 50.0
@export var spawn_trigger_distance: float = 100.0

# --- VARIABLES ---
const ChunkSpawnerScript = preload("res://scripts/SpaceChunkSpawner.gd")
var player_node: Node3D
var last_chunk_end: Marker3D = null 
var spawned_chunks: Array[Node3D] = [] 
var chunks_spawned: int = 0 

func _ready():
    add_to_group("level_manager")
    randomize()
    
    player_node = get_tree().get_first_node_in_group("player") 
    if not player_node:
        push_error("LevelGenerator: Player node not found!")
        set_process(false)
        return
        
    initialize_world()
    
    # Auto-start
    print("Level Generator: Ready. Starting...")
    start_game() 

func _process(delta):
    if not is_instance_valid(player_node): return
        
    if is_game_running:
        # 1. Update Distance
        distance += scroll_speed * delta 
        
        # 2. Check for new chunks
        if is_instance_valid(last_chunk_end):
            var dist = player_node.global_position.distance_to(last_chunk_end.global_position)
            if dist < spawn_trigger_distance:
                spawn_new_chunk(last_chunk_end.global_position, last_chunk_end.global_transform.basis)

        # 3. Despawn old chunks
        if spawned_chunks.size() > 0:
            var first = spawned_chunks[0]
            if player_node.global_position.z - first.global_position.z > despawn_distance:
                remove_chunk(first)

func initialize_world():
    for chunk in spawned_chunks: chunk.queue_free()
    spawned_chunks.clear()
    chunks_spawned = 0
    last_chunk_end = null
    
    var pos = Vector3.ZERO
    var basis = Basis()
    for i in range(initial_chunk_count):
        spawn_new_chunk(pos, basis)
        if is_instance_valid(last_chunk_end):
            pos = last_chunk_end.global_position
            basis = last_chunk_end.global_transform.basis

func spawn_new_chunk(pos: Vector3, basis: Basis):
    if chunk_scenes.is_empty(): return
    
    chunks_spawned += 1
    
    var random_scene = chunk_scenes.pick_random()
    var new_chunk = random_scene.instantiate()
    
    if new_chunk.get_script() == null:
        new_chunk.set_script(ChunkSpawnerScript)
    
    add_child(new_chunk)
    new_chunk.global_position = pos
    new_chunk.global_transform.basis = basis
    spawned_chunks.append(new_chunk)
    
    # Start Spawner
    if new_chunk.has_method("spawn_objects"):
        new_chunk.spawn_objects(0, 0)
    
    # Connect Signals
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
    distance += 50.0 # Bonus score
    if is_instance_valid(player_node) and player_node.has_method("increase_speed"):
        player_node.increase_speed(speed_amount)

func _game_over():
    if not is_game_running: return
    print("--- GAME ENDED --- Final Distance: ", int(distance))
    
    # Stop Gameplay Logic
    is_game_running = false
    set_process(false)
    
    # Do NOT pause the tree (animations can continue if desired), just stop logic.
    get_tree().paused = false

func start_game():
    is_game_running = true
    distance = 0.0
    set_process(true)
