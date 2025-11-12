# res://scripts/Angel.gd
# FINAL VERSION: Direct movement, speed decay, and public accessors for compatibility
extends Area3D

# Signals
signal speed_changed(new_speed: float)

# Node References
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh

# Exported Properties
@export var turn_speed: float = 3.0
@export var max_h_offset := 20.0
@export var h_move_speed := 15.0
@export var max_health := 100
@export var damage_amount := 25

@export var speed :=30
@export var min_speed := 20
@export var speed_decay := 1.0
@export var max_speed := 60.0

# State Management
enum Lane {LEFT=1, CENTER=0, RIGHT=-1}
enum State {RUNNING, JUMPING, SLIDING, DEAD}

var targetLane : int = Lane.CENTER
var currentLane : int = Lane.CENTER

var current_health := max_health
var target_h_offset := 0.0
var target_yaw: float = 0.0
var velocity := Vector3.ZERO


func _ready():
    set_process_mode(Node.PROCESS_MODE_ALWAYS)
    camera.make_current()
    
    # Setup
    collision_layer = 1
    collision_mask = 1
    monitoring = true
    monitorable = true
    area_entered.connect(_on_area_entered)
    
    # Camera setup (FIXED TO REMOVE TILT)
    spring_arm.position = Vector3(0, 2, 0)
    
    # FIX: Ensure the SpringArm has no pitch, yaw, or roll
    spring_arm.rotation_degrees = Vector3(0, 0, 0)
    
    camera.position = Vector3(0, 0, 30)
    
    # FIX: Ensure the Camera has no pitch, yaw, or roll
    camera.rotation_degrees = Vector3(0, 0, 0)


func take_damage(amount):
    current_health = max(current_health - amount, 0)
    print("Health: ", current_health)
    if current_health <= 0:
        game_over()

 
func game_over():
    print("Game Over!")
    
    # 1. Check if the node is still valid and has access to the SceneTree
    if not is_instance_valid(self) or not is_inside_tree():
        print("Angel node is not in the tree or invalid; cannot proceed with game_over.")
        return
    
    # 2. Get the tree only after validation
    var tree = get_tree()
    if not tree:
        return
        
    # Stop the game
    tree.paused = true
    
    await tree.create_timer(2.0).timeout
    tree.reload_current_scene() # Restart the level


func _process(delta):
    var input_dir = Input.get_axis("ui_right", "ui_left")
    
    # Corrected: Multiply input_dir by -1 to reverse movement direction.
    target_h_offset = clamp(
        target_h_offset + (-input_dir) * h_move_speed * delta, 
        -max_h_offset, 
        max_h_offset
    )

    # Yaw steering input (currently unused for movement)
    var steer = 0.0
    if Input.is_physical_key_pressed(KEY_Q):
        steer -= 90.0 * delta
    if Input.is_physical_key_pressed(KEY_E):
        steer += 90.0 * delta
    target_yaw += steer


func _physics_process(delta):
    # --- Speed Decay Logic ---
    speed = max(min_speed, speed - speed_decay * delta)
    speed_changed.emit(speed) # Emit signal to update UI
    # -------------------------

    # 1. Forward Movement
    velocity = -transform.basis.z * speed
    
    # 2. Horizontal Movement (Interpolate to target_h_offset on the X-axis)
    var current_x = global_position.x
    var new_x = lerp(current_x, target_h_offset, 10.0 * delta)
    
    # 3. Apply the movement
    global_position += velocity * delta
    global_position.x = new_x

## Public Accessors (for LevelGenerator and UI)

func get_speed() -> float:
    return speed

func set_speed(new_speed: float):
    speed = min(max_speed, max(min_speed, new_speed))
    speed_changed.emit(speed)
    
func get_min_speed() -> float:
    return min_speed

func get_max_speed() -> float:
    return max_speed

## Collision Handling

func _on_area_entered(area):
    if area.is_in_group("orbs"):
        # Increase speed and clamp it to max_speed
        var speed_increase_amount = 1.0 
        speed = min(max_speed, speed + speed_increase_amount)
        speed_changed.emit(speed) # Emit signal to update UI
        print("Angel: Speed increased to ", speed)
        
        area.queue_free()
    elif area.is_in_group("obstacles"):
        take_damage(damage_amount)
        area.queue_free()
