extends Node2D

# Get a reference to the Camera2D node.
# The % symbol is a shortcut to get a unique child node.
@onready var camera = %Camera2D

func _ready():
	# Tell the viewport to use this camera.
	camera.make_current()