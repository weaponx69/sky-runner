extends PathFollow3D

@export_group("Movement")
@export var initial_speed = 35.0 # The speed the player starts with.
@export var max_speed = 45.0 # The maximum speed the player can reach.
@export var boost_amount = 15.0 # Speed gained per orb.
@export var friction = 5.0 # How quickly speed wears off. Higher is faster.
@export var raycast: RayCast3D # <-- Drag your RayCast3D node here in the Inspector!

var current_speed: float = 0.0
var speed_boost: float = 0.0
var speed_penalty: float = 0.0

func _ready():
    # Give the player an initial burst of speed.
    speed_boost = initial_speed
    
    if not raycast:
        push_error("RayCast3D node not assigned! Forward movement will not be collision-aware.")

func _physics_process(delta):
    # Check if the raycast is hitting an obstacle.
    if raycast and raycast.is_colliding():
        # Stop forward movement if an obstacle is detected.
        # This prevents the player from fighting with the physics engine.
        current_speed = 0.0
    else:
        # Calculate the final speed including boosts and penalties
        var final_speed = speed_boost * (1.0 - speed_penalty)
        # Smoothly interpolate current_speed toward final_speed
        current_speed = lerp(current_speed, final_speed, delta * 5.0)

    # Move based on the current speed.
    progress += current_speed * delta

    # Gradually recover from penalties and boosts
    speed_boost = lerp(speed_boost, 0.0, delta * friction)
    speed_penalty = lerp(speed_penalty, 0.0, delta * 1.0)

# This function is called by the obstacle's signal to apply a slowdown
func apply_penalty(penalty_amount: float):
    print("Player script received slowdown signal! Penalty: ", penalty_amount) # Debug print
    # Add the penalty. Cap the maximum slowdown at 90% to avoid stopping completely.
    speed_penalty = min(speed_penalty + penalty_amount, 0.9)
    
func add_speed_boost():
    # Add to the boost pool rather than directly setting current_speed.
    speed_boost += boost_amount
    # Clamp the speed_boost so it cannot exceed the configured max_speed.
    speed_boost = clamp(speed_boost, 0.0, max_speed)
