## The main game scene, responsible for setting up the camera.
#
# This script ensures that the `Camera2D` node is the current camera for the viewport.
extends Node2D

## A reference to the Camera2D node in the scene. The `%` symbol is a shortcut to get a unique child node.
@onready var camera = %Camera2D

## Called when the node is added to the scene. Makes the camera the current camera for the viewport.
func _ready():
	# Tell the viewport to use this camera.
	camera.make_current()