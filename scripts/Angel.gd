# res://scripts/Angel.gd
extends CharacterBody3D

@export var speed: float = 8.0
@export var strafe_speed: float = 5.0
@export var mouse_sensitivity: float = 0.002
@export var boost_speed: float = 25.0
@export var forward_speed: float = 0.0
@export var max_forward_speed: float = 20.0
@export var forward_friction: float = 1.5
@export var orb_push_force: float = 8.0
@export var initial_push: float = 12.0  # Initial forward velocity to start moving

@onready var player_mesh = $PlayerMesh
@export var sway_max_x: float = 0.5
@export var sway_speed: float = 10.0
var pitch: float = 0.0

func _ready():
	var camera = $SpringArm3D/Camera3D
	if camera:
		camera.make_current()
	# Place the camera a little behind and above the angel
	$SpringArm3D.position = Vector3(0, 1.8, 2.5)   # 1.8 m up, 2.5 m back
	$SpringArm3D.rotation_degrees = Vector3(-15, 0, 0)  # tilt 15° downward
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Give initial forward push so the player can reach the first orbs
	forward_speed = initial_push
	velocity.z = -forward_speed  # Apply immediately
	# Add collision exceptions so Area3D orbs don't physically block the character
	var orb_nodes = get_tree().get_nodes_in_group("orbs")
	for orb in orb_nodes:
		if orb is Area3D:
			add_collision_exception_with(orb)
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Mouse look - horizontal rotation (yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Mouse look - vertical rotation (pitch) - limited range
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -PI/4, PI/4)
		$SpringArm3D.rotation.x = pitch

func _physics_process(delta: float) -> void:
	# 1. Set vertical velocity to 0 to prevent falling or rising.
	velocity.y = 0
	# 2. Apply friction to forward movement
	forward_speed = max(forward_speed - forward_friction * delta, 0)
	# 2.5 Handle horizontal input (A/D)
	var input_dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * strafe_speed
	# 3. Handle the visual sway for the mesh based on left/right input.
	var sway_input = input_dir
	var target_pos_x = sway_input * sway_max_x
	player_mesh.position.x = lerp(player_mesh.position.x, target_pos_x, sway_speed * delta)
	# 4. Set forward velocity and apply movement
	velocity.z = -forward_speed
	move_and_slide()
func apply_boost(direction):
	# Set the player's velocity directly for an immediate forward push
	velocity = direction * boost_speed
func _on_orb_collected(push_amount: float = 1.0):
	# Called when an orb is collected
	forward_speed = min(forward_speed + orb_push_force * push_amount, max_forward_speed)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
