# res://scripts/Angel.gd
# Edit file: res://scripts/Angel.gd
# Simplified version that just follows the PathFollow3D
extends Area3D
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh
@export var turn_speed: float = 3.0
@export var max_h_offset := 20.0
@export var h_move_speed := 15.0
@export var max_health := 100
@export var damage_amount := 25

var current_health := max_health
var target_h_offset := 0.0
var target_yaw: float = 0.0


func _ready():
    set_process_mode(Node.PROCESS_MODE_ALWAYS)  # Allows processing when paused
    camera.make_current()
    
    # Set up collision layers for proper detection
    collision_layer = 1  # Player on layer 1
    collision_mask = 1   # Detect obstacles on layer 1
    
    # Debug collision setup
    print("Angel collision - Layer: ", collision_layer, " Mask: ", collision_mask)
    print("Angel in player group: ", is_in_group("player"))
    
    # Ensure monitoring is enabled
    monitoring = true
    monitorable = true
    
    # Connect the area_entered signal once
    area_entered.connect(_on_area_entered)
    
    # Make sure this camera is the active one
    camera.make_current()
    # Orient the player mesh
    player_mesh.rotation_degrees = Vector3(0, -90, 0)
    # Reset everything to default relative positioning
    spring_arm.position = Vector3(0, 2, 0)  # Spring arm 2 units above angel
    spring_arm.rotation = Vector3(0, 0, 0)  # No rotation
    # Position camera far back using spring arm length
    camera.position = Vector3(0, 0, -30)  # 30 units back in local space
    # Ensure camera looks forward (along -Z)
    camera.rotation = Vector3(0, 0, 0)
    # Create a simple colored cube to show forward direction
    var cube = MeshInstance3D.new()
    var box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(0.5, 0.5, 2.0)  # Long box pointing forward
    cube.mesh = box_mesh
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED
    # Override the material on the mesh instance
    cube.set_surface_override_material(0, material)
    # Position it in front of the angel
    cube.position = Vector3(0, 0, 2)
    add_child(cube)


func take_damage(amount):
    current_health = max(current_health - amount, 0)  # Clamp at 0
    print("Health: ", current_health)
    if current_health <= 0:
        game_over()

 
func game_over():
    print("Game Over!")
    # Stop the game
    get_tree().paused = true
    
    # Optional: show game over UI or restart
    # You can add a simple restart after delay
    await get_tree().create_timer(2.0).timeout
    get_tree().reload_current_scene()  # Restart the level


func _process(delta):
    var path_follow = get_parent() as PathFollow3D
    if path_follow:
        # Use arrow keys for h_offset movement
        var input_dir = Input.get_axis("ui_right", "ui_left")
        target_h_offset = clamp(target_h_offset + input_dir * h_move_speed * delta, -max_h_offset, max_h_offset)
        path_follow.h_offset = lerp(path_follow.h_offset, target_h_offset, 10.0 * delta)


func _physics_process(delta):
    # 1. PathFollow3D drives position
    var path_follow = get_parent() as PathFollow3D
    if path_follow:
        global_position = path_follow.global_position

    # 2. Read the path's forward direction
    var curve = path_follow.get_parent().curve
    var xf = curve.sample_baked_with_rotation(path_follow.progress)
    var forward = xf.basis.z

    # 3. Convert to yaw
    var path_yaw = atan2(forward.x, forward.z)

    # 4. Player steering (Q/E keys for rotation)
    var steer = 0.0
    if Input.is_physical_key_pressed(KEY_Q):
        steer -= 90.0 * delta
    if Input.is_physical_key_pressed(KEY_E):
        steer += 90.0 * delta
    target_yaw += steer
    
    var max_turn = deg_to_rad(20.0)
    var clamped_yaw = clamp(path_yaw + target_yaw, path_yaw - max_turn, path_yaw + max_turn)

    # 5. Smoothly rotate the angel
    var current_yaw = rotation.y
    rotation.y = lerp_angle(current_yaw, clamped_yaw, turn_speed * delta)


# Update the _on_area_entered function
func _on_area_entered(area):
    if area.is_in_group("orbs"):
        var path_follow = get_parent() as PathFollow3D
        if path_follow and path_follow.has_method("increase_speed"):
            print("Angel: Calling increase_speed")
            path_follow.increase_speed()
            area.queue_free()
        else:
            print("Angel: PathFollow3D missing increase_speed method")
    elif area.is_in_group("obstacles"):
        take_damage(damage_amount)
        area.queue_free()

    #if area.is_in_group("orbs"):
        #print("Orb collected!")
        #var path_follow = get_parent() as PathFollow3D
        #if path_follow:
            ## Try to find the UI to update speed
            #var ui = get_tree().get_first_node_in_group("ui")
            #if ui and ui.has_method("update_speed"):
                #ui.update_speed(10)  # Add 10 to speed
            #else:
                ## Direct speed increase if possible
                #if path_follow.has_method("increase_speed"):
                    #path_follow.increase_speed(10)
                #else:
                    #print("Orb collected but no speed update method found")
        #area.queue_free()
    #elif area.is_in_group("obstacles"):
        #take_damage(damage_amount)
        #area.queue_free()
#
    #if area.is_in_group("orbs"):
        #var path_follow = get_parent() as PathFollow3D
        #if path_follow and path_follow.has_method("increase_speed"):
            #path_follow.increase_speed(path_follow.current_speed)
        #area.queue_free()
    #elif area.is_in_group("obstacles"):
        #take_damage(damage_amount)
        #area.queue_free()
