# res://scripts/UI.gd
extends CanvasLayer

@onready var speed_label: Label = $SpeedLabel
@onready var player_path_follow: PathFollow3D = get_node("../Path3D/PlayerPathFollow")
@onready var speed_meter: TextureProgressBar = $SpeedMeter

func _ready():
    # Set the meter's max value based on the player's max speed.
    speed_meter.max_value = player_path_follow.max_speed
    
    # Connect to the player's speed_changed signal to know when to update the UI.
    player_path_follow.speed_changed.connect(_on_player_speed_changed)
    # Set the initial speed value on the label.
    _on_player_speed_changed(player_path_follow.current_speed)

func _on_player_speed_changed(new_speed: float):
    # Update the meter's value.
    speed_meter.value = new_speed
    
    # Update the label's text with the new speed, rounded to a whole number.
    speed_label.text = "Speed: %d" % round(new_speed)
