# Orb Collectible Script
# FIX: Forces collision mask to 1 (Player Only) to prevent physics spam.

extends Area3D

signal collected(orb, speed_amount) 

@export var speed_value: float = 5.0 
var rotation_speed: float = 90.0

func _ready():
    if not is_in_group("orbs"):
        add_to_group("orbs")

    # FORCE Collision Rules (Using set_deferred to bypass Inspector locks)
    # Layer 2 = Interactables/Obstacles
    set_deferred("collision_layer", 2) 
    # Mask 1 = Player Only (Ignore Layer 2 to stop Orbs hitting Rocks)
    set_deferred("collision_mask", 1)  

    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

func _process(delta):
    rotate_y(deg_to_rad(rotation_speed) * delta)

func _on_body_entered(body):
    if body.is_in_group("player"):
        collected.emit(self, speed_value)
        queue_free()
