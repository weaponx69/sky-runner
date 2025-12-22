## Represents a collectible orb in the game.
#
# This script is attached to an `Area3D` node that represents an orb.
# It adds the orb to the "orbs" group and sets up an animation to make it rotate and pulsate.
extends "res://scripts/PathNode.gd"

## Called when the node is added to the scene. Sets up the orb's animation.
func _ready():
	# Set base properties from PathNode
	is_collectible = true
	momentum_value = 10.0

	# Add to orbs group
	add_to_group("orbs")

	# Rotate the orb
	$Sprite2D.rotation_degrees = randf_range(0, 360)

	# Animate the orb
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation_degrees", 360, 2.0).set_trans(Tween.TRANS_LINEAR).set_repeat_count(-1)
	tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), 1.0).set_trans(Tween.TRANS_SINE).set_repeat_count(-1).set_loops()
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE)
