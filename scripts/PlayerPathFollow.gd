# res://scripts/PlayerPathFollow.gd
extends PathFollow3D

# Renamed 'base_speed' to 'min_speed' for clarity. This is your default cruising speed.
@export var min_speed: float = 12.0

@export var base_speed: float = 5.0
@export var speed_increase_per_orb: float = 1.0

# This is the new variable that controls how fast your speed boost decays.
@export var momentum_decay_rate: float = 0.25
@export var speed_increment: float = 2.0
@export var lateral_speed: float = 15.0
@export var max_lateral_offset: float = 5.0
@export var acceleration: float = 2.0
@export var max_speed: float = 50.0

# New variables for the tilting effect
@export_group("Visuals")
@export var max_tilt_angle: float = 1.0
@export var tilt_speed: float =0.0
@export var friction: float = 5.0
@export var rotation_speed := 22.0
@export var max_h_offset := 20.0
@export var move_speed := 5.0
@onready var angel: Node3D = $Angel

var target_h_offset := 0.0
var current_rotation := 0.0
var current_speed: float
var target_speed: float 
var paused: bool = false

signal speed_changed(new_speed: float)

func _ready():
        # At the start, all speeds are set to the minimum.
    target_speed = min_speed
    current_speed = min_speed
    speed_changed.emit(current_speed)
    rotation_mode = PathFollow3D.ROTATION_NONE


func _physics_process(delta):
    if paused:
        return
    
    if not paused:
        target_speed = lerp(target_speed, min_speed, momentum_decay_rate * delta)

        # The current speed will smoothly follow the target speed
        current_speed = lerp(current_speed, target_speed, acceleration * delta)
        speed_changed.emit(current_speed)
        
        # This part remains the same, moving you forward.
        progress += current_speed * delta


func increase_speed(amount: float):
    # Boost both target and current speed
    target_speed = min(target_speed + amount, max_speed)
    current_speed = clamp(current_speed + amount, min_speed, max_speed)
    print("Emitting speed_changed increased to: ", current_speed)
    speed_changed.emit(current_speed)
