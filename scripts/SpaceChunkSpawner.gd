# Space Chunk Spawner Script (Attach this to your Chunk Scenes)

extends Node3D

# --- EXTERNAL SCENES (Set these in the Godot Inspector) ---
@export var orb_scene: PackedScene 
@export var obstacle_scene: PackedScene 

# --- SPAWN VOLUME ---
@export_group("Spawn Volume")
@export var spawn_volume_x: float = 10.0 # Width (X-axis) of the spawning zone
@export var spawn_volume_y: float = 10.0 # Height (Y-axis) of the spawning zone
@export var spawn_volume_z: float = 100.0 # Length/depth (Z-axis) of the spawning zone

@export_group("Continuous Spawning")
@export var orb_spawn_interval: float = 0.5 # Time in seconds between orb spawns
@export var rock_spawn_interval: float = 1.5 # Time in seconds between rock spawns

# --- INTERNAL VARIABLES ---
var orb_timer: Timer
var rock_timer: Timer
var generator: Node3D = null # Reference to LevelGenerator

# --- PUBLIC METHOD CALLED BY LEVEL GENERATOR ---

func spawn_objects(_orb_count_unused: int, _rock_count_unused: int):
    """
    Initializes timers to begin continuous spawning within this chunk's volume.
    The LevelGenerator calls this once per chunk, and this script handles the loop.
    """
    # 1. Find the Level Generator using the group (requires LevelGenerator to be in 'level_manager' group)
    generator = get_tree().get_first_node_in_group("level_manager")
    if generator == null:
        push_error("Chunk Spawner cannot find LevelGenerator in 'level_manager' group.")
        # We allow it to continue running, but it won't know the game state
    
    # 2. Setup Orb Timer for Continuous Spawning
    if orb_timer == null:
        orb_timer = Timer.new()
        orb_timer.wait_time = orb_spawn_interval
        orb_timer.autostart = true
        orb_timer.timeout.connect(_on_orb_timer_timeout)
        add_child(orb_timer)
    
    # 3. Setup Rock Timer for Continuous Obstacle Spawning
    if rock_timer == null:
        rock_timer = Timer.new()
        rock_timer.wait_time = rock_spawn_interval
        rock_timer.autostart = true
        rock_timer.timeout.connect(_on_rock_timer_timeout)
        add_child(rock_timer)
    
    # Ensure timers are running
    orb_timer.start()
    rock_timer.start()
    
func _on_orb_timer_timeout():
    # Only spawn if the game is actually running
    var is_game_running = true
    if is_instance_valid(generator):
        is_game_running = generator.is_game_running
        
    if is_game_running:
        _spawn_entity(orb_scene, "orbs")

func _on_rock_timer_timeout():
    # Only spawn if the game is actually running
    var is_game_running = true
    var chunks_spawned = 0
    if is_instance_valid(generator):
        is_game_running = generator.is_game_running
        chunks_spawned = generator.chunks_spawned
    
    if is_game_running:
        # Simple difficulty gating: only spawn obstacles after the player has survived 5 chunks
        if chunks_spawned > 5:
            _spawn_entity(obstacle_scene, "obstacles")

func _spawn_entity(scene: PackedScene, group_name: String):
    """Helper function to instantiate and place a single entity."""
    if not is_instance_valid(scene):
        push_error("Spawn scene is not set for %s! Check the Chunk Scene Inspector." % group_name)
        return
        
    var new_entity = scene.instantiate()
    
    # 1. Random Placement within the chunk's volume
    var rand_x = randf_range(-spawn_volume_x / 2.0, spawn_volume_x / 2.0)
    var rand_y = randf_range(-spawn_volume_y / 2.0, spawn_volume_y / 2.0)
    
    # 2. Place along the Z-axis (length of the chunk)
    # Spawn in the far third of the chunk volume to give the player time to react
    var rand_z = randf_range(-spawn_volume_z * 0.7, -spawn_volume_z * 0.3)
    
    new_entity.position = Vector3(rand_x, rand_y, rand_z)
    
    # 3. Add entity as a child of this chunk
    add_child(new_entity)
    new_entity.add_to_group(group_name)

# Stop timers when the chunk is removed
func _exit_tree():
    if is_instance_valid(orb_timer):
        orb_timer.stop()
        orb_timer.queue_free()
    if is_instance_valid(rock_timer):
        rock_timer.stop()
        rock_timer.queue_free()
