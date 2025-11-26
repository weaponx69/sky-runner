# Angel Player Script
# FEATURE: Rail Shooter Movement (Auto-Path to Orb + Mouse Dodge).
# FIX: Ship flies to nearest orb automatically; Mouse adds a dodge offset.
# FIX: Includes "Deadzone" check to ignore orbs that are too close/behind.
# FIX: Uses stable visual rotation logic (no shaking).

extends CharacterBody3D

# Signals
signal speed_changed(new_speed: float)

# Node References
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh

@export var key_dodge_speed: float = 15.0 # Speed keys adjust the dodge offset

# --- EXPORTED PROPERTIES ---
@export_group("Control")
@export var use_mouse_input: bool = false # Default to Keyboard control
@export var mouse_sensitivity: float = 0.3
@export var max_dodge_offset: float = 15.0 # Max distance you can pull away from the path
@export var steer_response: float = 5.0    # How fast ship reacts to path changes
@export var h_move_speed: float = 15.0     # Ref for banking

@export_group("Auto-Pathing")
@export var scan_distance: float = 200.0 
@export var min_target_distance: float = 20.0 # Ignore orbs closer than this (Forward Deadzone)
@export var path_look_ahead: float = 40.0 # How far ahead to project "default" path if no orbs
@export var center_bias: float = 4.0      # Higher = prefers center orbs over side orbs

@export_group("Visual Settings")
@export var show_reticle: bool = true 
@export var reticle_color: Color = Color(0.0, 1.0, 0.5) 
@export var reticle_size: float = 2.0 
@export var show_debug_line: bool = true 
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
var dodge_offset: Vector2 = Vector2.ZERO # The player's manual evasion offset

# --- VISUALS ---
var aim_line_mesh: ImmediateMesh
var aim_line_node: MeshInstance3D
var reticle_node: MeshInstance3D

func _ready():
    add_to_group("player")
    speed = start_speed
    is_game_active = true
    
    # Capture Mouse
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    
    # Reset Visuals (We apply rotation dynamically in physics)
    if player_mesh: player_mesh.rotation = Vector3.ZERO
    
    if camera: 
        camera.make_current()
        camera.position = Vector3(0, 0, 30)
        camera.rotation_degrees = Vector3.ZERO
    if spring_arm:
        spring_arm.position = Vector3(0, 2, 0)
        spring_arm.rotation_degrees = Vector3.ZERO
        
    _setup_visuals()

func _update_input_mode():
    # If starting in Keyboard Mode (default), mouse is HIDDEN/FREE.
    # If in Mouse Mode, mouse is CAPTURED/LOCKED.
    #if use_mouse_input:
        #Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    #else:
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _unhandled_input(_event):
    if not is_game_active: return

    # 1. Toggle Mode with TAB (Keep for dual-mode switching)
    #if event.is_action_pressed("ui_focus_next"): 
        #use_mouse_input = !use_mouse_input
        #print("Control Mode: ", "MOUSE (Dodge)" if use_mouse_input else "KEYBOARD (Switch)")
        #_update_input_mode()
        #dodge_offset = Vector2.ZERO 

    # We want to capture mouse movement even if we are in Keyboard mode, 
    # but only use key presses if we are NOT in mouse mode (for the Dodge Offset)

    # 2. MOUSE INPUT: Adds to the dodge offset
    #if event is InputEventMouseMotion:
        #dodge_offset.x += event.relative.x * mouse_sensitivity * 0.1
        #dodge_offset.y -= event.relative.y * mouse_sensitivity * 0.1
    
    # 3. KEY INPUT (WASD): Adds to the dodge offset over time (smooth push)
    # This key input is only active if the main mode is KEYBOARD (Node Switching)
    #if not use_mouse_input:
    if true:
        var delta_time = get_process_delta_time()
        
        var key_dodge_dir = Vector2.ZERO
        # WASD Control Mapping
        if Input.is_physical_key_pressed(KEY_A): key_dodge_dir.x -= 1.0 # Left
        if Input.is_physical_key_pressed(KEY_D): key_dodge_dir.x += 1.0 # Right
        if Input.is_physical_key_pressed(KEY_W): key_dodge_dir.y += 1.0 # Up
        if Input.is_physical_key_pressed(KEY_S): key_dodge_dir.y -= 1.0 # Down

        if key_dodge_dir.length_squared() > 0.0:
            # Add continuous push force to dodge offset
            dodge_offset += key_dodge_dir.normalized() * key_dodge_speed * delta_time
        
    # 4. Clamp offset (applies to all movement types)
    dodge_offset.x = clampf(dodge_offset.x, -max_dodge_offset, max_dodge_offset)
    dodge_offset.y = clampf(dodge_offset.y, -max_dodge_offset, max_dodge_offset)


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
    ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    reticle_node.material_override = ring_mat
    add_child(reticle_node)
    reticle_node.top_level = true

func _process(delta):
    # --- VISUAL UPDATE ONLY ---
    aim_line_mesh.clear_surfaces()
    
    # Determine where we are trying to fly (Target + Offset)
    var flight_target = _calculate_flight_target()
    
    # Update Reticle (Green Ring)
    if show_reticle:
        reticle_node.visible = true
        reticle_node.global_position = reticle_node.global_position.lerp(flight_target, 25.0 * delta)
        if camera: reticle_node.look_at(camera.global_position, Vector3.UP)
        
    # Update Tether Line (Red Line) to Orb (The Rail)
    if show_debug_line and is_instance_valid(current_orb_target):
        aim_line_node.visible = true
        aim_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
        aim_line_mesh.surface_add_vertex(global_position)
        aim_line_mesh.surface_add_vertex(current_orb_target.global_position)
        aim_line_mesh.surface_end()
    else:
        aim_line_node.visible = false


