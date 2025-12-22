extends MeshInstance3D

func _ready():
    # Ensure the material is emissive and bright if not already set in the scene file
    if not material_override:
        var material = StandardMaterial3D.new()
        material.emission_enabled = true
        material.emission = Color(1, 0, 0, 1) # Bright Red
        material.albedo_color = Color(1, 0, 0, 1)
        material.metallic_specular = 0.0
        material.roughness = 1.0
        material_override = material
