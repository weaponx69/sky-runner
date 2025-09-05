extends Node

const ROCK_MODELS = [
    preload("res://assets/rocks/rock1.glb"),
    preload("res://assets/rocks/rock2.glb"),
    preload("res://assets/rocks/rock3.glb")
]

func _ready():
    # example: pick a random rock and instantiate it
    var rock_scene = ROCK_MODELS[randi() % ROCK_MODELS.size()]
    var rock = rock_scene.instantiate()
    add_child(rock)