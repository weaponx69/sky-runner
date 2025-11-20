# Angel Player Script (Attach to a CharacterBody3D node)

extends CharacterBody3D

# Signals
signal speed_changed(new_speed: float)

# Node References
# NOTE: Camera setup should ideally be children of the CharacterBody3D
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
    
    # 2. Camera Setup (as in your original script)
    camera.make_current()
    
    spring_arm.position = Vector3(0, 2, 0)
    spring_arm.rotation_degrees = Vector3(0, 0, 0)
    
    camera.position = Vector3(0, 0, 30)
    camera.rotation_degrees = Vector3(0, 0, 0)
    
    # NOTE: Since we changed to CharacterBody3D, we listen for a different collision signal.
    # We will use the 'body_entered' signal from the Orb/Obstacle Area3D nodes instead.

# --- GAME OVER AND HEALTH ---

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
        # Fallback to reload if generator is missing (as in your original script)
        get_tree().paused = true
        await get_tree().create_timer(2.0).timeout
        get_tree().reload_current_scene()

# --- INPUT (WASD mapping for lateral movement) ---

func _process(delta):
    # This remains for steering the player mesh or interpolation
    # Yaw steering input
    var steer = 0.0
    if Input.is_physical_key_pressed(KEY_Q):
        steer -= 90.0 * delta
    if Input.is_physical_key_pressed(KEY_E):
        steer += 90.0 * delta
    # You would typically apply this to the rotation_degrees.y or spring_arm.rotation_degrees.y
    pass

func _physics_process(delta):
    # 1. Speed Decay (The core inverse runner mechanic)
    speed = max(min_speed, speed - speed_decay * delta)
    speed_changed.emit(speed) # Emit signal to update UI
    
    # Check for game over condition based on speed decay
    if speed <= min_speed:
        _trigger_game_over()

    # 2. Forward Movement (Always forward along the local Z axis)
    # The CharacterBody3D uses 'velocity' for movement
    velocity.z = -speed
    
    # 3. Horizontal Movement (Reading WASD/UI input for strafing)
    var input_dir_x = Input.get_axis("ui_left", "ui_right")
    var input_dir_y = Input.get_axis("ui_down", "ui_up")
    
    # Calculate lateral velocity (X and Y movement based on WASD)
    velocity.x = input_dir_x * h_move_speed
    velocity.y = input_dir_y * h_move_speed

    # 4. Apply Physics Movement and Collision
    move_and_slide()
    
    # 5. Apply Boundary Checks (using clamped global_position)
    _apply_boundaries()

# --- HELPER FUNCTIONS ---

func _apply_boundaries():
    var new_pos = global_position
    var half_width = max_h_offset # Using max_h_offset as the boundary limit
    
    # Clamp X (Horizontal)
    new_pos.x = clampf(new_pos.x, -half_width, half_width)
    
    # Clamp Y (Vertical) - Adjust this based on your camera view limits
    var half_height = half_width # Assuming Y bounds are similar to X bounds
    new_pos.y = clampf(new_pos.y, -half_height, half_height) 
    
    global_position = new_pos

# --- PUBLIC METHODS FOR ORB INTERACTION ---

func increase_speed(amount: float):
    """Called by the Orb script to instantly restore forward momentum."""
    speed = min(max_speed, speed + amount)
    speed_changed.emit(speed)
    
# --- PUBLIC GETTERS (Useful for the Level Generator) ---

func get_speed() -> float:
    return speed

func get_max_speed() -> float:
    return max_speed

# NOTE: The _on_area_entered function is obsolete for a CharacterBody3D.
# The Orb/Obstacle Area3D nodes will now check for *this* CharacterBody3D entering them.
# I've kept the logic for clarity if you choose to attach this to a parent Area3D later.
