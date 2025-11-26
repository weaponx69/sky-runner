## Represents a 3D collectible orb in the game.
#
# This script is attached to an `Area3D` node that represents a 3D orb.
# When the player enters the orb's area, the orb is "collected," emitting a signal and then destroying itself.
# The orb also rotates for visual effect.
extends Area3D

## Emitted when the orb is collected by the player.
# - `orb`: A reference to this orb instance.
# - `speed_amount`: The amount of speed the player gains.
signal collected(orb, speed_amount) 

## The amount of speed the player gains when collecting this orb.
@export var speed_value: float = 5.0 
## The speed at which the orb rotates on its Y-axis, in degrees per second.
var rotation_speed: float = 90.0

## Called when the node enters the scene tree for the first time.
# Sets up the orb's group, collision layers, and signal connections.
func _ready():
    if not is_in_group("orbs"):
        add_to_group("orbs")

    # Force collision rules to ensure the orb only interacts with the player.
    # Layer 2 is for interactables/obstacles.
    set_deferred("collision_layer", 2) 
    # Mask 1 is for the player only, preventing orbs from colliding with rocks.
    set_deferred("collision_mask", 1)  

    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

## Called every frame. Rotates the orb for visual effect.
# - `delta`: The time elapsed since the previous frame.
func _process(delta):
    rotate_y(deg_to_rad(rotation_speed) * delta)

## Called when a body enters the orb's area.
# If the body is the player, it emits the `collected` signal and destroys the orb.
# - `body`: The body that entered the area.
func _on_body_entered(body):
    if body.is_in_group("player"):
        collected.emit(self, speed_value)
        queue_free()
