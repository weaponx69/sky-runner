# res://scripts/Angel.gd
extends Area3D

@export_group("Movement")
@export var horizontal_speed = 8.0
@export var vertical_speed = 4.0
@export var max_horizontal_distance = 5.0
@export var max_vertical_distance = 3.0

@export var spawner: Node
var parent_path_follow: PathFollow3D
func _ready():
    parent_path_follow = get_parent() as PathFollow3D
    if not parent_path_follow:
        push_error("Angel's parent is not a PathFollow3D! Movement will not work.")
        set_physics_process(false)
    else:
        print("Angel script is ready and connected to PathFollow3D.")
        # Connect the area_entered signal to the function
        area_entered.connect(self._on_area_entered)

func _physics_process(delta):
    # 1. Get player input as a 2D vector.
    var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    # 2. Update the parent's offsets.
    parent_path_follow.h_offset += input_vector.x * horizontal_speed * delta
    # ui_up is negative, so we subtract to move up
    #parent_path_follow.v_offset -= input_vector.y * vertical_speed * delta
    
    # 3. Clamp the offset values.
    parent_path_follow.h_offset = clamp(parent_path_follow.h_offset, -max_horizontal_distance, max_horizontal_distance)
    parent_path_follow.v_offset = clamp(parent_path_follow.v_offset, -max_vertical_distance, max_vertical_distance)

func _on_area_entered(area: Area3D):
    # Prevent accessing already-freed instances or ones queued for deletion
    if not is_instance_valid(area) or area.is_queued_for_deletion():
        return
    # Check if the area we collided with is an Orb
    if area.is_in_group("orbs"):
        # Tell the parent PathFollow3D to increase its speed
        if parent_path_follow and parent_path_follow.has_method("add_speed_boost"):
            parent_path_follow.add_speed_boost()
        # Return the orb to the spawner's pool if available; otherwise free it
        if spawner and spawner.has_method("return_orb_to_pool"):
            spawner.return_orb_to_pool(area)
        else:
            area.queue_free()
    # Check if the area we collided with is an obstacle
    elif area.is_in_group("obstacles"):
        print("Collision with an obstacle! Game over.")
        get_tree().call_deferred("reload_current_scene")
