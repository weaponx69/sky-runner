# Ghost Script (Path Node Hazard)
# INHERITANCE: Inherits PathNode for rail connectivity.
# BEHAVIOR: Deals damage (momentum loss) if the player collides with it.

extends "res://scripts/PathNode.gd"

@export var speed_damage: float = 20.0 
var rotation_speed: float = 2.0

func _ready():
    # Set properties inherited from PathNode
    is_collectible = false
    momentum_value = -speed_damage # Hazards remove speed
    
    # 1. Setup Collision (Area3D setup)
    set_deferred("collision_layer", 2)
    set_deferred("collision_mask", 1) # Detect Player Only
    
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
        
    add_to_group("obstacles")
    add_to_group("ghosts")    

func _process(delta):
    # Basic visual rotation to make it look like it's floating/spinning
    rotation.y += rotation_speed * delta 

func _on_body_entered(body):
    if body.is_in_group("player"):
        if body.has_method("decrease_speed"):
            print("Ghost: Collision! Removing momentum.")
            body.decrease_speed(speed_damage)
        
        # Remove the ghost from the scene after impact
        queue_free()
