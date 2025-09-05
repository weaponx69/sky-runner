# res://scripts/PlayerPathFollow.gd
extends PathFollow3D

signal speed_changed(new_speed)

@export var base_speed: float = 12.0
@export var speed_increment: float = 2.0
@export var lateral_speed: float = 15.0
@export var max_lateral_offset: float = 5.0
@export var acceleration: float = 2.0
@export var max_speed: float = 50.0
@export var current_speed: float

# New variables for the tilting effect
@export_group("Visuals")
@export var max_tilt_angle: float = 30.0
@export var tilt_speed: float = 5.0

var paused: bool = false
# FIX: This line declares the 'angel' variable and gets the node.
# This is what was missing and causing the error.
@onready var angel: Node3D = $Angel


func _ready():
    current_speed = base_speed
    # Emit the initial speed so the UI can display it at the start.
    speed_changed.emit(current_speed)
    
    # Debug initial positions and path length
    var path_node = get_parent() as Path3D
    var path_length = 0.0
    if path_node and path_node.curve:
        path_length = path_node.curve.get_baked_length()
    print("PlayerPathFollow initial global_position: ", global_position)
    print("Path length: ", path_length)
    print("Initial progress: ", progress, " progress_ratio: ", progress_ratio)

func _process(_delta):
    var _angel = get_node_or_null("Angel")
    #if angel:
        #print("Angel position from path: ", angel.global_position)
    # Allow pausing/unpausing movement with space bar (ui_accept)
    if Input.is_action_just_pressed("ui_accept"):
        paused = not paused
        print("Movement paused: ", paused)
        
func _physics_process(delta):
    if paused:
        return
        
    var path_node = get_parent() as Path3D
    # Move the node forward along the path based on the current speed.
    #progress += current_speed * delta
    if not path_node or not path_node.curve:
        return
    
    var curve_length = path_node.curve.get_baked_length()
    if curve_length <= 0:
        return
    
    if not paused:
        # Smooth acceleration
        current_speed = lerp(current_speed, base_speed, acceleration * delta)
        
        # Forward movement
        progress += current_speed * delta
                
        # Lateral movement
        var input_dir = 0.0
        if Input.is_action_pressed("ui_left"):
            input_dir -= 1.0
        if Input.is_action_pressed("ui_right"):
            input_dir += 1.0
            
        self.h_offset = clamp(self.h_offset + input_dir * lateral_speed * delta, -max_lateral_offset, max_lateral_offset)
        # Loop around
        if progress > curve_length:
            progress = fmod(progress, curve_length)
            
        # --- New Tilting Logic ---
        # Calculate the target tilt based on player input. Note the inversion (-input_dir).
        var target_tilt_rad = deg_to_rad(-input_dir * max_tilt_angle)
    
        # Smoothly interpolate the angel's z rotation towards the target tilt.
        angel.rotation.z = lerp(angel.rotation.z, target_tilt_rad, tilt_speed * delta)

func increase_speed(amount: float):
    # FIX: We now increase the base_speed and clamp IT against the max_speed.
    # This makes max_speed the true ceiling for our target speed.
    base_speed = min(base_speed + amount, max_speed)
    
    # We no longer need to touch current_speed here directly.
    # The lerp() in _physics_process will handle accelerating to the new base_speed smoothly.
    # We still emit the signal to update the UI, showing the target speed.
    speed_changed.emit(base_speed)
