## Manages the player character, an angel, including its movement, targeting, and game state.
extends CharacterBody3D

## Emitted when the angel's speed changes.
signal speed_changed(new_speed: float)

# Node References
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $ModelPivot

# --- EXPORTED PROPERTIES ---
@export var key_dodge_speed: float = 15.0
@export var dodge_return_speed: float = 10.0

# --- PHYSICS VARIABLES ---
var dodge_velocity: Vector2 = Vector2.ZERO
@export var dodge_acceleration: float = 60.0
@export var dodge_friction: float = 5.0
@export var dodge_return_spring: float = 4.0 

# The future orb we are "looking at" to switch to
var locked_branch_target: Node3D = null

@export_group("Control")
@export var use_mouse_input: bool = false
@export var mouse_sensitivity: float = 0.3
@export var max_dodge_offset: float = 15.0
@export var steer_response: float = 1.0
@export var h_move_speed: float = 15.0

@export_group("Auto-Pathing")
@export var auto_select_path: bool = true
@export var scan_distance: float = 1500.0
@export var min_target_distance: float = 10.0
@export var path_look_ahead: float = 120.0
@export var center_bias: float = 4.0

@export_group("Visual Settings")
@export var show_reticle: bool = true
@export var reticle_color: Color = Color(0.0, 1.0, 0.5)
@export var reticle_size: float = 2.0
@export var show_debug_line: bool = false
@export var show_branch_paths: bool = true
@export var line_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var model_rotation_offset: float = 180.0
@export var model_pitch_offset: float = 0.0
@export var rotation_speed: float = 10.0

@export_group("Space Flight Feel")
@export var acceleration: float = 5.0
@export var friction: float = 2.0
@export var bank_angle: float = 45.0
@export var bank_speed: float = 8.0

@export_group("Momentum Mechanics")
@export var start_speed: float = 30.0
@export var speed_decay: float = 2.0
@export var max_speed: float = 60.0
@export var min_speed_threshold: float = 5.0

# --- STATE ---
var speed: float = 30.0
var is_game_active: bool = true
var current_orb_target: Node3D = null
var dodge_offset: Vector2 = Vector2.ZERO

var branch_line_mesh: ImmediateMesh
var branch_line_node: MeshInstance3D
var aim_line_mesh: ImmediateMesh
var aim_line_node: MeshInstance3D
var reticle_node: MeshInstance3D

func _ready():
    add_to_group("player")
    speed = start_speed
    is_game_active = true
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    
    if player_mesh: player_mesh.rotation = Vector3.ZERO
    
    if camera: 
        camera.make_current()
        camera.position = Vector3(0, 0, 30)
        camera.rotation_degrees = Vector3.ZERO
    if spring_arm:
        spring_arm.position = Vector3(0, 2, 0)
        spring_arm.rotation_degrees = Vector3.ZERO
        
    _setup_visuals()


# --- SMART RETICLE LOGIC (The Switch System) ---
func _update_smart_reticle_target():
    # 1. Determine Input "Command" (Left/Right Switch)
    var input_dir = Vector2.ZERO
    
    if Input.is_action_just_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A): 
        if not Input.is_action_pressed("ui_right") and not Input.is_physical_key_pressed(KEY_D):
            input_dir.x = -1.0 # SEARCH LEFT
            
    if Input.is_action_just_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
        if not Input.is_action_pressed("ui_left") and not Input.is_physical_key_pressed(KEY_A):
            input_dir.x = 1.0 # SEARCH RIGHT

    # If no new button press, we keep our current lock! (Persistence)
    if input_dir.length() == 0:
        if not is_instance_valid(locked_branch_target):
            _auto_lock_nearest_forward()
        return

    # 2. GLOBAL SEARCH (Get ALL orbs, ignore neighbors)
    var all_orbs = get_tree().get_nodes_in_group("orbs")
    var best_match = null
    var max_score = -INF
    var cam_xform = camera.global_transform
    var cam_forward = -cam_xform.basis.z

    for orb in all_orbs:
        if not is_instance_valid(orb): continue
        if orb == current_orb_target: continue 
        
        # --- SAFEGUARD 1: GENERATION DISTANCE ---
        var dist = global_position.distance_to(orb.global_position)
        if dist > scan_distance: continue

        # --- SAFEGUARD 2: VISIBILITY ---
        # Only lock onto what the camera can actually see
        if not camera.is_position_in_frustum(orb.global_position):
            continue

        # B. Direction Check (Is it in front of the camera?)
        var to_orb = orb.global_position - camera.global_position
        if cam_forward.dot(to_orb.normalized()) < 0.5: 
            continue 
            
        # C. Screen Position Check
        var screen_x = to_orb.dot(cam_xform.basis.x)
        var side_match = screen_x * input_dir.x 
        
        if side_match > 0: 
            # Score: Favor screen alignment, penalize distance slightly
            var score = abs(screen_x) - (dist * 0.1)
            
            if score > max_score:
                max_score = score
                best_match = orb
            
    # 3. Apply the Lock
    if best_match:
        # print(">>> GLOBAL LOCK: Switched to ", best_match.name)
        locked_branch_target = best_match
        current_orb_target = best_match
        dodge_offset = Vector2.ZERO
        _auto_lock_nearest_forward()


