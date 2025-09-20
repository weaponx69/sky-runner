# res://scripts/Orb3D.gd
extends Area3D

signal collected(orb, speed_amount)  # Add speed_amount parameter

@export var speed_value: float = 5.0  # Each orb can have different speed

func _ready():
    # Ensure Area3D only detects, doesn't physically collide
    collision_layer = 2  # Put orbs on layer 2 (collectibles)
    collision_mask = 1   # Only detect player on layer 1
    
    # Add to orbs group for collision exception management
    add_to_group("orbs")
    
    # Connect the area_entered signal (detect other Area3D, e.g. Angel)
    connect("area_entered", Callable(self, "_on_area_entered"))
    
    
func _on_area_entered(area):
    if area.is_in_group("player"):
        # Notify the LevelGenerator (or any listener) that we've been collected.
        collected.emit(self, speed_value)  # Pass speed_value
