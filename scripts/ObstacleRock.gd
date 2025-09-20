extends Area3D

func _ready():
    collision_layer = 1  # Obstacles on layer 1
    collision_mask = 1   # Detect player on layer 1
    add_to_group("obstacles")
    
    # Optional: Add visual feedback
    print("Obstacle rock ready for collision")