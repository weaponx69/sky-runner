## Represents a rock obstacle in the game.
#
# This script is attached to an `Area3D` node that represents a rock.
# It sets up the rock's collision properties so it can be detected by the player
# and applies a default material to the rock's mesh.
extends Area3D

## Called when the node enters the scene tree for the first time.
# Initializes the rock's group, collision layers, monitoring settings, and material.
func _ready():
    add_to_group("obstacles")
    
    # Set collision layers for obstacle detection.
    # Rocks are on layer 1 and can only detect the player, who is also on layer 1.
    collision_layer = 1
    collision_mask = 1
    
    # Ensure monitoring is enabled to detect collisions.
    monitoring = true
    monitorable = true
    
    # Debugging output to confirm collision setup.
    print("Rock spawned - Layer: ", collision_layer, " Mask: ", collision_mask)
    print("Rock in obstacles group: ", is_in_group("obstacles"))
    
    # Connect the collision signal if it's not already connected.
    if not area_entered.is_connected(Callable(self, "_on_area_entered")):
        area_entered.connect(_on_area_entered)
    
    # Apply a default material to the rock's mesh.
    var mesh_node = get_node_or_null("RockMesh")
    if mesh_node:
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.5, 0.5, 0.5)
        material.roughness = 1.0
        mesh_node.material_override = material

## Called when another area enters this rock's area.
# Prints a debug message to indicate a collision has been detected.
# - `area`: The area that entered this rock's area.
func _on_area_entered(area):
    print("Rock collision detected with: ", area.name, " Groups: ", area.get_groups())
