# res://scripts/Orb3D.gd
extends Area3D
signal collected

func _ready():
	# Connect the body_entered signal to our function
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body that entered is in the "player" group
	if body.is_in_group("player"):
		collected.emit()
		queue_free() # The orb disappears
