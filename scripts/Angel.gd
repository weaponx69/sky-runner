# Angel Player Script
# FIX: Added 'aim_cone_angle' to strictly ignore objects outside a forward field of view.
# FIX: Increased lateral distance penalty to stop targeting orbs on the far sides.

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
# NEW: Field of View for targeting. 90 = Wide, 30 = Narrow Tunnel Vision.
@export var aim_cone_angle: float = 30.0 
@export var auto_aim_strength: float = 0.5 
@export var distance_weight: float = 1.0 
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

@export_group("Debug")
@export var show_debug_line: bool = true 

# --- STATE ---
var speed: float = 30.0
var is_game_active: bool = true
var current_target: Node3D = null 

# --- VISUALS ---
var aim_line_mesh: ImmediateMesh
var aim_line_node: MeshInstance3D

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
        
    _setup_aim_line()

func _setup_aim_line():
    aim_line_mesh = ImmediateMesh.new()
    aim_line_node = MeshInstance3D.new()
    aim_line_node.mesh = aim_line_mesh
    aim_line_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1, 0, 0, 1)
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    aim_line_node.material_override = mat
    add_child(aim_line_node)

func _process(_delta):
    aim_line_mesh.clear_surfaces()
    
    if show_debug_line and is_instance_valid(current_target):
        aim_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
        aim_line_mesh.surface_add_vertex(Vector3.ZERO)
        var target_local = to_local(current_target.global_position)
        aim_line_mesh.surface_add_vertex(target_local)
        aim_line_mesh.surface_end()

func _physics_process(delta):
    if not is_game_active:
        return

    # 1. Speed Decay
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

    # Inertia
    if target_dir.length() > 0.01:
        velocity.x = lerp(velocity.x, target_vel_x, acceleration * delta)
        velocity.y = lerp(velocity.y, target_vel_y, acceleration * delta)
    else:
        velocity.x = lerp(velocity.x, 0.0, friction * delta)
        velocity.y = lerp(velocity.y, 0.0, friction * delta)

    # Banking
    if player_mesh:
        var target_roll = - (velocity.x / h_move_speed) * deg_to_rad(bank_angle)
        player_mesh.rotation.z = lerp(player_mesh.rotation.z, target_roll, bank_speed * delta)

    # Physics
    move_and_slide()
    _apply_boundaries()

func _get_weighted_aim_vector(user_input: Vector2) -> Vector2:
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var best_score = -INF 
    
    # Calculate the cone threshold (Dot product value)
    # cos(45 deg) = 0.707. Higher angle = lower dot threshold.
    var cone_dot_threshold = cos(deg_to_rad(aim_cone_angle))
    
    for orb in orbs:
        if not is_instance_valid(orb): continue
        
        # 1. Range Check (Strict Forward Only)
        var to_orb = orb.global_position - global_position
        
        # Must be in front (Negative Z relative to player direction)
        # Since we move -Z, objects in front have lower Z. Vector z must be < 0.
        # We enforce -2.0 to ignore objects we are practically touching/passing.
        if to_orb.z > -2.0: continue
        
        # Must be within max range
        if to_orb.length_squared() > auto_aim_range * auto_aim_range: continue
        
        # 2. Cone Check (The "Tunnel Vision" Fix)
        # Compare direction to orb vs Forward vector (0,0,-1)
        var dir_to_orb = to_orb.normalized()
        var forward_dot = Vector3.FORWARD.dot(dir_to_orb) # Vector3.FORWARD is (0,0,-1) in Godot
        
        if forward_dot < cone_dot_threshold:
            continue # Outside the vision cone, ignore completely
            
        # --- SCORING LOGIC ---
        
        # A. Weighted Distance (Heavily penalize side distance)
        # Multiply X/Y distance by 10.0 effectively making them "farther"
        var weighted_dist_sq = (to_orb.x * to_orb.x * 10.0) + (to_orb.y * to_orb.y * 10.0) + (to_orb.z * to_orb.z)
        var dist_score = 1000.0 / max(1.0, weighted_dist_sq)
        
        # B. Alignment Factor (User Input)
        var align_factor = 0.0
        var dir_to_orb_2d = Vector2(dir_to_orb.x, dir_to_orb.y).normalized()
        
        if user_input.length_squared() > 0.1:
            align_factor = user_input.normalized().dot(dir_to_orb_2d)
        
        # C. Final Weighted Score
        var score = (dist_score * distance_weight) + (align_factor * alignment_weight * 100.0)
        
        if score > best_score:
            best_score = score
            best_orb = orb
    
    current_target = best_orb
            
    if best_orb:
        var target_dir = (best_orb.global_position - global_position).normalized()
        return Vector2(target_dir.x, target_dir.y)
    
    return Vector2.ZERO

func _apply_boundaries():
    var new_pos = global_position
    var limit = max_h_offset
    new_pos.x = clampf(new_pos.x, -limit, limit)
    new_pos.y = clampf(new_pos.y, -limit, limit) 
    global_position = new_pos

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

func get_speed() -> float: return speed
func get_max_speed() -> float: return max_speed