## Automatically locks onto the "straightest" path forward.
func _auto_lock_nearest_forward():
    if not is_instance_valid(current_orb_target) or not "neighbors" in current_orb_target:
        return

    var neighbors = current_orb_target.neighbors
    if neighbors.is_empty():
        locked_branch_target = null
        return

    var best_orb = null
    var max_dot = -1.0
    var rail_forward = Vector3(0, 0, -1) # Global Forward

    # Pick the neighbor most aligned with straight forward
    for orb in neighbors:
        if not is_instance_valid(orb): continue
        
        var dir = (orb.global_position - current_orb_target.global_position).normalized()
        var alignment = rail_forward.dot(dir)
        
        if alignment > max_dot:
            max_dot = alignment
            best_orb = orb
            
    locked_branch_target = best_orb

# --- VISUALS ---
func _setup_visuals():
    aim_line_mesh = ImmediateMesh.new()
    aim_line_node = MeshInstance3D.new()
    aim_line_node.mesh = aim_line_mesh
    aim_line_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var line_mat = StandardMaterial3D.new()
    line_mat.albedo_color = line_color
    line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    line_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    aim_line_node.material_override = line_mat
    add_child(aim_line_node)
    aim_line_node.top_level = true

    var ring_mesh = TorusMesh.new()
    ring_mesh.inner_radius = reticle_size * 0.8
    ring_mesh.outer_radius = reticle_size
    reticle_node = MeshInstance3D.new()
    reticle_node.mesh = ring_mesh
    reticle_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var ring_mat = StandardMaterial3D.new()
    ring_mat.albedo_color = reticle_color
    ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    reticle_node.material_override = ring_mat
    add_child(reticle_node)
    reticle_node.top_level = true
    
    branch_line_mesh = ImmediateMesh.new()
    branch_line_node = MeshInstance3D.new()
    branch_line_node.mesh = branch_line_mesh
    branch_line_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var branch_mat = StandardMaterial3D.new()
    branch_mat.albedo_color = Color(0.0, 1.0, 1.0, 0.3) 
    branch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    branch_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    branch_line_node.material_override = branch_mat
    add_child(branch_line_node)
    branch_line_node.top_level = true

# --- PROCESS (Visuals & Reticle) ---
func _process(delta):
    # 1. Update Inputs
    _update_smart_reticle_target()

    # --- RED TETHER LINE ---
    aim_line_mesh.clear_surfaces()
    if show_debug_line and is_instance_valid(current_orb_target):
        aim_line_node.visible = true
        aim_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
        aim_line_mesh.surface_add_vertex(global_position)
        aim_line_mesh.surface_add_vertex(current_orb_target.global_position)
        aim_line_mesh.surface_end()
    else:
        aim_line_node.visible = false

    # --- RETICLE UPDATE (Stable & Locked) ---
    if show_reticle:
        reticle_node.visible = true
        var visual_target = Vector3.ZERO
        
        # PRIORITY A: Locked Target (User selection or Auto-Path)
        if is_instance_valid(locked_branch_target):
            visual_target = locked_branch_target.global_position
        
        # PRIORITY B: Horizon View (Stable Forward)
        # If no lock, look straight down the track (-Z) instead of at nearby orbs.
        else:
            var horizon_point = global_position + Vector3(0, 0, -100.0)
            # Add a little of the dodge offset so it feels connected to the ship
            horizon_point.x += dodge_offset.x * 2.0
            horizon_point.y += dodge_offset.y * 2.0
            visual_target = horizon_point

        # Smooth Snapping
        reticle_node.global_position = reticle_node.global_position.lerp(visual_target, 25.0 * delta)
        
        if camera: 
            reticle_node.look_at(camera.global_position, Vector3.UP)
    else:
        reticle_node.visible = false

    # --- CYAN BRANCH LINES ---
    branch_line_mesh.clear_surfaces()
    if show_branch_paths and is_instance_valid(current_orb_target) and "neighbors" in current_orb_target:
        branch_line_node.visible = true
        branch_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
        for next_orb in current_orb_target.neighbors:
            if is_instance_valid(next_orb):
                branch_line_mesh.surface_add_vertex(current_orb_target.global_position)
                branch_line_mesh.surface_add_vertex(next_orb.global_position)
        branch_line_mesh.surface_end()
    else:
        branch_line_node.visible = false

