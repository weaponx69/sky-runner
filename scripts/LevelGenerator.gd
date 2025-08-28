# res://scripts/LevelGenerator.gd
extends Node3D

var orb_scene = preload("res://scenes/Orb3D.tscn")
var path3d: Path3D
var curve: Curve3D

var generated_distance: float = 0.0
var active_orbs: Array = []
var orb_pool: Array = []
var last_spawn_distance: float = 0.0

# --- Configuration ---
var segment_length: float = 150.0
var curve_amplitude: float = 7.0
var orb_spacing: float = 3.0
var generation_ahead_distance: float = 400.0
var path_width: float = 4.0
var path_height: float = 2.0
# --------------------
var rng = RandomNumberGenerator.new()

func _ready():
	# Find Path3D automatically, assuming it's a sibling node
	path3d = get_parent().get_node("Path3D")
	if not path3d:
		push_error("LevelGenerator Error: Path3D node not found! Make sure it's a sibling of this node.")
		return
	
	# Create a new curve resource if one doesn't exist
	if not path3d.curve:
		path3d.curve = Curve3D.new()
	curve = path3d.curve
	
	# Create the initial path segment so the player has something to see
	generate_path_segment(0, 600.0)
	spawn_orbs_on_path()

func _process(delta):
	if not is_instance_valid(path3d) or not curve:
		return
	
	# Find the player node in the scene
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Use the player's forward position (absolute Z value) to track progress
	var player_progress = abs(player.global_position.z)

	# Check if we need to generate more path ahead of the player
	var needed_distance = player_progress + generation_ahead_distance
	
	if needed_distance > generated_distance:
		generate_path_segment(generated_distance, segment_length)
		spawn_orbs_on_path()
		
		# Clean up orbs that are far behind the player to save memory
		cleanup_old_orbs(player_progress - 100.0)

func generate_path_segment(start_distance: float, length: float):
	# Start from the last point on the curve or the origin if it's the first segment
	var start_point = Vector3.ZERO
	if curve.point_count > 0:
		start_point = curve.get_point_position(curve.point_count - 1)
	else:
		# Ensure the very first point is at 0,0,0
		curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 1)

	var current_pos = start_point
	var points_to_add = int(length / 5.0) # More points for a smoother curve

	# Add new points to create a winding path in the -Z direction (forward)
	for i in range(1, points_to_add + 1):
		var t = float(i) / points_to_add
		var progress = start_distance + (t * length)
		
		# Use sine waves to create a windy, twisty feel
		var x_offset = sin(progress * 0.05) * curve_amplitude
		var y_offset = cos(progress * 0.08) * (curve_amplitude * 0.5)
		var z_step = -length / float(points_to_add) # Move in the -Z direction
		
		var new_point = current_pos + Vector3(x_offset, y_offset, z_step)
		curve.add_point(new_point)
		
		current_pos = new_point

	generated_distance = start_distance + length

func spawn_orbs_on_path():
	if not curve or curve.point_count < 2:
		return
	var spawn_start = last_spawn_distance
	var spawn_end = generated_distance
	
	if spawn_end <= spawn_start:
		return
	
	# Temporary PathFollow3D to compute offsets
	var temp_follower = PathFollow3D.new()
	path3d.add_child(temp_follower)
	var path_length = curve.get_baked_length()
	var distance = spawn_start
	while distance < spawn_end:
		if distance >= path_length:
			break
		# Pick a random horizontal offset within the configured path width
		var half_width = path_width / 2.0
		var random_h_offset = rng.randf_range(-half_width, half_width)
		# Pick a random vertical offset within the configured path height
		var half_height = path_height / 2.0
		var random_v_offset = rng.randf_range(-half_height, half_height)
		# Position the follower and read its global position
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
	var orbs_to_remove = []
	for orb in active_orbs:
		# Check if an orb is behind the cleanup threshold
		if abs(orb.global_position.z) < cleanup_progress:
			orbs_to_remove.append(orb)
	
	for orb in orbs_to_remove:
		remove_orb(orb)

func get_orb_from_pool() -> Area3D:
	if not orb_pool.is_empty():
		var orb = orb_pool.pop_back()
		orb.visible = true
		orb.process_mode = Node.PROCESS_MODE_INHERIT
		return orb
	
	var new_orb = orb_scene.instantiate()
	add_child(new_orb)
	return new_orb

func remove_orb(orb: Area3D):
	if orb in active_orbs:
		active_orbs.erase(orb)
		orb.visible = false
		orb.process_mode = Node.PROCESS_MODE_DISABLED
		# Move it far away to hide it
		orb.global_position = Vector3(0, -1000, 0) 
		orb_pool.append(orb)
