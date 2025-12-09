extends GdUnitTestSuite

var player_script = load("res://scripts/Angel.gd")
var player = null
var target_orb = null

func before_test():
    # 1. Instantiate the Player
    player = player_script.new()
    add_child(player)
    
    # 2. Mock a Target Orb
    target_orb = Node3D.new()
    target_orb.name = "TargetOrb"
    add_child(target_orb)

func after_test():
    player.free()
    target_orb.free()

func test_player_moves_forward_on_rail():
    # Setup: Player at 0, Target straight ahead at -100
    player.global_position = Vector3(0, 0, 0)
    target_orb.global_position = Vector3(0, 0, -100)
    
    player.current_orb_target = target_orb
    player.is_game_active = true
    player.speed = 30.0 # Force speed
    
    # Simulate 1 frame
    player._physics_process(0.016)
    
    # ASSERT: Player Z should be less than 0 (moving forward)
    assert_float(player.global_position.z).is_less(0.0)

func test_player_converges_to_angled_path():
    # Setup: Player at 0,0,0
    player.global_position = Vector3(0, 0, 0)
    
    # Target is offset: 20 units to the RIGHT (X=20)
    target_orb.global_position = Vector3(20, 0, -100)
    player.current_orb_target = target_orb
    
    # Measure initial X distance (Gap is 20.0)
    var initial_gap = abs(player.global_position.x - target_orb.global_position.x)
    
    # Simulate 1 second of gameplay (60 frames)
    for i in range(60):
        player._physics_process(0.016)
        
    # Measure new gap
    var current_gap = abs(player.global_position.x - target_orb.global_position.x)
    
    # ASSERT 1: Player moved towards the right (> 0.0)
    assert_float(player.global_position.x).is_greater(0.0)
    
    # ASSERT 2: The gap got smaller (converging on path)
    assert_float(current_gap).is_less(initial_gap)

func test_dodge_offset_keeps_player_off_center():
    # Setup: Straight path
    player.global_position = Vector3(0, 0, 0)
    target_orb.global_position = Vector3(0, 0, -100)
    player.current_orb_target = target_orb
    
    # Apply Dodge: Player wants to be 5 units to the LEFT of the rail
    player.dodge_offset = Vector2(-5.0, 0.0)
    
    # Simulate 1 second
    for i in range(60):
        player._physics_process(0.016)
        
    # ASSERT: Player should align to -5.0 (with small tolerance for floating point errors)
    assert_float(player.global_position.x).is_between(-5.1, -4.9)
