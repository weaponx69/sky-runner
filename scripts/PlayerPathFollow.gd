# res://scripts/PlayerPathFollow.gd
# Edit file: res://scripts/PlayerPathFollow.gd
extends PathFollow3D

@export_group("Movement")
@export var initial_speed = 15.0 # The speed the player starts with. (increased for a stronger initial push)
@export var max_speed = 25.0 # The maximum speed the player can reach.
@export var boost_amount = 5.0 # Speed gained per orb.
@export var friction = 0.8 # How quickly speed wears off. Higher is faster. (reduced to preserve initial boost)

var current_speed: float = 0.0
var speed_boost: float = 0.0
var speed_penalty: float = 0.0

func _ready():
    # Give the player an initial burst of speed. This only happens once.
    speed_boost = initial_speed
func _physics_process(delta):
    # Calculate the final speed including boosts and penalties
    var final_speed = speed_boost * (1.0 - speed_penalty)
    # Smoothly interpolate current_speed toward final_speed
    current_speed = lerp(current_speed, final_speed, delta * 5.0) # snappier acceleration

    # Move based on the current speed.
    progress += current_speed * delta

    # Gradually recover from penalties and boosts
    speed_boost = lerp(speed_boost, 0.0, delta * friction)
    speed_penalty = lerp(speed_penalty, 0.0, delta * 1.0)

func add_speed_boost():
    # Add to the boost pool rather than directly setting current_speed.
    speed_boost += boost_amount
    # Clamp the speed_boost so it cannot exceed the configured max_speed.
    speed_boost = clamp(speed_boost, 0.0, max_speed)
# This function will be called by obstacle (e.g., Rock) signals to apply a slowdown
func _on_obstacle_collision(_obstacle, penalty_amount: float):
    print("Player script received slowdown signal! Penalty: ", penalty_amount) # Debug print
    # Add the penalty. Cap the maximum slowdown at 90% to avoid stopping completely.
    speed_penalty = min(speed_penalty + penalty_amount, 0.9)
