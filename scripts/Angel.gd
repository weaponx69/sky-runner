# Angel Player Script
# FIX: Refactored Auto-Aim to use a weighted score (Alignment vs Distance).
# FIX: Allows player to override "Closest" logic by steering towards specific orbs.

extends CharacterBody3D

# Signals
signal speed_changed(new_speed: float)

# Node References
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh

# --- EXPORTED PROPERTIES ---
@export_group("Control")
@export var max_h_offset: float = 20.0
@export var h_move_speed: float = 15.0

@export_group("Auto-Aim Tuning")
@export var auto_aim_range: float = 60.0 
@export var auto_aim_strength: float = 0.5 
# NEW: How much "Points" an orb gets for being close (0.0 - 10.0)
@export var distance_weight: float = 1.0 
# NEW: How much "Points" an orb gets for being looked at (0.0 - 10.0)
# Set this HIGHER than distance_weight to prioritize aiming over proximity.
@export var alignment_weight: float = 3.0 

@export_group("Space Flight Feel")
@export var acceleration: float = 3.0  
@export var friction: float = 2.0      
@export var bank_angle: float = 25.0   
@export var bank_speed: float = 5.0

@export_group("Momentum Mechanics")
@export var start_speed: float = 30.0
@export var speed_decay: float = 2.0   
@export var max_speed: float = 60.0
@export var min_speed_threshold: float = 5.0 

# --- STATE ---
var speed: float = 30.0
var is_game_active: bool = true

func _ready():
    add_to_group("player")
    speed = start_speed
    is_game_active = true
    
    if camera:
        camera.make_current()
        camera.position = Vector3(0, 0, 30)
        camera.rotation_degrees = Vector3(0, 0, 0)
    if spring_arm:
        spring_arm.position = Vector3(0, 2, 0)
        spring_arm.rotation_degrees = Vector3(0, 0, 0)

func _physics_process(delta):
    if not is_game_active:
        return

    # 1. Logarithmic-like Speed Decay
    var decay_factor = clampf(speed / max_speed, 0.0, 1.0)
    var current_decay = speed_decay * decay_factor
    current_decay = max(current_decay, 0.5)
    
    decrease_speed(current_decay * delta)

    # 2. Forward Movement
    velocity.z = -speed
    
    # 3. Horizontal/Vertical Movement
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
    var aim_dir = _get_weighted_aim_vector(input_dir)
    
    var target_dir = input_dir + (aim_dir * auto_aim_strength)
    if target_dir.length() > 1.0:
        target_dir = target_dir.normalized()
    
    var target_vel_x = target_dir.x * h_move_speed
    var target_vel_y = target_dir.y * h_move_speed

    # PHYSICS: Apply Inertia
    if target_dir.length() > 0.01:
        velocity.x = lerp(velocity.x, target_vel_x, acceleration * delta)
        velocity.y = lerp(velocity.y, target_vel_y, acceleration * delta)
    else:
        velocity.x = lerp(velocity.x, 0.0, friction * delta)
        velocity.y = lerp(velocity.y, 0.0, friction * delta)

    # 4. Apply Visual Banking
    if player_mesh:
        var target_roll = - (velocity.x / h_move_speed) * deg_to_rad(bank_angle)
        player_mesh.rotation.z = lerp(player_mesh.rotation.z, target_roll, bank_speed * delta)

    # 5. Apply Physics
    move_and_slide()
    _apply_boundaries()

func _get_weighted_aim_vector(user_input: Vector2) -> Vector2:
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var best_score = -INF 
    
    for orb in orbs:
        if not is_instance_valid(orb): continue
        
        # 1. Range Check
        var dz = orb.global_position.z - global_position.z
        # Only consider orbs in front (dz < 0) and within max range
        if dz >= 0 or abs(dz) > auto_aim_range:
            continue
            
        var diff_3d = orb.global_position - global_position
        var dir_to_orb = Vector2(diff_3d.x, diff_3d.y).normalized()
        
        # --- NEW SCORING LOGIC ---
        
        # A. Distance Factor (0.0 to 1.0)
        # 1.0 = Right in front of face. 0.0 = At max range.
        var dist = diff_3d.length()
        var dist_factor = 1.0 - clampf(dist / auto_aim_range, 0.0, 1.0)
        
        # B. Alignment Factor (-1.0 to 1.0)
        # 1.0 = You are pressing directly towards it.
        var align_factor = 0.0
        if user_input.length_squared() > 0.1:
            align_factor = user_input.normalized().dot(dir_to_orb)
        
        # C. Final Weighted Score
        # We multiply factors by Inspector weights to decide importance
        var score = (dist_factor * distance_weight) + (align_factor * alignment_weight)
        
        if score > best_score:
            best_score = score
            best_orb = orb
            
    if best_orb:
        var target_dir_3d = (best_orb.global_position - global_position).normalized()
        return Vector2(target_dir_3d.x, target_dir_3d.y)
    
    return Vector2.ZERO

func _apply_boundaries():
    var new_pos = global_position
    var limit = max_h_offset
    new_pos.x = clampf(new_pos.x, -limit, limit)
    new_pos.y = clampf(new_pos.y, -limit, limit) 
    global_position = new_pos

# --- MOMENTUM METHODS ---

func increase_speed(amount: float):
    if not is_game_active: return
    speed = min(max_speed, speed + amount)
    speed_changed.emit(speed)

func decrease_speed(amount: float):
    if not is_game_active: return
    speed -= amount
    speed_changed.emit(speed)
    
    if speed <= min_speed_threshold:
        speed = 0
        _trigger_game_over()

func _trigger_game_over():
    print("Angel: Momentum depleted (0). Stopping Game.")
    is_game_active = false
    velocity = Vector3.ZERO
    
    var generator = get_tree().get_first_node_in_group("level_manager")
    if generator and generator.has_method("_game_over"):
        generator._game_over()

# --- GETTERS ---
func get_speed() -> float: return speed
func get_max_speed() -> float: return max_speed
