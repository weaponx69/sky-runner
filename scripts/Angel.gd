# Angel Player Script
# FIX: Re-added 'h_move_speed' variable which was causing a crash in the banking calculation.
# FIX: Retains Node Switching logic and Rotation fix.

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
@export var steer_response: float = 8.0 # Higher = Snappier auto-pilot
@export var h_move_speed: float = 15.0  # Reference speed for banking visuals

@export_group("Targeting")
@export var scan_range: float = 100.0 
@export var switch_cone_angle: float = 120.0 

@export_group("Reticle Visuals")
@export var show_reticle: bool = true 
@export var reticle_color: Color = Color(0.0, 1.0, 0.5) 
@export var reticle_size: float = 2.0

@export_group("Visual Settings")
@export var model_rotation_offset: float = 180.0 

@export_group("Space Flight Feel")
@export var acceleration: float = 5.0  
@export var friction: float = 2.0      
@export var bank_angle: float = 35.0   
@export var bank_speed: float = 8.0

@export_group("Momentum Mechanics")
@export var start_speed: float = 30.0
@export var speed_decay: float = 2.0   
@export var max_speed: float = 60.0
@export var min_speed_threshold: float = 5.0 

# --- STATE ---
var speed: float = 30.0
var is_game_active: bool = true
var current_target: Node3D = null 

# --- VISUALS ---
var reticle_node: MeshInstance3D

func _ready():
    add_to_group("player")
    speed = start_speed
    is_game_active = true
    
    # Apply visual rotation fix
    if player_mesh:
        player_mesh.rotation_degrees.y = model_rotation_offset
    
    if camera:
        camera.make_current()
        camera.position = Vector3(0, 0, 30)
        camera.rotation_degrees = Vector3(0, 0, 0)
    if spring_arm:
        spring_arm.position = Vector3(0, 2, 0)
        spring_arm.rotation_degrees = Vector3(0, 0, 0)
        
    _setup_reticle()
    _auto_lock_nearest()

func _setup_reticle():
    var mesh = TorusMesh.new()
    mesh.inner_radius = reticle_size * 0.9
    mesh.outer_radius = reticle_size
    
    reticle_node = MeshInstance3D.new()
    reticle_node.mesh = mesh
    reticle_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = reticle_color
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    reticle_node.material_override = mat
    add_child(reticle_node)
    reticle_node.top_level = true
    reticle_node.visible = false

func _process(delta):
    if is_instance_valid(current_target) and show_reticle:
        reticle_node.visible = true
        reticle_node.global_position = reticle_node.global_position.lerp(current_target.global_position, 25.0 * delta)
        if camera:
            reticle_node.look_at(camera.global_position, Vector3.UP)
    else:
        reticle_node.visible = false

func _physics_process(delta):
    if not is_game_active: return

    # 1. Speed Decay
    var decay_factor = clampf(speed / max_speed, 0.0, 1.0)
    decrease_speed(speed_decay * decay_factor * delta)

    # 2. Input: Switch Targets
    if Input.is_action_just_pressed("ui_left"): _try_switch_target(Vector2.LEFT)
    if Input.is_action_just_pressed("ui_right"): _try_switch_target(Vector2.RIGHT)
    if Input.is_action_just_pressed("ui_up"): _try_switch_target(Vector2.UP)
    if Input.is_action_just_pressed("ui_down"): _try_switch_target(Vector2.DOWN)

    # 3. Target Validation
    if not is_instance_valid(current_target) or current_target.global_position.z > global_position.z:
        _auto_lock_nearest()

    # 4. Auto-Pilot Movement
    velocity.z = -speed 
    
    if is_instance_valid(current_target):
        var target_pos = current_target.global_position
        var diff_x = target_pos.x - global_position.x
        var diff_y = target_pos.y - global_position.y
        
        velocity.x = lerp(velocity.x, diff_x * steer_response, acceleration * delta)
        velocity.y = lerp(velocity.y, diff_y * steer_response, acceleration * delta)
    else:
        velocity.x = lerp(velocity.x, 0.0, friction * delta)
        velocity.y = lerp(velocity.y, 0.0, friction * delta)

    # 5. Banking (Uses h_move_speed as reference)
    if player_mesh:
        # Prevent division by zero
        var ref_speed = max(h_move_speed, 1.0)
        var target_roll = - (velocity.x / ref_speed) * deg_to_rad(bank_angle)
        player_mesh.rotation.z = lerp(player_mesh.rotation.z, target_roll, bank_speed * delta)

    move_and_slide()
    _apply_boundaries()

# --- TARGETING LOGIC ---

func _auto_lock_nearest():
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var min_dist = INF
    
    for orb in orbs:
        if not is_instance_valid(orb): continue
        var dz = orb.global_position.z - global_position.z
        
        if dz < -1.0 and abs(dz) < scan_range:
            var dist = global_position.distance_squared_to(orb.global_position)
            if dist < min_dist:
                min_dist = dist
                best_orb = orb
                
    if best_orb:
        current_target = best_orb

func _try_switch_target(input_dir: Vector2):
    var origin_pos = global_position
    if is_instance_valid(current_target):
        origin_pos = current_target.global_position
        
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_cand = null
    var best_score = -INF
    
    for orb in orbs:
        if not is_instance_valid(orb) or orb == current_target: continue
        if orb.global_position.z > global_position.z - 1.0: continue
        
        var diff_3d = orb.global_position - origin_pos
        var relative_dir = Vector2(diff_3d.x, diff_3d.y).normalized()
        
        var alignment = input_dir.dot(relative_dir)
        
        if alignment > 0.3: 
            var dist = diff_3d.length()
            var score = (1000.0 / dist) + (alignment * 50.0)
            
            if score > best_score:
                best_score = score
                best_cand = orb
                
    if best_cand:
        current_target = best_cand

# --- BOUNDARIES & MOMENTUM ---

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
    _auto_lock_nearest()

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
