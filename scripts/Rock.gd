# res://scripts/Rock.gd
extends Area3D

# Define a signal that sends the obstacle and penalty amount
signal obstacle_collision(obstacle, penalty_amount)

# Penalty value, configurable per-rock in the Inspector.
@export var slowdown_penalty: float = 1000

# This is only called once when this is called.
func _ready():
    # --- THIS IS THE FIX ---
    # Only connect the signal if it's not already connected.
    # This prevents the "already connected" error.
    if not area_entered.is_connected(_on_area_entered):
        area_entered.connect(_on_area_entered)

# This function is called automatically when another Area3D enters this one.
func _on_area_entered(area):
    # We check if the area that entered is the player by checking its group.
    if area.is_in_group("player"):
        print("Rock collided with player!") # Debug print
        # Emit our custom signal, sending this rock and the configured penalty.
        obstacle_collision.emit(self, slowdown_penalty)
        # Optional: Make the rock disappear after collision.
        queue_free()
