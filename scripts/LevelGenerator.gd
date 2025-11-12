# res://scripts/LevelGenerator.gd
# FINAL VERSION: Manages infinite procedural generation and dynamic content density.

extends Node3D

# --- CHUNK MANAGEMENT PROPERTIES ---

@export var chunk_scenes: Array[PackedScene] 
@export var initial_chunk_count: int = 4
@export var despawn_distance: float = 50.0
@export var spawn_trigger_distance: float = 100.0

# --- DYNAMIC DIFFICULTY PARAMETERS (NEW/MODIFIED) ---
@export var base_orb_count: float = 3.0           # Orbs to spawn in the first chunk
@export var base_rock_count: float = 3.0          # Rocks to spawn in the first chunk
@export var difficulty_increase_rate: float = 0.05 # How fast density increases (per chunk)
@export var max_chunk_content: float = 40.0       # Maximum total objects per chunk

# --- INTERNAL VARIABLES ---

var player_node: Node3D
var last_chunk_end: Marker3D = null 
var spawned_chunks: Array[Node3D] = [] 
var chunks_spawned: int = 0 # Tracks player progress

# --- CORE FUNCTIONS ---

func _ready():
    randomize()
    
    # Find the Angel player node
    player_node = get_tree().get_first_node_in_group("player") 
    if not player_node:
        push_error("Player node not found! Ensure the Angel scene is in the 'player' group.")
        set_process(false)
        return
        
    initialize_world()

func _process(_delta):
    if not is_instance_valid(player_node):
        return

    # 1. Spawn Check
    if is_instance_valid(last_chunk_end):
        var distance_to_end = player_node.global_position.distance_to(last_chunk_end.global_position)
        if distance_to_end < spawn_trigger_distance:
            spawn_new_chunk(last_chunk_end.global_position, last_chunk_end.global_transform.basis)

    # 2. Despawn Check
    if spawned_chunks.size() > 0:
        var first_chunk = spawned_chunks[0]
        var distance_behind = player_node.global_position.z - first_chunk.global_position.z
        if distance_behind > despawn_distance:
            remove_chunk(first_chunk)


## 🏗️ CHUNK GENERATION AND MANAGEMENT

func initialize_world():
    var current_position = Vector3.ZERO
    var current_basis = Basis()
    
    for i in range(initial_chunk_count):
        spawn_new_chunk(current_position, current_basis)
        
        if is_instance_valid(last_chunk_end):
            current_position = last_chunk_end.global_position
            current_basis = last_chunk_end.global_transform.basis

func spawn_new_chunk(spawn_position: Vector3, spawn_basis: Basis):
    if chunk_scenes.is_empty():
        push_error("Chunk Scenes array is empty! Cannot generate world.")
        return
        
    # 1. Calculate Content Counts (NEW LOGIC)
    chunks_spawned += 1
    var difficulty_multiplier = float(chunks_spawned) * difficulty_increase_rate
    
    var target_orb_count = base_orb_count * (1.0 + difficulty_multiplier)
    var target_rock_count = base_rock_count * (1.0 + difficulty_multiplier)
    
    var total_content = target_orb_count + target_rock_count
    
    # Clamp total content to prevent infinite growth (Optional safety cap)
    if total_content > max_chunk_content:
        var scale_factor = max_chunk_content / total_content
        target_orb_count *= scale_factor
        target_rock_count *= scale_factor
        
    # Final Conversion to Integers
    var final_orb_count = roundi(target_orb_count)
    var final_rock_count = roundi(target_rock_count)
    
    # 2. Instantiate and Position Chunk
    var random_scene = chunk_scenes.pick_random()
    var new_chunk = random_scene.instantiate()
    add_child(new_chunk)
    spawned_chunks.append(new_chunk)
    
    new_chunk.global_position = spawn_position
    new_chunk.global_transform.basis = spawn_basis
    
    # 3. Call the Spawner Script (NEW CALL)
    # The new_chunk must have the spawn_objects function defined (SpaceChunkSpawner.gd)
    if new_chunk.has_method("spawn_objects"):
        new_chunk.spawn_objects(final_orb_count, final_rock_count)
    else:
         push_error("Chunk missing required 'spawn_objects' function!")

    # 4. Find Anchor and Connect Signals
    var end_anchor = new_chunk.find_child("EndAnchor", true, false) as Marker3D
    
    if is_instance_valid(end_anchor):
        connect_orb_signals(new_chunk)
        last_chunk_end = end_anchor
    else:
        push_error("Chunk missing required 'EndAnchor' Marker3D! Generation will fail.")

func remove_chunk(chunk: Node3D):
    spawned_chunks.erase(chunk)
    chunk.queue_free()

func connect_orb_signals(chunk: Node3D):
    # Iterate through all children of the chunk to find orbs
    for child in chunk.get_children():
        if child.is_in_group("orbs") and child.has_signal("collected"):
            child.collected.connect(_on_orb_collected)


# --- PLAYER INTERACTION ---

func _on_orb_collected(_orb = null, speed_amount = 1.0):
    if is_instance_valid(player_node):
        if player_node.has_method("get_speed") and player_node.has_method("set_speed") and player_node.has_method("get_max_speed"):
            var current_speed = player_node.get_speed()
            var max_speed = player_node.get_max_speed()
            
            var new_speed = min(max_speed, current_speed + speed_amount)
            player_node.set_speed(new_speed)
            print("LevelGenerator: Player speed increased to ", new_speed)
    else:
        push_warning("Cannot increase player speed: Player node is not valid.")
