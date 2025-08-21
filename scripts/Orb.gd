extends Area2D

func _ready():
	# Add to orbs group
	add_to_group("orbs")
	
	# Rotate the orb
	$Sprite2D.rotation_degrees = randf_range(0, 360)
	
	# Animate the orb
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation_degrees", 360, 2.0).set_trans(Tween.TRANS_LINEAR).set_repeat_count(-1)
	tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), 1.0).set_trans(Tween.TRANS_SINE).set_repeat_count(-1).set_loops()
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE)
