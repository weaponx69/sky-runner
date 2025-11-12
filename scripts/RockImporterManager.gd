extends Node

@export var rock_folder_path: String = "res://assets/rocks/"
@export var spawn_distance: float = 50.0
@export var spawn_height: float = 0.0
@export var spawn_width: float = 10.0
@export var rock_scale: Vector3 = Vector3(1, 1, 1)

var rock_models: Array = []
var rng = RandomNumberGenerator.new()

func _ready():
    rng.randomize()
    load_rock_models()

func load_rock_models():
    # Clear existing models
    rock_models.clear()
    
    # Import GLB files from the rocks folder
    var dir = DirAccess.open(rock_folder_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
                var full_path = rock_folder_path + file_name
                var model = load(full_path)
                if model:
                    rock_models.append(model)
                    print("Loaded rock model: " + file_name)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    else:
        push_warning("Could not open rock folder: " + rock_folder_path)
    
    # If no GLB models found, fall back to existing scenes
    if rock_models.is_empty():
        push_warning("No GLB models found, using fallback scenes")
        rock_models = [
            preload("res://scenes/Rock.tscn"),
            preload("res://scenes/ObstacleRock.tscn")
        ]

func spawn_random_rock(position: Vector3 = Vector3.ZERO) -> Node3D:
    if rock_models.is_empty():
        push_error("No rock models available!")
        return null
    
    var random_model = rock_models.pick_random()
    var rock_instance = random_model.instantiate()
    
    # Set position and add some randomness
    rock_instance.position = position
    
    # Add random rotation and scale variation
    rock_instance.rotation_degrees = Vector3(
        rng.randf_range(-15, 15),
        rng.randf_range(0, 360),
        rng.randf_range(-15, 15)
    )
    
    var scale_variation = rng.randf_range(0.8, 1.3)
    rock_instance.scale = rock_scale * scale_variation
    
    add_child(rock_instance)
    return rock_instance

func spawn_rock_along_path(distance: float, lane: int = 0) -> Node3D:
    # Spawn rocks along the player's path with lane positioning
    var lane_width = 3.0
    var x_pos = lane * lane_width + rng.randf_range(-1.0, 1.0)
    var z_pos = -distance  # Negative because player moves forward
    
    # Add some height variation
    var y_pos = rng.randf_range(-0.5, 0.5)
    
    return spawn_random_rock(Vector3(x_pos, y_pos, z_pos))

func spawn_rock_cluster(center_pos: Vector3, count: int = 3) -> Array:
    # Spawn a cluster of rocks around a center position
    var rocks = []
    
    for i in range(count):
        var offset = Vector3(
            rng.randf_range(-2, 2),
            0,
            rng.randf_range(-2, 2)
        )
        var rock = spawn_random_rock(center_pos + offset)
        if rock:
            rocks.append(rock)
    
    return rocks
