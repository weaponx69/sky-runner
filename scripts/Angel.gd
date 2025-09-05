# res://scripts/Angel.gd
# Edit file: res://scripts/Angel.gd
# Simplified version that just follows the PathFollow3D
extends Area3D
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_arm = $SpringArm3D
@onready var player_mesh = $PlayerMesh

func _ready():
    # Make sure this camera is the active one
    camera.make_current()
    # Reset the mesh rotation and try different angles
    player_mesh.rotation_degrees = Vector3(0, 0, 0)  # Reset first
    # Try rotating the mesh to face the path direction; side bar suggests 90 degrees off
    player_mesh.rotation_degrees = Vector3(0, -90, 0)
    print("PlayerMesh rotation set to -90 degrees")
    print("PlayerMesh forward now: ", -player_mesh.global_transform.basis.z)
    
    # Reset everything to default relative positioning
    spring_arm.position = Vector3(0, 2, 0)  # Spring arm 2 units above angel
    spring_arm.rotation = Vector3(0, 0, 0)  # No rotation
    
    # Position camera far back using spring arm length
    # SpringArm3D will automatically handle the positioning
    camera.position = Vector3(0, 0, -30)  # 30 units back in local space
    
    # Ensure camera looks forward (along -Z)
    camera.rotation = Vector3(0, 0, 0)
    
    print("Camera active: ", camera.is_current())
    print("SpringArm position: ", spring_arm.global_position)
    print("Camera position: ", camera.global_position)
    print("Angel position: ", global_position)
    
    # Create a simple colored cube to show forward direction
    var cube = MeshInstance3D.new()
    var box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(0.5, 0.5, 2.0)  # Long box pointing forward
    cube.mesh = box_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED
    # Override the material on the mesh instance
    cube.set_surface_override_material(0, material)
    
    # Position it in front of the angel
    cube.position = Vector3(0, 0, 2)
    add_child(cube)
    
    print("Angel is facing: ", -global_transform.basis.z)
    print("Angel rotation: ", rotation_degrees)
func _physics_process(_delta):
    # Just sync position with parent PathFollow3D
    var path_follow = get_parent()
    if path_follow:
        global_position = path_follow.global_position

func _process(_delta):
    print("Angel position: ", global_position)
    print("Angel forward: ", -global_transform.basis.z)
