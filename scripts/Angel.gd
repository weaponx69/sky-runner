## Manages the player character, an angel, including its movement within the maze.
extends CharacterBody3D

@export_group("Movement")
## The player's side-to-side movement speed.
@export var sideways_speed: float = 25.0
## The base forward speed of the player.
@export var forward_speed: float = 40.0
## The burst of forward speed gained from collecting an orb.
@export var speed_boost_amount: float = 20.0
## The rate at which the sideways velocity decreases when there is no input.
@export var sideways_friction: float = 0.1

@export_group("Visuals")
## The maximum angle the player model will bank (roll) when moving sideways.
@export var bank_angle: float = 35.0
## The speed at which the player model banks.
@export var bank_speed: float = 5.0

# Node References
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $ModelPivot

var is_game_active: bool = true

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    add_to_group("player")
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    # Set the physics properties for a flying character.
    motion_mode = MOTION_MODE_FLOATING
    up_direction = Vector3.UP

func _physics_process(delta):
    if not is_game_active:
        velocity = Vector3.ZERO
        move_and_slide()
        return

    # 1. Get Input for steering
    var input_dir = Input.get_axis("ui_left", "ui_right")

    # 2. Determine/Update Velocity
    
    # Sideways Velocity
    if input_dir != 0:
        # If there is input, accelerate towards the target sideways speed.
        velocity.x = lerp(velocity.x, input_dir * sideways_speed, 0.1)
    else:
        # If there is no input, apply friction to the sideways velocity.
        velocity.x = lerp(velocity.x, 0.0, sideways_friction)

    # Forward Velocity
    # Maintain a constant forward speed.
    velocity.z = -forward_speed

    # 3. Move the Character
    # move_and_slide() handles the collision detection and response.
    move_and_slide()
    
    # 4. Handle Visuals (Banking)
    if player_mesh:
        # Calculate target bank angle based on sideways velocity
        var target_roll = lerp(0.0, deg_to_rad(-bank_angle), clampf(velocity.x / sideways_speed, -1.0, 1.0))
        # Smoothly interpolate the mesh's roll
        player_mesh.rotation.z = lerp(player_mesh.rotation.z, target_roll, bank_speed * delta)

## Called by the LevelGenerator when an orb is collected.
func add_speed_boost():
    # Temporarily increase the forward speed.
    velocity.z -= speed_boost_amount

func _input(event):
    if is_game_active and event.is_action_pressed("ui_accept"):
        GameStateEvents.toggle_pause_requested.emit()

func _trigger_game_over():
    is_game_active = false
    velocity = Vector3.ZERO
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    GameStateEvents.game_over.emit()