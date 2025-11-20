# Angel Player Script (Attach to a CharacterBody3D node)

extends CharacterBody3D

# Signals
signal speed_changed(new_speed: float)

# Node References
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh

# --- EXPORTED PROPERTIES ---
@export_group("Control & Health")
@export var turn_speed: float = 3.0
@export var max_h_offset: float = 20.0
@export var h_move_speed: float = 15.0
@export var max_health: int = 100
@export var damage_amount: int = 25

@export_group("Speed Decay Mechanics")
@export var speed: float = 30.0
@export var min_speed: float = 20.0
@export var speed_decay: float = 1.0
@export var max_speed: float = 60.0

# --- STATE MANAGEMENT ---
var current_health: int = max_health

# --- GODOT LIFECYCLE ---

func _ready():
    # 1. Ensure this node is in the 'player' group for collision detection
    add_to_group("player")
    
    # 2. Camera Setup
    if camera:
        camera.make_current()
        camera.position = Vector3(0, 0, 30)
        camera.rotation_degrees = Vector3(0, 0, 0)
    
    if spring_arm:
        spring_arm.position = Vector3(0, 2, 0)
        spring_arm.rotation_degrees = Vector3(0, 0, 0)

func take_damage(amount: int):
    current_health = max(current_health - amount, 0)
    print("Health: ", current_health)
    if current_health <= 0:
        _trigger_game_over()

func _trigger_game_over():
    """Triggers the game over sequence by calling the Level Generator."""
    print("Game Over! Speed or Health reached zero.")
    
    # Find the Level Generator/Game Manager using the group
    var generator = get_tree().get_first_node_in_group("level_manager")
    if generator and generator.has_method("_game_over"):
        generator._game_over()
    else:
        # Fallback to reload if generator is missing
        get_tree().paused = true
        await get_tree().create_timer(2.0).timeout
        get_tree().reload_current_scene()

func _process(_delta):
    # Placeholder for future cosmetic updates (e.g. banking animation)
    pass

func _physics_process(delta):
    # 1. Speed Decay (The core inverse runner mechanic)
    speed = max(min_speed, speed - speed_decay * delta)
    speed_changed.emit(speed) # Emit signal to update UI
    
    # Check for game over condition based on speed decay
    if speed <= min_speed:
        _trigger_game_over()

    # 2. Forward Movement (Always forward along the local Z axis)
    velocity.z = -speed
    
    # 3. Horizontal Movement (Reading WASD/UI input for strafing)
    var input_dir_x = Input.get_axis("ui_left", "ui_right")
    var input_dir_y = Input.get_axis("ui_down", "ui_up")
    
    # Calculate lateral velocity (X and Y movement based on WASD)
    velocity.x = input_dir_x * h_move_speed
    velocity.y = input_dir_y * h_move_speed

    # 4. Apply Physics Movement and Collision
    move_and_slide()
    
    # 5. Apply Boundary Checks
    _apply_boundaries()

func _apply_boundaries():
    var new_pos = global_position
    var half_width = max_h_offset 
    
    new_pos.x = clampf(new_pos.x, -half_width, half_width)
    
    var half_height = half_width 
    new_pos.y = clampf(new_pos.y, -half_height, half_height) 
    
    global_position = new_pos

# --- PUBLIC METHODS FOR ORB INTERACTION ---

func increase_speed(amount: float):
    """Called by the Orb script to instantly restore forward momentum."""
    speed = min(max_speed, speed + amount)
    speed_changed.emit(speed)

func get_speed() -> float:
    return speed

func get_max_speed() -> float:
    return max_speed
