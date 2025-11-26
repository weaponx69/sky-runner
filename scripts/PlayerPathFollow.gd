## Manages the player's movement along a predefined `Path3D`.
#
# This script controls the player's forward motion, speed, momentum, and visual tilting effects.
# The player's speed decays over time but can be increased by collecting items.
extends PathFollow3D

## The default cruising speed when no boosts are active.
@export var min_speed: float = 12.0
## The base speed of the player.
@export var base_speed: float = 5.0
## The amount speed increases when an orb is collected.
@export var speed_increase_per_orb: float = 1.0
## The rate at which the speed boost from collectibles decays over time.
@export var momentum_decay_rate: float = 0.25
## The incremental value for speed adjustments.
@export var speed_increment: float = 2.0
## The speed of lateral (side-to-side) movement.
@export var lateral_speed: float = 15.0
## The maximum distance the player can move laterally from the center of the path.
@export var max_lateral_offset: float = 5.0
## The rate at which the player's current speed approaches the target speed.
@export var acceleration: float = 2.0
## The maximum speed the player can achieve.
@export var max_speed: float = 50.0

@export_group("Visuals")
## The maximum angle the player model will tilt during movement.
@export var max_tilt_angle: float = 1.0
## The speed at which the player model tilts.
@export var tilt_speed: float = 0.0
## The friction applied to movement, slowing down lateral motion.
@export var friction: float = 5.0
## The speed at which the player model rotates.
@export var rotation_speed := 22.0
## The maximum horizontal offset for the player model.
@export var max_h_offset := 20.0
## The movement speed of the player.
@export var move_speed := 5.0
## A reference to the player's 3D model node.
@onready var angel: Node3D = $Angel

## The target horizontal offset, used for smooth lateral movement.
var target_h_offset := 0.0
## The current rotation of the player model.
var current_rotation := 0.0
## The player's current speed.
var current_speed: float
## The speed the player is trying to reach.
var target_speed: float 
## A flag to indicate if the game is paused.
var paused: bool = false

## Emitted when the player's speed changes.
signal speed_changed(new_speed: float)

## Called when the node enters the scene tree for the first time.
# Initializes the player's speed and sets the rotation mode.
func _ready():
    target_speed = min_speed
    current_speed = min_speed
    speed_changed.emit(current_speed)
    rotation_mode = PathFollow3D.ROTATION_NONE

## Called every physics frame. Handles player movement and speed decay.
# - `delta`: The time elapsed since the previous physics frame.
func _physics_process(delta):
    if paused:
        return
    
    # Speed decays back to the minimum over time
    target_speed = lerp(target_speed, min_speed, momentum_decay_rate * delta)

    # Current speed smoothly catches up to the target speed
    current_speed = lerp(current_speed, target_speed, acceleration * delta)
    speed_changed.emit(current_speed)

    # Move the player forward along the path
    progress += current_speed * delta

## Increases the player's speed by a specified amount.
# - `amount`: The amount to increase the speed by.
func increase_speed(amount: float):
    target_speed = min(target_speed + amount, max_speed)
    current_speed = clamp(current_speed + amount, min_speed, max_speed)
    print("Emitting speed_changed increased to: ", current_speed)
    speed_changed.emit(current_speed)
