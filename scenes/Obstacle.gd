# Obstacle Script (Attach to the Root Node of 'Rock.tscn')

extends Area3D

@export var scroll_speed: float = 30.0 
@export var speed_damage: float = 10.0 # How much momentum you lose when hitting a rock
var rotation_speed: float = 10.0

func _ready():
    # 1. Setup Collision Rules
    set_deferred("collision_layer", 2)
    set_deferred("collision_mask", 1) # Detect Player Only
    
    # 2. Connect Signal
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
        
    add_to_group("obstacles")

func _process(delta):
    # Visual rotation
    rotate_y(deg_to_rad(rotation_speed) * delta)
    rotate_x(deg_to_rad(rotation_speed * 0.5) * delta)

func _on_body_entered(body):
    if body.is_in_group("player"):
        # Instead of Game Over, we now reduce the player's momentum
        if body.has_method("decrease_speed"):
            print("Obstacle: Hit Player! Removing ", speed_damage, " speed.")
            body.decrease_speed(speed_damage)
        
        # Destroy the rock on impact so it doesn't hit twice
        queue_free()
