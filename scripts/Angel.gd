# res://scripts/Angel.gd
# Edit file: res://scripts/Angel.gd
extends Area3D

@export_group("Movement")
@export var horizontal_speed = 8.0
@export var vertical_speed = 4.0
@export var max_horizontal_distance = 5.0
@export var max_vertical_distance = 3.0

var parent_path_follow: PathFollow3D

func _ready():
    parent_path_follow = get_parent() as PathFollow3D
    if not parent_path_follow:
        push_error("Angel's parent is not a PathFollow3D! Movement will not work.")
        set_physics_process(false)
    else:
        print("Angel script is ready and connected to PathFollow3D.")

func _physics_process(delta):
    # 1. Get player input as a 2D vector.
    var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    # If there's any input, print it to the console.
    if input_vector != Vector2.ZERO:
        print("Input detected: ", input_vector)

    # 2. Update the parent's offsets.
    parent_path_follow.h_offset += input_vector.x * horizontal_speed * delta
    # We invert the Y-axis because ui_up gives a negative value, but we want to move up (positive v_offset).
    parent_path_follow.v_offset -= input_vector.y * vertical_speed * delta
    
    # 3. Clamp the offset values.
    parent_path_follow.h_offset = clamp(parent_path_follow.h_offset, -max_horizontal_distance, max_horizontal_distance)
    parent_path_follow.v_offset = clamp(parent_path_follow.v_offset, -max_vertical_distance, max_vertical_distance)
    
    # Print the current offsets every frame to see if they are changing.
    # print("Current Offsets - H: ", parent_path_follow.h_offset, " V: ", parent_path_follow.v_offset)

func _on_area_entered(area):
    # Check if the area we collided with is an Orb
    if area.is_in_group("orbs"):
        # Tell the parent PathFollow3D to increase its speed
        if parent_path_follow and parent_path_follow.has_method("boost"):
            parent_path_follow.boost()
        
        # Tell the orb to handle its own collection logic (like disappearing)
        if area.has_method("collect"):
            area.collect()
