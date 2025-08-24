# res://scripts/LevelGenerator.gd
# Edit file: res://scripts/LevelGenerator.gd
extends Node3D

@export var orb_scene: PackedScene
@export var orb_count: int = 5
@export var spawn_distance: float = 20.0
@export var spawn_height_range: Vector2 = Vector2(-5, 5)
@export var spawn_width_range: Vector2 = Vector2(-10, 10)
@export var initial_first_distance: float = 10.0
@export var initial_spacing: float = 10.0
@export var initial_count: int = 5

func _ready():
	if orb_scene == null:
		push_error("OrbGenerator: orb_scene is not set!")
		return
	
	randomize()
	await get_tree().process_frame
	spawn_initial_orbs()
func spawn_initial_orbs():
	var scene = get_tree().current_scene
	if scene == null:
		push_error("LevelGenerator: No current_scene to spawn orbs into.")
		return
	var angel = null
	if scene.has_node("Angel"):
		angel = scene.get_node("Angel")
	else:
		push_error("LevelGenerator: Angel node not found in current scene. Spawning relative to scene origin.")
	var base_pos: Vector3 = Vector3.ZERO
	if angel:
		base_pos = angel.global_position
	else:
		base_pos = scene.transform.origin
	for i in range(initial_count):
		var orb := orb_scene.instantiate()
		var spawn_pos := base_pos + Vector3(0, 1.5, -(initial_first_distance + i * initial_spacing))
		orb.global_position = spawn_pos
		scene.add_child.call_deferred(orb)

func generate_orbs():
	# Clear existing orbs
	for child in get_children():
		if child.has_method("is_orb") or child.name.begins_with("Orb"):
			child.queue_free()
	
	# Spawn new orbs from horizon
	for i in range(orb_count):
		var orb_instance = orb_scene.instantiate()
		orb_instance.name = "Orb%d" % (i + 1)
		
		# Calculate position in front of player (along Z axis)
		var base_pos = transform.origin
		
		# Spawn orbs in a horizontal pattern at spawn_distance
		var angle = (i * 2.0 * PI) / orb_count
		var x = sin(angle) * ((spawn_width_range.x + spawn_width_range.y) * 0.5)
		var y = randf_range(spawn_height_range.x, spawn_height_range.y)
		var z = -spawn_distance  # Negative Z is forward in camera view
		
		# Set local position relative to self (safe before adding to scene tree)
		orb_instance.position = base_pos + Vector3(x, y, z)
		
		# Make orbs move toward this generator's position if they support velocity
		if orb_instance.has_method("set_velocity"):
			var direction_to_player = (base_pos - orb_instance.position).normalized()
			orb_instance.set_velocity(direction_to_player * 3.0)
		add_child(orb_instance)
