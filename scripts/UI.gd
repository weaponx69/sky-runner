extends CanvasLayer

# Drag your SpeedLabel and PlayerPathFollow nodes here in the Inspector
@export var speed_label: Label
@export var player_node: PathFollow3D

func _ready():
    # Check if the nodes are assigned to prevent crashes
    if not speed_label or not player_node:
        print("UI Error: Speed Label or Player Node not assigned in the Inspector!")
        return
    
    # Connect to the player's signal.
    # When the player emits "speed_updated", we call our "_on_player_speed_updated" function.
    player_node.speed_updated.connect(_on_player_speed_updated)
    
    # Set the initial text
    _on_player_speed_updated(player_node.current_speed)

func _on_player_speed_updated(new_speed: float):
    # This function's only job is to update the label.
    # We use %.1f to format the speed to one decimal place.
    speed_label.text = "Speed: %.1f" % new_speed
