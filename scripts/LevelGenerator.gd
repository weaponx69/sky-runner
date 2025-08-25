# Replace file content: res://scripts/LevelGenerator.gd
extends Node3D

@export var orb_scene: PackedScene
@export var number_of_orbs: int = 20
@export var spawn_radius: float = 30.0


func _ready():
	assert(orb_scene != null, "Orb Scene is not set in the LevelGenerator. Please assign Orb3D.tscn in the Inspector.")

	for i in range(number_of_orbs):
		var orb_instance = orb_scene.instantiate()

		var random_angle = randf_range(0, TAU)
		var random_distance = randf_range(5.0, spawn_radius)
		
		var spawn_position = Vector3(
			cos(random_angle) * random_distance,
			1.0,
			sin(random_angle) * random_distance
		)

		orb_instance.position = self.position + spawn_position

		get_parent().call_deferred("add_child", orb_instance)
