# Angel Player Script
# FIX: Movement is now AUTOMATIC towards the 'current_target'.
# FIX: Inputs (WASD/Arrows) are used to SWITCH the target Reticle between orbs.

extends CharacterBody3D

# Signals
signal speed_changed(new_speed: float)

# Node References
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh

# --- EXPORTED PROPERTIES ---
@export_group("Control")
@export var max_h_offset: float = 25.0 # Limits how far side-to-side you can go
@export var steer_speed: float = 5.0   # How snappy the auto-pilot is

@export_group("Targeting")
@export var scan_range: float = 100.0  # How far ahead we can lock on
@export var switch_angle: float = 60.0 # Cone angle for switching targets

@export_group("Reticle Visuals")
@export var show_reticle: bool = true 
@export var reticle_color: Color = Color(0.0, 1.0, 0.5) 
@export var reticle_size: float = 2.0

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
    
    if camera:
        camera.make_current()
    
    _setup_reticle()
    
    # Initial Lock-on: Find the closest orb straight ahead
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
    # Visual Reticle Logic
    if is_instance_valid(current_target) and show_reticle:
        reticle_node.visible = true
        # Smoothly snap reticle to target position
        reticle_node.global_position = reticle_node.global_position.lerp(current_target.global_position, 25.0 * delta)
        if camera:
            reticle_node.look_at(camera.global_position, Vector3.UP)
    else:
        reticle_node.visible = false

func _physics_process(delta):
    if not is_game_active: return

    # 1. Handle Speed Decay
    var decay_factor = clampf(speed / max_speed, 0.0, 1.0)
    decrease_speed(speed_decay * decay_factor * delta)

    # 2. Handle Input for Target Switching (Discrete Taps)
    # Maps to WASD / Arrows automatically
    if Input.is_action_just_pressed("ui_left"): _try_switch_target(Vector2.LEFT)
    if Input.is_action_just_pressed("ui_right"): _try_switch_target(Vector2.RIGHT)
    if Input.is_action_just_pressed("ui_up"): _try_switch_target(Vector2.UP)
    if Input.is_action_just_pressed("ui_down"): _try_switch_target(Vector2.DOWN)

    # 3. Validate Target
    # If target is destroyed (collected) or passed, find a new one automatically
    if not is_instance_valid(current_target) or current_target.global_position.z > global_position.z:
        _auto_lock_nearest()

    # 4. Automatic Movement Logic
    velocity.z = -speed # Constant forward momentum
    
    if is_instance_valid(current_target):
        # Steer towards the target's X and Y
        var target_pos = current_target.global_position
        
        # Calculate difference
        var diff_x = target_pos.x - global_position.x
        var diff_y = target_pos.y - global_position.y
        
        # Smoothly interpolate velocity towards the target
        velocity.x = lerp(velocity.x, diff_x * 2.0, steer_speed * delta)
        velocity.y = lerp(velocity.y, diff_y * 2.0, steer_speed * delta)
    else:
        # No target? Drift back to center (or just drift)
        velocity.x = lerp(velocity.x, 0.0, delta)
        velocity.y = lerp(velocity.y, 0.0, delta)

    # 5. Apply Visual Banking (Roll) based on steering
    if player_mesh:
        var bank_amount = -velocity.x * 0.05
        player_mesh.rotation.z = lerp(player_mesh.rotation.z, bank_amount, 5.0 * delta)

    move_and_slide()
    _apply_boundaries()

# --- TARGETING LOGIC ---

func _auto_lock_nearest():
    # Default behavior: Lock onto the closest orb in front of us
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var min_dist = INF
    
    for orb in orbs:
        if not is_instance_valid(orb): continue
        var dz = orb.global_position.z - global_position.z
        
        # Must be in front (dz < 0) and within range
        if dz < -1.0 and abs(dz) < scan_range:
            var dist = global_position.distance_squared_to(orb.global_position)
            if dist < min_dist:
                min_dist = dist
                best_orb = orb
    
    if best_orb:
        current_target = best_orb

func _try_switch_target(direction_2d: Vector2):
    # Switch context: Start from current target (or player if null)
    var origin_pos = global_position
    if is_instance_valid(current_target):
        origin_pos = current_target.global_position
        
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_candidate = null
    var best_score = -INF
    
    for orb in orbs:
        if not is_instance_valid(orb) or orb == current_target: continue
        
        # Must be in front of the PLAYER (not necessarily the old target)
        if orb.global_position.z > global_position.z - 1.0: continue
        
        # Calculate vector from Origin (current target) to Candidate
        var diff_3d = orb.global_position - origin_pos
        
        # Ignore Z for direction check, we care about Screen Space relative (X/Y)
        var relative_dir = Vector2(diff_3d.x, diff_3d.y).normalized()
        
        # Dot product check: Is this orb in the direction we pressed?
        var alignment = direction_2d.dot(relative_dir)
        
        # Filter: Must be roughly in that direction (> 0.5 is approx 60 degrees)
        if alignment > 0.5:
            # Score based on distance (Closer = Better)
            # But heavily weight alignment so we pick the one "in that direction"
            var dist = diff_3d.length()
            var score = (1000.0 / dist) + (alignment * 10.0)
            
            if score > best_score:
                best_score = score
                best_candidate = orb
                
    if best_candidate:
        current_target = best_candidate

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
    
    # Optional: When collecting, auto-find next target immediately
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
    var generator = get_tree().get_first_node_in_group("level_manager")
    if generator and generator.has_method("_game_over"):
        generator._game_over()

func get_speed() -> float: return speed
func get_max_speed() -> float: return max_speed
