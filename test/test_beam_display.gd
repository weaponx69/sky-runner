extends Node3D

var beam_instance: MeshInstance3D 

func _ready():
    # 1. Create the MeshInstance
    beam_instance = MeshInstance3D.new()
    
    # 2. Create the Cylinder
    var mesh = CylinderMesh.new()
    mesh.top_radius = 0.2
    mesh.bottom_radius = 0.2
    mesh.height = 1.0
    beam_instance.mesh = mesh

    # 3. ROTATE it to lie flat (point along Z axis)
    # Default cylinder is Y-up. Rotate -90 degrees on X to make it Z-forward.
    beam_instance.rotation_degrees.x = -90

    # 4. Create Material (Bright Red)
    var material = StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # Makes it glow purely red (no shadows)
    material.albedo_color = Color(1, 0, 0, 1) 
    beam_instance.material_override = material
    
    # 5. Add to the Scene Root (Global access)
    get_tree().root.call_deferred("add_child", beam_instance)
    
    # 6. Position it
    call_deferred("_post_add_setup")

func _post_add_setup():
    # Place it 5 units in front of the world center
    beam_instance.global_position = Vector3(0, 0, -5)
    print("Spawned RED TEST BEAM at: ", beam_instance.global_position)
