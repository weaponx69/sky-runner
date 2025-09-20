# res://scripts/LevelGenerator.gd
extends Node3D

@onready var player_path_follow: PathFollow3D

@export var path_radius: float = 2000.0
@export var orb_count: int = 205
@export var rock_count: int = 150
@export var orb_y_position: float = 1.0  # New property for fixed orb height
@export var rock_height_range: Vector2 = Vector2(-10.0, 30.0)
@export var rock_y_position: float = 1.0  # New property for fixed rock height
@export var rock_side_variance: float = 50.0
@export var spawn_distance: float = 100.0

var orb_scene: PackedScene
var rock_scene: PackedScene

func _ready():
    randomize()
    orb_scene = preload("res://scenes/Orb3D.tscn")
    rock_scene = preload("res://scenes/Rock.tscn")

    player_path_follow = get_node("../Path3D/PlayerPathFollow")
    
    create_large_circular_path()
    spawn_orbs_along_path()
    spawn_rocks_along_path()


func create_large_circular_path():
    var curve = Curve3D.new()
    var segments = 100
    for i in range(segments + 1):
        var angle = (i * 2.0 * PI) / segments
        var x = cos(angle) * path_radius
        var z = sin(angle) * path_radius
        curve.add_point(Vector3(x, 0, z))
    curve.set_point_position(0, curve.get_point_position(segments))

    var path_3d = get_node("../Path3D")
    if path_3d:
        path_3d.curve = curve
        print("Created circular path with length: ", curve.get_baked_length())

func spawn_orbs_along_path():
    print("Spawning orbs…")
    var path_3d = get_node("../Path3D")
    if not path_3d or not path_3d.curve:
        return
    
    var path_length = path_3d.curve.get_baked_length()
    if path_length == 0: return
    
    for i in range(orb_count):
        # Spread orbs evenly across the entire path
        var progress = (float(i) / float(orb_count)) * path_length
        var path_position = path_3d.curve.sample_baked(progress)
        var orb = orb_scene.instantiate()
        
        add_child(orb)
        
        orb.global_position = path_position + Vector3(0, orb_y_position, 0)
        orb.set_meta("path_progress", progress)
        orb.collected.connect(_on_orb_collected)

        orb.global_position = path_position + Vector3(0, orb_y_position, 0)
        orb.set_meta("path_progress", progress)
        
        
func spawn_rocks_along_path():
    var path_3d = get_node("../Path3D")
    if not path_3d or not path_3d.curve:
        return

    var path_length = path_3d.curve.get_baked_length()
    if path_length == 0: return
    
    # Create noise for random positioning
    var noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.frequency = 0.5

    for i in range(rock_count):
        # Use noise for random progress along path
        var noise_val = noise.get_noise_1d(i * 0.1)
        var progress = randf_range(0, path_length)
        
        # Get position on path
        var path_position = path_3d.curve.sample_baked(progress)
        var tangent = path_3d.curve.sample_baked_with_rotation(progress).basis.z
        
        # Use noise for random perpendicular offset
        var perp_noise = noise.get_noise_2d(i * 0.1, 0)
        var side_offset = perp_noise * 300.0  # 300 unit spread
        
        # Calculate perpendicular direction for random offset
        var perpendicular = Vector3(-tangent.z, 0, tangent.x).normalized()
        
        # Final position with noise-based offset
        var final_position = path_position + (perpendicular * side_offset)
        
        var orb = orb_scene.instantiate()
        add_child(orb)
        orb.global_position = final_position + Vector3(0, orb_y_position, 0)
        orb.collected.connect(_on_orb_collected)
 
        
# Add this method to LevelGenerator:
func _on_orb_collected(_orb, speed_amount):
    if player_path_follow:
        player_path_follow.increase_speed(speed_amount)
