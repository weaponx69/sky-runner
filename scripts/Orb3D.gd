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
    # Visual spin (only if not collected)
    if visible:
        rotate_y(deg_to_rad(rotation_speed) * delta)

func _on_body_entered(body):
    if body.is_in_group("player"):
        if is_collectible:
            # 1. Mark as collected so we don't trigger twice
            is_collectible = false 
            
            # 2. Notify the Level Generator / Player
            collected.emit(self, momentum_value)
            
            # 3. FIX: Disable instead of Destroy
            # We hide the mesh and disable collision, but KEEP the node in memory.
            # This allows the Angel to read the 'neighbors' array from this node.
            visible = false
            set_deferred("monitoring", false)
            set_deferred("monitorable", false)
            
            # NOTE: The LevelGenerator will automatically delete this node
            # when the chunk goes off-screen.
 
