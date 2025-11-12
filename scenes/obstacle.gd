# This is the main obstacle for now
# it spawns in lanes for the player to avoid
extends StaticBody3D

enum ObstacleType{STANDARD, LOW, HIGH}
@export var CurrentObstacleType : ObstacleType = ObstacleType.STANDARD
@export var Speed : float = 10.0


# This moves the obstacle.  The player is already moving
func _process(_delta: float) -> void:
    pass
    #position.z += Speed * delta

func _ready():
    collision_layer = 1  # Obstacles on layer 1
    collision_mask = 1   # Detect player on layer 1
    add_to_group("obstacles")
    
    # Optional: Add visual feedback
    print("Obstacle rock ready for collision")
    
