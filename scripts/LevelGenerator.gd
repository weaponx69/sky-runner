extends Node2D

@export var orb_scene: PackedScene
@export var obstacle_scene: PackedScene
@export var level_length: float = 10000.0
@export var orb_density: float = 0.8
@export var obstacle_density: float = 0.3

var generated_distance: float = 0.0
var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
func _process(delta):
	if player:
		var player_x = player.global_position.x
		generate_chunks(player_x + 1000)

func generate_chunks(ahead_distance: float):
	while generated_distance < ahead_distance:
		generate_chunk(generated_distance)
		generated_distance += 500

func generate_chunk(start_x: float):
	# Generate orbs
	for i in range(int(orb_density * 10)):
		var orb = orb_scene.instantiate()
		orb.global_position = Vector2(
			start_x + randf_range(0, 500),
			randf_range(-200, 200)
		)
		add_child(orb)
	
	# Generate obstacles
	for i in range(int(obstacle_density * 5)):
		var obstacle = obstacle_scene.instantiate()
		obstacle.global_position = Vector2(
			start_x + randf_range(0, 500),
			randf_range(-150, 150)
		)
		add_child(obstacle)