# --- PHYSICS PROCESS ---
func _physics_process(delta):
    if not is_game_active: return

    # --- 1. ORGANIC MOMENTUM PHYSICS ---
    var input_vector = Vector2.ZERO
    if Input.is_physical_key_pressed(KEY_A): input_vector.x -= 1.0
    if Input.is_physical_key_pressed(KEY_D): input_vector.x += 1.0
    if Input.is_physical_key_pressed(KEY_W): input_vector.y += 1.0
    if Input.is_physical_key_pressed(KEY_S): input_vector.y -= 1.0
    
    if input_vector.length() > 1.0: input_vector = input_vector.normalized()

    # Acceleration
    if input_vector.length() > 0.0:
        dodge_velocity += input_vector * dodge_acceleration * delta
    
    # Spring Force
    var spring_force = -dodge_offset * dodge_return_spring
    if input_vector.length() > 0.0: spring_force *= 0.2 
    dodge_velocity += spring_force * delta

    # Friction
    dodge_velocity = dodge_velocity.lerp(Vector2.ZERO, dodge_friction * delta)
    dodge_offset += dodge_velocity * delta

    # Limits
    if dodge_offset.x < -max_dodge_offset or dodge_offset.x > max_dodge_offset:
        dodge_velocity.x *= -0.5
        dodge_offset.x = clampf(dodge_offset.x, -max_dodge_offset, max_dodge_offset)
    if dodge_offset.y < -max_dodge_offset or dodge_offset.y > max_dodge_offset:
        dodge_velocity.y *= -0.5
        dodge_offset.y = clampf(dodge_offset.y, -max_dodge_offset, max_dodge_offset)

    # --- 2. SPEED & MOMENTUM ---
    var decay_factor = clampf(speed / max_speed, 0.0, 1.0)
    decrease_speed(speed_decay * decay_factor * delta)
    velocity.z = -speed

    # --- 3. FAILSAFE ---
    if is_instance_valid(current_orb_target):
        if global_position.z < current_orb_target.global_position.z:
            find_next_target_from_neighbors(current_orb_target)
            if is_instance_valid(current_orb_target) and global_position.z < current_orb_target.global_position.z:
                 _pick_nearest_forward_orb()

    # --- 4. TARGETING & MOVEMENT ---
    _update_auto_path() 
    var target_pos = _calculate_flight_target()

    # Apply Interpolation
    var current_pos = global_position
    var interp_factor = steer_response * delta 
    current_pos.x = lerp(current_pos.x, target_pos.x, interp_factor)
    current_pos.y = lerp(current_pos.y, target_pos.y, interp_factor)
    current_pos.z += velocity.z * delta 
    global_position = current_pos

# --- 5. VISUAL ROTATION (Fixed Orientation) ---
    if player_mesh:
        # 1. Calculate where we want to look
        var look_target = target_pos
        if (look_target - global_position).length() < 1.0:
            look_target = global_position + Vector3(0, 0, -10.0)
            
        # 2. Create the "Ideal" Rotation (Standard Forward)
        # looking_at returns a Transform where -Z points to target, Y is Up.
        var target_transform = player_mesh.global_transform.looking_at(look_target, Vector3.UP)
        
        # 3. Apply the Model Offsets to the TARGET (Crucial Step)
        # Instead of rotating the mesh after, we rotate the GOAL.
        # This prevents the "spinning" bug because we aren't adding rotation every frame.
        
        # Rotate -90 degrees on X to lay the cylinder flat
        if model_pitch_offset != 0.0:
            target_transform.basis = target_transform.basis.rotated(target_transform.basis.x, deg_to_rad(model_pitch_offset))
            
        if model_rotation_offset != 0.0:
            target_transform.basis = target_transform.basis.rotated(target_transform.basis.y, deg_to_rad(model_rotation_offset))

        # 4. Apply Banking (Roll)
        # We calculate the bank based on sideways movement
        var move_delta_x = target_pos.x - global_position.x
        var bank_amount = clampf(move_delta_x, -1.0, 1.0)
        var target_roll = -bank_amount * deg_to_rad(bank_angle)
        
        # Add the roll to the target basis
        target_transform.basis = target_transform.basis.rotated(target_transform.basis.z, target_roll)

        # 5. Smoothly Interpolate to this new, corrected orientation
        # We assume the current transform is close to valid, and we drift toward the corrected target
        player_mesh.global_transform = player_mesh.global_transform.interpolate_with(target_transform, rotation_speed * delta)

