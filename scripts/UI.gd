extends CanvasLayer

@onready var momentum_bar = $MarginContainer/VBoxContainer/MomentumBar
@onready var progress_label = $MarginContainer/VBoxContainer/ProgressLabel

func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var angel = player as CharacterBody2D
		if angel.has_method("get_momentum"):
			var momentum = angel.momentum
			var max_momentum = angel.max_momentum
			momentum_bar.value = (momentum / max_momentum) * 100
			progress_label.text = "Distance: %dm" % int(angel.global_position.x / 100)
