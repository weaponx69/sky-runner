# res://scripts/Angel.gd
extends CharacterBody2D

# Movement variables
const FORWARD_SPEED = 250.0
const LIFT_FORCE = 600.0
const GRAVITY = 1200.0

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle flying input
	if Input.is_action_pressed("ui_accept"): # "ui_accept" is usually the Space bar
		velocity.y = -LIFT_FORCE

	# Set constant forward movement
	velocity.x = FORWARD_SPEED
	
	move_and_slide()
