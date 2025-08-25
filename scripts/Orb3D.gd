# res://scripts/Orb3D.gd
extends Area3D
signal collected
@export var boost_speed := 15.0          # m/s after hit
@export var boost_duration := 1.0        # seconds

func _ready():
	# Connect the body_entered signal to our function
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# If the Angel enters, give it a forward boost for boost_duration seconds
	if body.name == "Angel":
		collected.emit()
		# Set immediate forward velocity and pause the angel's normal physics processing
		body.velocity = Vector3(0, 0, -boost_speed)
		body.set_physics_process(false)
		await get_tree().create_timer(boost_duration).timeout
		body.set_physics_process(true)
		queue_free()
	elif body.is_in_group("player"):
		collected.emit()
		queue_free()
