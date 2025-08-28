# res://scripts/Angel.gd
extends CharacterBody3D

@export_category("Movement")
@export var forward_speed = 10.0 # How fast the Angel moves along the path
@export var move_speed = 8.0     # How quickly the Angel steers left and right
@export var horizontal_limit = 5.0 # How far left/right the Angel can move from the center of the path

@export_category("Setup")
@export var path_follow_node: PathFollow3D # Assign this in the Inspector!

func _physics_process(delta):
	# Safety check: Do nothing if the node hasn't been assigned in the editor.
	if not path_follow_node:
		push_warning("The 'Path Follow Node' has not been assigned in the Inspector for the Angel script.")
		return

	# --- Automatic Forward Movement ---
	# We increase the 'progress' on the PathFollow3D node to move forward
	path_follow_node.progress += forward_speed * delta

	# --- Player Steering Input ---
	# Get horizontal input (A/D or Left/Right Arrows)
	var horizontal_input = Input.get_axis("ui_left", "ui_right")

	# --- Calculate Target Horizontal Position ---
	# Determine where the player wants to be based on their input
	var target_h_offset = horizontal_input * horizontal_limit

	# --- Smoothly Move to Target Horizontal Position ---
	# Use lerp (linear interpolation) to smoothly move the horizontal offset.
	path_follow_node.h_offset = lerp(path_follow_node.h_offset, target_h_offset, move_speed * delta)
