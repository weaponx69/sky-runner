# res://test/LevelGeneratorTest.gd
class_name LevelGeneratorTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/LevelGenerator.gd'
const LevelGenerator = preload("res://scripts/LevelGenerator.gd")
const SpawnableItem = preload("res://scripts/SpawnableItem.gd")

var level_generator: LevelGenerator
var path_3d: Path3D
var player_path_follow: PathFollow3D
var mock_player_scene: PackedScene
var scene_root: Node  # Store reference for cleanup

func before_test():
    # Create a mock player scene for testing
    var player_node = Node3D.new()
    player_node.name = "Player"
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "PlayerMesh"
    # Set a specific size for predictable calculations
    mesh_instance.mesh = BoxMesh.new()
    mesh_instance.mesh.size = Vector3(2, 1, 1)
    player_node.add_child(mesh_instance)

    mock_player_scene = PackedScene.new()
    mock_player_scene.pack(player_node)

    # Set up the scene tree for the test
    scene_root = auto_free(Node.new())
    var game_node = auto_free(Node3D.new()) # The parent of Path3D
    scene_root.add_child(game_node)

    path_3d = auto_free(Path3D.new())
    path_3d.name = "Path3D"
    game_node.add_child(path_3d)

    player_path_follow = auto_free(PathFollow3D.new())
    player_path_follow.name = "PlayerPathFollow"
    path_3d.add_child(player_path_follow)

    level_generator = auto_free(LevelGenerator.new())
    level_generator.name = "LevelGenerator"
    game_node.add_child(level_generator)

    # Assign the dependencies
    level_generator.player_path_follow = player_path_follow
    level_generator.player_scene = mock_player_scene

    # Add the test scene to the tree
    add_child(scene_root)
func after_test():
    # Clean up the test scene
    if scene_root and is_instance_valid(scene_root):
        scene_root.queue_free()

func test_initialization_calculates_player_width():
    assert_that(level_generator).is_not_null()
    assert_that(level_generator).is_inheriting(Node3D)

    # Trigger the _ready() function
    level_generator._ready()

    # Player width should be calculated from the mesh in mock_player_scene
    assert_float(level_generator.player_width).is_equal(2.0)

func test_generate_path_segment_adds_points_to_curve():
    level_generator._ready()

    var initial_point_count = level_generator.curve.get_point_count()

    # Ensure we have a valid curve
    assert_that(level_generator.curve).is_not_null()

    # Generate with a large enough distance to guarantee points
    level_generator.generate_path_segment(0, 200.0)

    var new_point_count = level_generator.curve.get_point_count()

    # Allow for the case where it might add exactly 1 point
    assert_int(new_point_count).is_greater_equal(initial_point_count + 1)
    assert_float(level_generator.generated_distance).is_greater(0.0)

func test_spawn_items_on_path_spawns_orbs():
    # Setup obstacle items
    var rock_item = SpawnableItem.new()
    rock_item.scene = PackedScene.new() # Mock scene
    rock_item.weight = 1.0
    level_generator.obstacle_items = [rock_item]
    level_generator.orb_spawn_chance = 1.0 # Ensure orbs always spawn

    level_generator._ready()

    # Ensure there's a path to spawn on
    level_generator.generate_path_segment(0, 100.0)

    var initial_item_count = level_generator.active_items.size()

    level_generator.spawn_items_on_path()

    var new_item_count = level_generator.active_items.size()
    assert_int(new_item_count).is_greater(initial_item_count)

    # Verify that orbs were actually spawned
    var orb_found = false
    for item in level_generator.active_items:
        if item.is_in_group("orbs"):
            orb_found = true
            break
    assert_bool(orb_found).is_true()

func test_cleanup_old_items_removes_passed_items():
    level_generator._ready()
    level_generator.generate_path_segment(0, 200.0)
    level_generator.spawn_items_on_path()

    var items_before_cleanup = level_generator.active_items.size()
    assert_int(items_before_cleanup).is_greater(0)

    # Simulate the player moving forward
    player_path_follow.progress = 150.0

    level_generator.cleanup_old_items(player_path_follow.progress - 100.0)

    var items_after_cleanup = level_generator.active_items.size()
    assert_int(items_after_cleanup).is_less(items_before_cleanup)

func test_orb_pooling_recycles_orbs():
    level_generator.orb_scene = preload("res://scenes/Orb3D.tscn")
    level_generator._ready()

    # Get a new orb from the pool
    var orb1 = level_generator.get_orb_from_pool()
    assert_that(orb1).is_not_null()

    # "Collect" the orb to recycle it
    level_generator._recycle_orb(orb1)

    # The pool should now have one orb
    assert_int(level_generator.orb_pool.size()).is_equal(1)

    # Get another orb, which should be the recycled one
    var orb2 = level_generator.get_orb_from_pool()
    assert_that(orb2).is_equal(orb1)
    assert_int(level_generator.orb_pool.size()).is_equal(0)
