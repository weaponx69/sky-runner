# res://scripts/Angel.gd
extends CharacterBody3D

@export var speed: float = 8.0
@export var strafe_speed: float = 5.0
@export var mouse_sensitivity: float = 0.002

var pitch: float = 0.0

func _ready():
	var camera = $SpringArm3D/Camera3D
	if camera:
		camera.make_current()
	
	# Place the camera a little behind and above the angel
	$SpringArm3D.position = Vector3(0, 1.8, 2.5)   # 1.8 m up, 2.5 m back
	$SpringArm3D.rotation_degrees = Vector3(-15, 0, 0)  # tilt 15° downward
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Mouse look - horizontal rotation (yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Mouse look - vertical rotation (pitch) - limited range
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -PI/4, PI/4)
		$SpringArm3D.rotation.x = pitch

func _physics_process(delta: float) -> void:
	# Constant speed straight down the world -Z axis
	velocity = Vector3(0, 0, -speed)
	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
