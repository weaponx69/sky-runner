extends Camera3D

# --- SETTINGS ---
@export_group("Follow Physics")
## How fast the camera catches up to the player's position (Lower = More Lag/Weight)
@export var follow_speed: float = 4.0
## How fast the camera rotates to look at the player
@export var look_speed: float = 6.0
## The offset relative to the player (Where the camera wants to be)
@export var default_offset: Vector3 = Vector3(0, 6, 18)

@export_group("Dynamic Juice")
## How much the camera tilts (Roll) when the player moves sideways.
## Increased to 3.0 because we are now measuring actual distance moved, which is smaller than velocity.
@export var lean_sensitivity: float = 3.0
## Maximum tilt angle in degrees
@export var max_lean_degrees: float = 15.0
## Extra FOV to add when moving fast
@export var speed_fov_boost: float = 15.0

# --- INTERNAL ---
var target_node: Node3D = null
var base_fov: float = 75.0
var last_x_pos: float = 0.0 # To track sideways movement

func _ready():
    # 1. Detach from the Player
    top_level = true
    
    # 2. Find the Angel
    target_node = get_tree().get_first_node_in_group("player")
    if not target_node:
        target_node = get_parent() 
        
    base_fov = fov
    
    if target_node:
        global_position = target_node.global_position + default_offset
        look_at(target_node.global_position, Vector3.UP)
        last_x_pos = target_node.global_position.x

func _physics_process(delta):
    if not is_instance_valid(target_node): return
    
    # --- 1. CALCULATE TARGET POSITION ---
    var target_pos = target_node.global_position + default_offset
    
    # --- 2. SMOOTH FOLLOW (The Lag) ---
    global_position = global_position.lerp(target_pos, follow_speed * delta)
    
    # --- 3. DYNAMIC LOOK AT ---
    # Look slightly ahead of the Angel (down the rail)
    var look_target = target_node.global_position
    look_target += Vector3(0, 0, -20.0) # Always look ahead 20 units
        
    # Smooth rotation towards the look target
    var current_transform = global_transform
    var target_transform = current_transform.looking_at(look_target, Vector3.UP)
    global_transform = current_transform.interpolate_with(target_transform, look_speed * delta)
    
    # --- 4. DUTCH TILT (Fixed for Snap Movement) ---
    # Instead of reading Key Inputs, we calculate how far the ship ACTUALLY moved sideways.
    var current_x = target_node.global_position.x
    
    # "x_diff" is how many units we moved left/right this frame
    var x_diff = current_x - last_x_pos
    last_x_pos = current_x
    
    # We amplify this difference to get a lean angle.
    # We invert it (-x_diff) so moving Right banks the camera Left.
    var lean_target = -x_diff * lean_sensitivity * 50.0 
    
    # Clamp it so we don't roll over
    lean_target = clampf(lean_target, -max_lean_degrees, max_lean_degrees)
    
    # Smoothly apply the tilt
    rotation_degrees.z = lerp(rotation_degrees.z, lean_target, 5.0 * delta)
    
    # --- 5. DYNAMIC FOV ---
    var desired_fov = base_fov
    if "speed" in target_node and "max_speed" in target_node:
        var speed_ratio = target_node.speed / target_node.get_max_speed()
        desired_fov += speed_ratio * speed_fov_boost
        
    fov = lerp(fov, desired_fov, 2.0 * delta)
    
    
