extends GdUnitTestSuite

# Test suite for the core game logic

func before_test():
    pass

func after_test():
    pass

func test_example():
    assert_that(true).is_true()

func test_level_generation():
    # 1. SETUP: Instantiation
    var level_generator = load("res://scripts/LevelGenerator.gd").new()
    auto_free(level_generator)
    
    # FIX A: Use the REAL Angel scene (so it has signals)
    var player_scene = load("res://scenes/Angel.tscn").instantiate()
    player_scene.add_to_group("player")
    auto_free(player_scene)

    # 2. SETUP: Tree Order (CRITICAL!)
    # FIX B: Add Player FIRST. If you add Generator first, it runs _ready()
    # immediately and fails to find the player because the player isn't there yet!
    get_tree().root.add_child(player_scene)
    get_tree().root.add_child(level_generator)

    # 3. Mocking
    var mock_chunk_scene = load("res://scenes/SpaceChunk.tscn")
    level_generator.chunk_scene = mock_chunk_scene
    level_generator.initial_chunk_count = 1
    
    # 4. Assertions (State Check)
    # Because of the correct order, _ready() has already run and found the player
    assert_that(level_generator.player).is_not_null()
    assert_that(level_generator.last_chunk_exit_nodes).is_not_empty()
    assert_that(level_generator.last_chunk_exit_nodes[0]).is_not_null()

    # 5. Action (Spawn Chunks)
    var initial_chunk_count = level_generator.spawned_chunks.size()
    level_generator.spawn_next_chunk()
    level_generator.spawn_next_chunk()
    level_generator.spawn_next_chunk()

    # 6. Verification
    assert_that(level_generator.spawned_chunks.size()).is_equal(initial_chunk_count + 3)

func test_player_orb_interaction():
    # 1. Setup
    var player_scene = load("res://scenes/Angel.tscn").instantiate()
    var orb_scene = load("res://scenes/Orb3D.tscn").instantiate()
    
    auto_free(player_scene)
    auto_free(orb_scene)
    
    get_tree().root.add_child(player_scene)
    get_tree().root.add_child(orb_scene)
    
    # 2. Set initial state
    player_scene.travel_speed = player_scene.min_travel_speed
    var initial_speed = player_scene.travel_speed
    var speed_amount = 5.0

    # 3. Action (Emit the signal)
    orb_scene.collected.emit(orb_scene, speed_amount)

    # 4. Assert (Check the Side Effect)
    # We don't need verify() here. If the speed matches, the function MUST have run.
    assert_that(player_scene.travel_speed).is_equal(initial_speed + speed_amount)
    
    # Optional: Check logic bounds
    assert_that(player_scene.travel_speed).is_less_equal(player_scene.max_travel_speed)


func test_player_ghost_interaction():
    # 1. Setup
    var player_scene = load("res://scenes/Angel.tscn").instantiate()
    var ghost_scene = load("res://scenes/Ghost.tscn").instantiate()
    
    auto_free(player_scene)
    auto_free(ghost_scene)
    
    get_tree().root.add_child(player_scene)
    get_tree().root.add_child(ghost_scene)
    
    # 2. Spy
    var player_spy = spy(player_scene)

    player_scene.travel_speed = player_scene.max_travel_speed
    var initial_speed = player_scene.travel_speed
    var speed_amount = 5.0 

    # 3. Action
    # Simulate collision
    ghost_scene._on_body_entered(player_scene)

    # 4. Verify & Assert
    verify(player_spy, 1).decrease_speed(speed_amount)
    
    assert_that(player_scene.travel_speed).is_equal(initial_speed - speed_amount)
    assert_that(player_scene.travel_speed).is_greater_equal(player_scene.min_travel_speed)
