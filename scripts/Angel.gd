# res://scripts/Angel.gd
extends Area3D

# This script is intentionally left blank.
# The Angel node is a CharacterBody3D for collision purposes,
# but all of its movement logic (forward and side-to-side) is now
# handled by the PlayerPathFollow.gd script on its parent node.
# This prevents two scripts from fighting for control.

func _process(_delta):
	# We can leave this function empty or use 'pass'.
	pass

func _physics_process(_delta):
	# We should also ensure the physics process is empty.
	pass
