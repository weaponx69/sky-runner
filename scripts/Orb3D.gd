extends Area3D

func _ready():
	# Ensure Area3D only detects, doesn't physically collide
	collision_layer = 0  # Don't be part of any collision layer
	collision_mask = 1   # Only detect player on layer 1
	
	# Add to orbs group for collision exception management
	add_to_group("orbs")
	
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("_on_orb_collected"):
		body._on_orb_collected()
	queue_free()
