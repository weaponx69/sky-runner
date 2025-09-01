# res://scripts/PlayerPathFollow.gd
# Edit file: res://scripts/PlayerPathFollow.gd
extends PathFollow3D

@export var speed = 5.0

func _physics_process(delta):
    # This line increases the node's progress along the path, creating forward movement.
    progress += speed * delta

@export var boost_amount = 2.0

func add_speed_boost():
    speed += boost_amount
    print("Speed boosted! New speed: ", speed)
