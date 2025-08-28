extends PathFollow3D

@export_category("Movement")
@export var forward_speed = 10.0 # How fast we move along the path
@export var move_speed = 8.0     # How quickly we steer left and right
@export var horizontal_limit = 5.0 # How far left/right we can move from the center

func _physics_process(delta):
	# --- Automatic Forward Movement ---
	# We increase our own 'progress' property to move forward
	self.progress += forward_speed * delta

	# --- Player Steering Input ---
	# Get horizontal input (A/D or Left/Right Arrows)
	var horizontal_input = Input.get_axis("ui_left", "ui_right")
	
	# --- Calculate Target Horizontal Position ---
	# Determine where the player wants to be based on their input
	var target_h_offset = horizontal_input * horizontal_limit

	# --- Smoothly Move to Target Horizontal Position ---
	# Use lerp to smoothly move the horizontal offset.
	self.h_offset = lerp(self.h_offset, target_h_offset, move_speed * delta)