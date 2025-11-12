# res://scripts/UI.gd
# Fixed version that monitors the Angel (Player) node directly
extends CanvasLayer

@onready var speed_label: Label = $SpeedLabel
@onready var speed_meter: ProgressBar = $SpeedMeter

# Variable to hold the reference to the Angel node
var player_node: Node3D

func _ready():
    # Wait a frame to ensure the main scene and the Angel node are ready
    await get_tree().process_frame
    
    # 1. Find the Angel (Player) node using the 'player' group
    player_node = get_tree().get_first_node_in_group("player")
    
    if is_instance_valid(player_node):
        print("UI: Found Angel (Player) node")
        
        # Set up progress bar using properties from the Angel script
        # Note: These properties must be declared as @export or public in Angel.gd
        if player_node.has_meta("min_speed") and player_node.has_meta("max_speed"):
            # Using get_meta/set_meta if they are not exposed properties
            speed_meter.max_value = player_node.max_speed # Assumes max_speed is a public or exported property
            speed_meter.min_value = player_node.min_speed # Assumes min_speed is a public or exported property
        else:
            # Fallback values
            speed_meter.max_value = 20.0
            speed_meter.min_value = 5.0
            
        # 2. Connect signal: The Angel.gd script needs to emit this signal now!
        if player_node.has_signal("speed_changed"):
            player_node.speed_changed.connect(_on_player_speed_changed)
            print("UI: Signal connected")
        else:
            push_warning("UI: 'speed_changed' signal not found on the Angel node. UI updates will only occur once.")
            
        # 3. Set initial display
        # Assumes the 'speed' property is available on the Angel node
        var initial_speed = player_node.speed if player_node.has_meta("speed") else speed_meter.min_value
        speed_label.text = "Speed: %d" % round(initial_speed)
        speed_meter.value = initial_speed
    else:
        push_error("UI: Angel (Player) node not found in 'player' group.")
        
func _on_player_speed_changed(new_speed: float):
    # This function is called every time the Angel node emits the signal
    speed_meter.value = new_speed
    speed_label.text = "Speed: %d" % round(new_speed)
