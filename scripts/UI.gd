# Edit file: res://scripts/UI.gd
extends CanvasLayer

@onready var speed_label: Label = $SpeedLabel
@onready var speed_meter: ProgressBar = $SpeedMeter

func _ready():
    # Wait a frame to ensure PlayerPathFollow is ready
    await get_tree().process_frame
    
    var player_path_follow = get_node("../Path3D/PlayerPathFollow")
    if player_path_follow:
        print("UI: Found PlayerPathFollow")
        
        # Set up progress bar
        if player_path_follow.has_method("get"):
            speed_meter.max_value = player_path_follow.max_speed
            speed_meter.min_value = player_path_follow.min_speed
        else:
            # Fallback values
            speed_meter.max_value = 20.0
            speed_meter.min_value = 5.0
        
        # Connect signal
        if player_path_follow.has_signal("speed_changed"):
            player_path_follow.speed_changed.connect(_on_player_speed_changed)
            print("UI: Signal connected")
        else:
            print("UI: speed_changed signal not found")
    else:
        print("UI: PlayerPathFollow not found")
    
    # Set initial display
    speed_label.text = "Speed: 5"
    speed_meter.value = 5.0

func _on_player_speed_changed(new_speed: float):
    #print("UI: Speed updated to: ", new_speed)
    speed_meter.value = new_speed
    speed_label.text = "Speed: %d" % round(new_speed)
