# Orb Collectible Script
# INHERITANCE: Inherits PathNode for rail connectivity.

extends "res://scripts/PathNode.gd" 

# Signals
signal collected(orb, speed_amount) 

# Base Orb setup
var rotation_speed: float = 90.0

func _ready():
    # Set base properties defined in PathNode
    is_collectible = true
    momentum_value = 10.0 # Orbs give 10 speed
    
    # 1. Setup Collision (Essential: Area3D setup)
    set_deferred("collision_layer", 2)
    set_deferred("collision_mask", 1) # Detect Player Only

    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

    add_to_group("orbs") 

func _process(delta):
    # Visual spin
    rotate_y(deg_to_rad(rotation_speed) * delta)

func _on_body_entered(body):
    if body.is_in_group("player"):
        if is_collectible:
            # Notify the Level Generator (or player)
            collected.emit(self, momentum_value)
        
        # When collected/touched, the Angel script handles switching to the next node.
        queue_free()
        
