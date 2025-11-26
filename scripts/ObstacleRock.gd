## Represents an obstacle rock in the game.
#
# This script is attached to an `Area3D` node that represents an obstacle rock.
# It sets the collision layer and mask to detect the player and adds the obstacle to the "obstacles" group.
extends Area3D

## Called when the node is added to the scene. Sets up the collision layer and mask for the obstacle.
func _ready():
    collision_layer = 1  # Obstacles on layer 1
    collision_mask = 1   # Detect player on layer 1
    add_to_group("obstacles")

    # Optional: Add visual feedback
    print("Obstacle rock ready for collision")
