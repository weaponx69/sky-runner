# Ghost Script
# BEHAVIOR: Sits on the "Orb Rail" and damages momentum significantly if hit.
# FUTURE: You could add logic here to make them wobble or chase slightly.

extends Area3D

@export var speed_damage: float = 20.0 # Ghosts hurt more than rocks!
var hover_speed: float = 2.0
var time_offset: float = 0.0


func _ready():
    # 1. Setup Collision (Same as Rocks)
    set_deferred("collision_layer", 2)
    set_deferred("collision_mask", 1) # Player Only
    
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
        
    add_to_group("obstacles") # Treat as obstacle for Game Over logic
    add_to_group("ghosts")    # Unique group for potential AI
    
    time_offset = randf() * 10.0

func _process(delta):
    # Visual: Bob up and down slightly like a ghost
    var _bob = sin(Time.get_ticks_msec() * 0.005 + time_offset) * 0.5
    # Note: adjusting position.y directly might conflict if we added physics, 
    # but for an Area3D it's fine visual juice.
    
    # Look at player (approximate, since player is at 0,0,0 locally relative to chunk movement)
    # Or just face forward.
    rotation.y += 2.0 * delta # Spin slowly

func _on_body_entered(body):
    if body.is_in_group("player"):
        if body.has_method("decrease_speed"):
            print("Ghost: Hit Player! momentum drained.")
            body.decrease_speed(speed_damage)
        
        queue_free()
