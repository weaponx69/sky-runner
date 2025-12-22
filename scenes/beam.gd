extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

func set_color(color: Color):
    var new_material = StandardMaterial3D.new()
    new_material.albedo_color = color
    new_material.emission_enabled = true
    new_material.emission = color
    mesh.material_override = new_material

# This function is for a persistent beam that shows a path
func show_path(start_point: Vector3, end_point: Vector3):
    global_position = start_point
    look_at(end_point)
    var distance = start_point.distance_to(end_point)
    scale.z = distance

# This function is for a one-shot laser-like effect
func draw(start_point: Vector3, end_point: Vector3):
    # 1. Place the beam at the muzzle
    global_position = start_point
    
    # 2. Aim the beam at the collision point
    # Godot's look_at points the -Z axis (Forward) at the target.
    # Since we set up our mesh to grow along -Z, this lines up perfectly.
    look_at(end_point)
    
    # 3. Stretch the beam to fit the distance
    var distance = start_point.distance_to(end_point)
    scale.z = distance
    
    # 4. (Optional) Make it disappear after a split second
    # Create a tween to fade it out or shrink it
    var tween = create_tween()
    tween.tween_property(self, "scale:z", 0.0, 0.1) # Shrink to 0 over 0.1 seconds
    await tween.finished
    queue_free()
