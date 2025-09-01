# res://scripts/PlayerPathFollow.gd
# Edit file: res://scripts/PlayerPathFollow.gd
extends PathFollow3D

@export_group("Movement")
@export var base_speed = 5.0
@export var boost_amount = 12.0
@export var friction = 1.0 # How quickly the boost wears off. Higher is faster.

var current_speed: float

func _ready():
    # At start, current speed equals base speed.
    current_speed = base_speed

func _physics_process(delta):
    # Move based on the current speed.
    progress += current_speed * delta

    # If boosted above base, smoothly decay back toward base speed.
    if current_speed > base_speed:
        current_speed = lerp(current_speed, base_speed, friction * delta)

func add_speed_boost():
    # Boost only affects the temporary current_speed.
    current_speed += boost_amount
    print("Speed boosted! New speed: ", current_speed)
