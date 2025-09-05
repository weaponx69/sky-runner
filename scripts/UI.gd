extends CanvasLayer

# We'll link this to our SpeedLabel node in the editor.
@onready var speed_label: Label = $SpeedLabel
# We also need a reference to the player controller.
@export var player_controller: PathFollow3D

func _process(_delta):
    # First, check if the player_controller is valid.
    if is_instance_valid(player_controller):
        # Get the current speed from the player controller.
        # We'll use int() to show a whole number.
        var current_speed = int(player_controller.current_speed)
        
        # Update the label's text property.
        speed_label.text = "Speed: %s" % current_speed