func _physics_process(delta):
    if not is_game_active: 
        # Skip everything if game logic is off (but still allow physics thread cleanup)
        return

    # 1. Speed Decay
    var decay_factor = clampf(speed / max_speed, 0.0, 1.0)
    decrease_speed(speed_decay * decay_factor * delta)

    # 2. Forward Movement
    velocity.z = -speed
    
    # 3. Targeting Logic
    _update_keyboard_logic() # Find nearest target if needed
    
    # 4. Movement Check (Crucial Fix for Crash)
    if velocity.length_squared() < 0.01:
        # If speed is zero, skip rotation/movement calculation
        move_and_slide()
        return

    # 5. Calculate Steering
    var destination = _calculate_flight_target()
    
    # Calculate Direction to Destination
    var desired_dir = (destination - global_position).normalized()
    
    # Get Current Heading
    var current_dir = velocity.normalized()
        
    # Slerp towards destination (Momentum)
    var new_dir = current_dir.slerp(desired_dir, steer_response * delta).normalized()
    velocity = new_dir * speed

    # 6. Visual Rotation
    if player_mesh:
        # A. Heading (Look at Destination)
        var target_t = player_mesh.global_transform.looking_at(destination, Vector3.UP)
        
        # Smoothly rotate base transform
        var current_b = player_mesh.global_transform.basis.orthonormalized()
        var target_b = target_t.basis.orthonormalized()
        var new_basis = current_b.slerp(target_b, rotation_speed * delta).orthonormalized()
        
        player_mesh.global_transform.basis = new_basis
        
        # B. Apply Offsets and Banking
        var display_basis = player_mesh.global_transform.basis
        
        if model_pitch_offset != 0.0:
            display_basis = display_basis.rotated(display_basis.x, deg_to_rad(model_pitch_offset))
        if model_rotation_offset != 0.0:
            display_basis = display_basis.rotated(display_basis.y, deg_to_rad(model_rotation_offset))
            
        var ref_speed = max(h_move_speed, 1.0)
        var bank_amount = clampf(velocity.x / ref_speed, -1.0, 1.0)
        var target_roll = -bank_amount * deg_to_rad(bank_angle)
        display_basis = display_basis.rotated(display_basis.z, target_roll)
        
        player_mesh.global_transform.basis = display_basis

    move_and_slide()


# --- HELPER: Calculate Destination ---
func _calculate_flight_target() -> Vector3:
    var target_pos = Vector3.ZERO
    
    if is_instance_valid(current_orb_target):
        # Base Path = Orb Position
        target_pos = current_orb_target.global_position
    else:
        # Base Path = Straight Ahead
        target_pos = global_position
        target_pos.z -= path_look_ahead
        # If no orb, recenter X/Y base so we don't drift infinitely
        target_pos.x = lerp(target_pos.x, 0.0, 0.1)
        target_pos.y = lerp(target_pos.y, 0.0, 0.1)
    
    # Apply Mouse Dodge Offset
    target_pos.x += dodge_offset.x
    target_pos.y += dodge_offset.y
    
    return target_pos


func _update_auto_path():
    # Only run this function if we have lost the current target (e.g., collected it)
    if is_instance_valid(current_orb_target):
        return

    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var best_score = INF
    
    for orb in orbs:
        if not is_instance_valid(orb): continue
        
        var diff = orb.global_position - global_position
        var dz = diff.z
        
        # 1. Forward Check (Must be far enough ahead)
        if dz > -min_target_distance: continue 
        if abs(dz) > scan_distance: continue
        
        # 2. Score: Prioritize Center > Side
        var forward_dist = abs(dz)
        var lateral_dist = Vector2(diff.x, diff.y).length()
        var score = forward_dist + (lateral_dist * center_bias)
        
        if score < best_score:
            best_score = score
            best_orb = orb
            
    current_orb_target = best_orb


# --- MOMENTUM METHODS ---
func increase_speed(amount: float):
    if not is_game_active: return
    speed = min(max_speed, speed + amount)
    speed_changed.emit(speed)
    
    # Force re-scan on pickup so we don't target the orb we just hit
    current_orb_target = null 
    _update_auto_path()

func decrease_speed(amount: float):
    if not is_game_active: return
    speed -= amount
    speed_changed.emit(speed)
    if speed <= min_speed_threshold:
        speed = 0
        velocity = Vector3.ZERO # Ensure velocity is zero immediately
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
           
 
# --- ADD THIS FUNCTION (Required for Keyboard Mode) ---
func _update_keyboard_logic():
    # If we lost the target or passed it, find the next one automatically
    if not is_instance_valid(current_orb_target) or current_orb_target.global_position.z > global_position.z - min_target_distance:
        _pick_nearest_forward_orb()


  
func _pick_nearest_forward_orb():
    var orbs = get_tree().get_nodes_in_group("orbs")
    var best_orb = null
    var min_dist = INF
    
    for orb in orbs:
        if not is_instance_valid(orb): continue
        var dz = orb.global_position.z - global_position.z
        
        # FIX: Use min_target_distance
        if dz > -min_target_distance: continue 
        if abs(dz) > scan_distance: continue
        
        var dist = global_position.distance_squared_to(orb.global_position)
        if dist < min_dist:
            min_dist = dist
            best_orb = orb
            
    current_orb_target = best_orb # Using the correct name
    
