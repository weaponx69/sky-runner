# res://scripts/LevelGenerator.gd
extends Node3D

@export var orb_scene: PackedScene
@export var spawn_distance: float = 15.0
@export var spawn_width: float = 12.0
@export var spawn_height: float = 5.0

var player: Node3D
var next_spawn_z: float = 0.0

func _ready():
	assert(orb_scene != null, "Orb Scene is not set in the LevelGenerator. Please assign Orb3D.tscn in the Inspector.")
	# Find the player node
	if has_node("../Angel"):
		player = get_node("../Angel")
	elif get_parent() and get_parent().has_node("Angel"):
		player = get_parent().get_node("Angel")
	# Wait a frame to ensure everything is in the tree
	call_deferred("spawn_initial_orbs")

func spawn_initial_orbs():
	# Spawn multiple initial orb lines closer to player
	for i in range(3):
		spawn_orbs_at_z(-i * 15.0)
	next_spawn_z = -45.0

func _process(delta):
	if not player:
		return
	# Check if player is approaching the next spawn zone
	var player_z = player.global_position.z
	if player_z < next_spawn_z + spawn_distance * 2:
		spawn_orbs_at_z(next_spawn_z)
		next_spawn_z -= spawn_distance

func spawn_orbs_at_z(z_pos):
	# Spawn 5-8 orbs in a horizontal line
	var orb_count = randi_range(5, 8)
	var spacing = spawn_width / (orb_count - 1) if orb_count > 1 else 0.0
	var start_x = -spawn_width / 2
	for i in range(orb_count):
		var orb = orb_scene.instantiate()
		add_child(orb)  # Add to tree first
		var x_pos = start_x + (i * spacing)
		var y_pos = randf_range(-spawn_height/2, spawn_height/2)
		orb.global_position = Vector3(x_pos, y_pos, z_pos)

func _on_orb_collected(push_amount: float = 1.0):
	# This will be called by orbs when collected
	if player and player.has_method("_on_orb_collected"):
		player._on_orb_collected(push_amount)
