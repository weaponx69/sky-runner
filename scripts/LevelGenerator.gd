# res://scripts/LevelGenerator.gd
extends Node3D

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

    create_large_circular_path()
    spawn_orbs_along_path()
    spawn_rocks_along_path()
    
    # Debug: Add a visible marker at origin for reference
    #add_debug_marker()

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
        
        # NOW that it's in the tree, we can safely set its global position.
        orb.global_position = path_position + Vector3(0, orb_y_position, 0)
        orb.set_meta("path_progress", progress)

func spawn_rocks_along_path():
    #print("Spawning rocks…")
    var path_3d = get_node("../Path3D")
    if not path_3d or not path_3d.curve:
        return

    var path_length = path_3d.curve.get_baked_length()
    if path_length == 0: return

    for i in range(rock_count):
        var progress = (float(i) / float(rock_count)) * path_length

        # Get position on path
        var path_position = path_3d.curve.sample_baked(progress)
        var path_direction = path_3d.curve.sample_baked_with_rotation(progress).basis.z

        # Calculate perpendicular directions for offset
        var up_vector = Vector3.UP
        var right_vector = path_direction.cross(up_vector).normalized()
        var _forward_vector = path_direction
        
        # Calculate the base position on the XZ plane
        var side_offset = randf_range(-rock_side_variance, rock_side_variance)
        var rock_position = path_position + (right_vector * side_offset)
        # Set the fixed Y position
        rock_position.y = rock_y_position
        
        # Position rock with variation
        var height = randf_range(rock_height_range.x, rock_height_range.y)
        side_offset = randf_range(-rock_side_variance, rock_side_variance)
        
        
        #var rock_position = path_position + (right_vector * side_offset) + (up_vector * height)
        rock_position.y = rock_y_position

        # Create rock
        var rock = rock_scene.instantiate()
        add_child(rock)
        
        rock.global_position = rock_position
        rock.rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))
       
        var scale_factor = randf_range(0.6, 1.4)
        rock.scale = Vector3.ONE * scale_factor
        
