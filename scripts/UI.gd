## Manages the user interface, including the speed label and speed meter.
#
# This script finds the player node and connects to its `speed_changed` signal
# to keep the UI updated with the player's current speed.
extends CanvasLayer

## The `Label` used to display the player's speed as text.
@onready var speed_label: Label = $SpeedLabel
## The `ProgressBar` used to visually represent the player's speed.
@onready var speed_meter: ProgressBar = $SpeedMeter

## A reference to the player node.
var player_node: Node3D

## Called when the node enters the scene tree for the first time.
# Initializes the UI by finding the player, setting up the speed meter,
# and connecting to the player's `speed_changed` signal.
func _ready():
    # Wait for one frame to ensure the main scene and the player node are ready.
    await get_tree().process_frame
    
    player_node = get_tree().get_first_node_in_group("player")
    
    if is_instance_valid(player_node):
        print("UI: Found Angel (Player) node")
        
        # Configure the speed meter's min and max values based on the player's properties.
        if player_node.has_meta("min_speed") and player_node.has_meta("max_speed"):
            speed_meter.max_value = player_node.max_speed
            speed_meter.min_value = player_node.min_speed
        else:
            # Use fallback values if the properties are not found.
            speed_meter.max_value = 20.0
            speed_meter.min_value = 5.0
            
        # Connect to the player's `speed_changed` signal to receive updates.
        if player_node.has_signal("speed_changed"):
            player_node.speed_changed.connect(_on_player_speed_changed)
            print("UI: Signal connected")
        else:
            push_warning("UI: 'speed_changed' signal not found on the Angel node. UI updates will only occur once.")
            
        # Set the initial UI display based on the player's starting speed.
        var initial_speed = player_node.speed if player_node.has_meta("speed") else speed_meter.min_value
        speed_label.text = "Speed: %d" % round(initial_speed)
        speed_meter.value = initial_speed
    else:
        push_error("UI: Angel (Player) node not found in 'player' group.")
        
## Called when the player's speed changes.
# Updates the speed meter and speed label with the new value.
# - `new_speed`: The player's new speed.
func _on_player_speed_changed(new_speed: float):
    speed_meter.value = new_speed
    speed_label.text = "Speed: %d" % round(new_speed)
