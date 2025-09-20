# res://scripts/Rock.gd
# Edit file: res://scripts/Rock.gd
extends Area3D

func _ready():
    add_to_group("obstacles")
    
    # Set collision layers for obstacle detection
    collision_layer = 1  # Obstacles on layer 1
    collision_mask = 1   # Detect player on layer 1
    
    # Ensure monitoring is enabled
    monitoring = true
    monitorable = true
    
    # Debug: Print collision setup
    print("Rock spawned - Layer: ", collision_layer, " Mask: ", collision_mask)
    print("Rock in obstacles group: ", is_in_group("obstacles"))
    
    # Connect collision signal only if not already connected
    if not area_entered.is_connected(Callable(self, "_on_area_entered")):
        area_entered.connect(_on_area_entered)
    
    # Material setup
    var mesh_node = get_node_or_null("RockMesh")
    if mesh_node:
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.5, 0.5, 0.5)
        material.roughness = 1.0
        mesh_node.material_override = material


func _on_area_entered(area):
    print("Rock collision detected with: ", area.name, " Groups: ", area.get_groups())
