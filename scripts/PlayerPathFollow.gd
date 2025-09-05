# res://scripts/PlayerPathFollow.gd
# TODO: Searched file for assignments to 'translation' and found none; no replacements necessary (use 'position' for PathFollow3D).
# res://scripts/PlayerPathFollow.gd
# TODO: No occurrences of 'unit_offset' found. Confirm whether 'progress' should use the PathFollow3D property 'progress_ratio' instead of a custom variable.
# res://scripts/PlayerPathFollow.gd
extends PathFollow3D

@export var base_speed: float = 2.0
@export var lateral_speed: float = 15.0
@export var max_lateral_offset: float = 5.0
@export var acceleration: float = 2.0

#var progress_ratio: float = 0.5
var current_speed: float = 2.0
var paused: bool = false

func _ready():
    # Debug initial positions and path length
    var path_node = get_parent() as Path3D
    var path_length = 0.0
    if path_node and path_node.curve:
        path_length = path_node.curve.get_baked_length()
    print("PlayerPathFollow initial global_position: ", global_position)
    print("Path length: ", path_length)
    print("Initial progress: ", progress, " progress_ratio: ", progress_ratio)

func _process(_delta):
    var angel = get_node_or_null("Angel")
    if angel:
        print("Angel position from path: ", angel.global_position)
    # Allow pausing/unpausing movement with space bar (ui_accept)
    if Input.is_action_just_pressed("ui_accept"):
        paused = not paused
        print("Movement paused: ", paused)
func _physics_process(delta):
    var path_node = get_parent() as Path3D
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
            progress = 0.0

func increase_speed(amount: float):
    base_speed += amount
    current_speed = base_speed