# --- HELPERS ---
func _calculate_flight_target() -> Vector3:
    var target_pos = Vector3.ZERO
    if is_instance_valid(current_orb_target):
        target_pos = current_orb_target.global_position
    else:
        target_pos = global_position
        target_pos.z -= path_look_ahead
        target_pos.x = lerp(target_pos.x, 0.0, 0.1)
        target_pos.y = lerp(target_pos.y, 0.0, 0.1)
    target_pos.x += dodge_offset.x
    target_pos.y += dodge_offset.y
    return target_pos
    
func find_next_target_from_neighbors(last_orb_visited: Node3D):
    # 1. CHECK LOCK: Did the player already select a branch with the reticle?
    if is_instance_valid(locked_branch_target) and locked_branch_target in last_orb_visited.neighbors:
        print(">>> CONFIRMED: Taking selected branch -> ", locked_branch_target.name)
        current_orb_target = locked_branch_target
        dodge_offset = Vector2.ZERO
        
        # CRITICAL: Auto-lock the NEXT forward path from here so the reticle doesn't go blank
        _auto_lock_nearest_forward()
        return
    
    # 2. Fallback Logic (if no lock was selected)
    if not "neighbors" in last_orb_visited or last_orb_visited.neighbors.is_empty():
        print("Angel: No neighbors found. Scanning forward fallback.")
        _pick_nearest_forward_orb() 
        return

    var candidates = last_orb_visited.neighbors
    var best_orb = null
    var best_score = -INF 
    var rail_forward = Vector3(0, 0, -1)

    print("--- SCANNING (Fallback) ---")
    for orb in candidates:
        if not is_instance_valid(orb): continue
        if orb.global_position.z > global_position.z + 2.0: continue

        var vector_to_orb = orb.global_position - global_position
        var direction_to_orb = vector_to_orb.normalized()
        var alignment = rail_forward.dot(direction_to_orb)
        
        if alignment < 0.1: continue

        var score = alignment
        if dodge_offset.length() > 0.1:
            var to_orb_local = to_local(orb.global_position)
            if sign(to_orb_local.x) == sign(dodge_offset.x):
                 score += 5.0 

        if score > best_score:
            best_score = score
            best_orb = orb

    if best_orb:
        print(">>> LOCKED ON: ", best_orb.name)
        current_orb_target = best_orb
        dodge_offset = Vector2.ZERO 
        _auto_lock_nearest_forward() # Ensure reticle has a target
    else:
        print("Angel: No valid target found ahead.")

func _update_auto_path():
    if not auto_select_path or is_instance_valid(current_orb_target): return
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var best_score = INF
    for orb in orbs:
        if not is_instance_valid(orb): continue
        var diff = orb.global_position - global_position
        var dz = diff.z
        if dz > -min_target_distance: continue 
        if abs(dz) > scan_distance: continue
        var forward_dist = abs(dz)
        var lateral_dist = Vector2(diff.x, diff.y).length()
        var score = forward_dist + (lateral_dist * center_bias)
        if score < best_score:
            best_score = score
            best_orb = orb
    current_orb_target = best_orb
    _auto_lock_nearest_forward()

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
        velocity = Vector3.ZERO 
        _trigger_game_over()

func _trigger_game_over():
    print("Angel: Momentum depleted (0). Stopping Game.")
    is_game_active = false
    velocity = Vector3.ZERO
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    var generator = get_tree().get_first_node_in_group("level_manager")
    if generator and generator.has_method("_game_over"):
        generator._game_over()

func get_speed() -> float: return speed
func get_max_speed() -> float: return max_speed

func _input(event):
    if is_game_active and event.is_action_pressed("ui_accept"):
        var generator = get_tree().get_first_node_in_group("level_manager")
        if generator and generator.has_method("toggle_pause"):
            generator.toggle_pause()

func _update_keyboard_logic():
    if not is_instance_valid(current_orb_target) or current_orb_target.global_position.z > global_position.z - min_target_distance:
        _pick_nearest_forward_orb()

func _pick_nearest_forward_orb():
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var min_dist = INF
    var my_z = global_position.z
    for orb in orbs: 
        if not is_instance_valid(orb): continue
        var orb_z = orb.global_position.z
        if orb_z > my_z - 1.0: continue
        var dist = global_position.distance_to(orb.global_position)
        if dist > scan_distance: continue
        if dist < min_dist:
            min_dist = dist
            best_orb = orb
    if best_orb:
        print("Angel: Scanner found forward target -> ", best_orb.name)
        current_orb_target = best_orb
        dodge_offset = Vector2.ZERO
        _auto_lock_nearest_forward()
    else:
        current_orb_target = null
