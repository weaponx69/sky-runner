# Space Chunk Spawner Script (Attach this to your Chunk Scenes)
# FIX: Removed strict typing on 'generator' to fix the parsing error that hid the Inspector slots.
# FIX: Implemented continuous timer-based spawning for steady orb flow.

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

# FIX: Removed ": Node3D" type hint. This allows us to access custom properties 
# like 'is_game_running' without causing an editor parsing error.
var generator = null 

func _ready():
    # Debug check to help you see if slots are empty
    if not orb_scene:
        push_warning("SpaceChunkSpawner: 'Orb Scene' slot is empty in Inspector!")
    if not obstacle_scene:
        push_warning("SpaceChunkSpawner: 'Obstacle Scene' slot is empty in Inspector!")

# --- PUBLIC METHOD CALLED BY LEVEL GENERATOR ---

func spawn_objects(_orb_count_unused: int, _rock_count_unused: int):
    """
    Initializes timers to begin continuous spawning within this chunk's volume.
    """
    # 1. Find the Level Generator using the group
    generator = get_tree().get_first_node_in_group("level_manager")
    if generator == null:
        push_error("Chunk Spawner cannot find LevelGenerator in 'level_manager' group.")
        return

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
    var is_running = false
    if is_instance_valid(generator):
        # We can now access this property safely because generator is dynamic
        is_running = generator.is_game_running
        
    if is_running:
        _spawn_entity(orb_scene, "orbs")

func _on_rock_timer_timeout():
    var is_running = false
    var chunks_count = 0
    
    if is_instance_valid(generator):
        is_running = generator.is_game_running
        chunks_count = generator.chunks_spawned
    
    if is_running:
        # Simple difficulty gating: only spawn obstacles after 5 chunks
        if chunks_count > 5:
            _spawn_entity(obstacle_scene, "obstacles")

func _spawn_entity(scene: PackedScene, group_name: String):
    """Helper function to instantiate and place a single entity."""
    if not is_instance_valid(scene):
        return
        
    var new_entity = scene.instantiate()
    
    # 1. Random Placement within the chunk's volume
    var rand_x = randf_range(-spawn_volume_x / 2.0, spawn_volume_x / 2.0)
    var rand_y = randf_range(-spawn_volume_y / 2.0, spawn_volume_y / 2.0)
    
    # 2. Place along the Z-axis (length of the chunk)
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
