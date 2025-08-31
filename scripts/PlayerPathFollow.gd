# res://scripts/PlayerPathFollow.gd
# Edit file: res://scripts/PlayerPathFollow.gd
extends PathFollow3D

@export var forward_speed: float = 5.0
@export var strafe_speed: float = 5.0
@export var max_strafe_offset: float = 8.0
@export var speed_boost_amount: float = 2.0

# --- ADD THESE VARIABLES TO SIMULATE FRICTION ---
# How quickly speed is lost. 1.0 = no loss. 0.99 = slow loss.
@export var speed_decay_rate: float = 0.998
# The base speed the player will slow down to.
@export var min_speed: float = 5.0

var current_strafe_offset: float = 0.0
var base_position: Vector3 = Vector3.ZERO
@onready var speed_label: Label = get_node("/root/MainGame/CanvasLayer/SpeedLabel")
func _ready():
    # Check path details and increase bake resolution
    var curve = get_parent().curve
    if curve:
        print("Path has ", curve.get_point_count(), " points")
        print("Baked points: ", curve.get_baked_points().size())
        print("Bake interval: ", curve.bake_interval)
        # Increase resolution for smoother movement
        curve.bake_interval = 0.02
        # Force rebake/read baked points after changing interval
        print("New baked points: ", curve.get_baked_points().size())
        # Optional: tessellate if available to generate additional smooth points
        if curve.get_point_count() > 1 and curve.has_method("tessellate"):
            var smooth_points = curve.tessellate(8, 2.0)
            print("Generated ", smooth_points.size(), " smooth points (tessellate)")
    else:
        print("No Curve3D found!")

func _physics_process(delta):
    if forward_speed > min_speed:
        forward_speed *= speed_decay_rate
    
    # Move along path normally
    progress += forward_speed * delta
    
    # Store the path position without strafing
    base_position = global_position
    
    # Get strafe input
    var strafe_direction = 0.0
    if Input.is_action_pressed("ui_right"):
        strafe_direction += 1.0
    if Input.is_action_pressed("ui_left"):
        strafe_direction -= 1.0
    
    # Calculate strafe offset
    current_strafe_offset += strafe_direction * strafe_speed * delta
    current_strafe_offset = clamp(current_strafe_offset, -max_strafe_offset, max_strafe_offset)
    
    # Apply strafe using a more reliable method
    # Get the path's forward direction
    var forward = -transform.basis.z
    # Get right direction perpendicular to forward and up
    var right = forward.cross(Vector3.UP).normalized()
    
    # Apply the offset
    global_position = base_position + right * current_strafe_offset
    
    if speed_label:
        speed_label.text = "Speed: %.1f" % forward_speed
# --- ADD THIS FUNCTION ---
# This function is called by the Orb3D.gd script
func add_speed_boost():
    forward_speed += speed_boost_amount
    print("Speed boosted! New speed: ", forward_speed)
