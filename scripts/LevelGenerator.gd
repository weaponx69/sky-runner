# res://scripts/LevelGenerator.gd
# Edit file: res://scripts/LevelGenerator.gd
# NOTE: Removed 'async' keyword from generate_path_segment; use 'await' within the function instead.
extends Node3D

@export var player_path_follow: PathFollow3D

@export var orb_scene: PackedScene = preload("res://scenes/Orb3D.tscn")
var path3d: Path3D
var curve: Curve3D

var generated_distance: float = 0.0
var active_orbs: Array = []
var orb_pool: Array = []
var last_spawn_distance: float = 0.0

# --- Configuration ---
var segment_length: float = 150.0
var curve_amplitude: float = 7.0
var orb_spacing: float = 10.0
var generation_ahead_distance: float = 400.0
var path_width: float = 10.0
var path_height: float = 2.0
# --------------------
var rng = RandomNumberGenerator.new()

func _ready():
    path3d = get_parent().get_node("Path3D")
    if not path3d:
        push_error("LevelGenerator Error: Path3D node not found!")
        set_process(false) # Stop processing if the path is missing
        return
    
    if not player_path_follow:
        push_error("LevelGenerator Error: 'Player Path Follow' node has not been assigned in the Inspector!")
        set_process(false) # Stop processing if the player reference is missing
        return
    
    if not path3d.curve:
        path3d.curve = Curve3D.new()
    curve = path3d.curve
    
    generate_path_segment(0, 600.0)
    spawn_orbs_on_path()

func _process(_delta):
    # This is our main safety check. If the player node somehow becomes invalid, stop.
    if not is_instance_valid(player_path_follow):
        return

    var player_progress = player_path_follow.progress
    var needed_distance = player_progress + generation_ahead_distance
    
    if needed_distance > generated_distance:
        generate_path_segment(generated_distance, segment_length)
        spawn_orbs_on_path()
        cleanup_old_orbs(player_progress - 100.0)

func generate_path_segment(start_distance: float, length: float):
    var start_point = Vector3.ZERO
    if curve.point_count > 0:
        start_point = curve.get_point_position(curve.point_count - 1)
    else:
        curve.add_point(Vector3.ZERO)
    
    var last_point = start_point
    var points_to_add = 10  # Sweet spot: 10 points for smooth curves
    var step_z = length / float(points_to_add)
    
    for i in range(1, points_to_add + 1):
        var progress = start_distance + (i * step_z)

        var x_offset = sin(progress * 0.05) * curve_amplitude
        var y_offset = cos(progress * 0.08) * (curve_amplitude * 0.5)

        var new_point = start_point + Vector3(x_offset, y_offset, -i * step_z)

        # Smooth handle calculation - this is what matters for smoothness
        var dir = (new_point - last_point).normalized()
        var handle_length = step_z * 0.4  # Slightly longer for smoother curves

        curve.add_point(new_point, -dir * handle_length, dir * handle_length, -1)

        last_point = new_point

    generated_distance = start_distance + length
    curve.bake_interval = 0.15
func spawn_orbs_on_path():
    if not curve or curve.point_count < 2:
        return
    
    var spawn_start = max(last_spawn_distance, 0)
    var spawn_end = generated_distance
    
    if spawn_end <= spawn_start:
        return
    
    var temp_follower = PathFollow3D.new()
    path3d.add_child(temp_follower)
    
    var path_length = curve.get_baked_length()
    var distance = spawn_start
    
    while distance < spawn_end and distance < path_length:
        var half_width = path_width / 2.0
        var random_h_offset = rng.randf_range(-half_width, half_width)
        var half_height = path_height / 2.0
        var random_v_offset = rng.randf_range(-half_height, half_height)
        
        temp_follower.progress = distance
        temp_follower.h_offset = random_h_offset
        temp_follower.v_offset = random_v_offset
        
        var position = temp_follower.global_position
        var orb = get_orb_from_pool()
        if orb:
            orb.global_position = position
            active_orbs.append(orb)
        
        distance += orb_spacing
    
    last_spawn_distance = spawn_end
    temp_follower.queue_free()

func cleanup_old_orbs(cleanup_progress: float):
    var remaining_orbs = []
    for orb in active_orbs:
        if not is_instance_valid(orb):
            continue
        var orb_progress = curve.get_closest_offset(path3d.to_local(orb.global_position))
        if orb_progress < cleanup_progress:
            # Stop tracking orbs that are behind the cleanup threshold.
            # Do NOT attempt to call methods on the orb here — it may already be freed.
            continue
        remaining_orbs.append(orb)
    # Replace the active_orbs list with only the still-relevant, valid orbs.
    active_orbs = remaining_orbs
func get_orb_from_pool() -> Area3D:
    if not orb_pool.is_empty():
        var orb = orb_pool.pop_back()
        orb.visible = true
        orb.process_mode = Node.PROCESS_MODE_INHERIT
        return orb
    
    var new_orb = orb_scene.instantiate()
    add_child(new_orb)
    return new_orb
