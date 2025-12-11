extends GdUnitTestSuite

const AngelScript = preload("res://scripts/Angel.gd")
const LevelGeneratorScript = preload("res://scripts/LevelGenerator.gd")

var player: CharacterBody3D
var level_generator: Node3D

# Set up the test environment before each test function
func before_test():
    # Instantiate the scripts
    player = AngelScript.new()
    player.name = "Player"
    level_generator = LevelGeneratorScript.new()
    level_generator.name = "LevelGenerator"
    
    # The LevelGenerator needs a reference to the player to function
    level_generator.player_node = player

    # Add them to the scene tree so they can interact with it (e.g., get_tree(), signals)
    add_child(level_generator)
    add_child(player)
    
    # Manually call _ready() to ensure signals are connected, including our new one
    level_generator._ready()

# Clean up after each test
func after_test():
    player.free()
    level_generator.free()

# --- TEST SUITE ---

func test_game_over_signal_flow():
    # VERIFY: We are using the global event bus, so it must exist.
    assert_that(GameStateEvents).is_not_null()

    # --- ARRANGE ---
    # Set the initial "playing" state for both nodes
    player.speed = 10.0
    player.min_speed_threshold = 5.0
    player.is_game_active = true
    level_generator.is_game_running = true
    get_tree().paused = false # Ensure the game is not paused initially

    # --- ACT ---
    # This action should cause player speed to drop to 0 and trigger the game_over signal
    player.decrease_speed(10.0) 
    
    # The player emits the signal, so we wait for the global bus to fire it.
    # This confirms the first half of the logic (the signal emission).
    await GameStateEvents.game_over
    
    # --- ASSERT ---
    # Re-evaluating assertions to ensure the engine picks up the latest script version.
    # Now, verify that the LevelGenerator reacted to the signal correctly.
    # This confirms the second half of the logic (the signal handling).
    assert_that(level_generator.is_game_running).is_false("LevelGenerator should no longer be running.")
    assert_that(get_tree().paused).is_true("The game tree should be paused after game over.")
