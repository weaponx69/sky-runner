# res://tests/TestSpaceChunkSpawner.gd
extends GdUnitTestSuite
# NOTE: The path to the GDUnit Assertion Utility is environment dependent. 
# This path is the standard location for GDUnit4 installations.
const ASSERTION_UTIL_PATH = "res://addons/gdunit4/api/asserts.gd"

# Replace this with the actual path to your SpaceChunkSpawner.gd script if different
const SPACE_CHUNK_SPAWNER_SCRIPT_PATH = "res://scripts/SpaceChunkSpawner.gd"
const ITERATIONS = 1000  # Number of times to simulate spawning objects for statistical accuracy
const EXPECTED_SURVIVAL_RATE = 0.05 # Expected survival rate (1.0 - 0.95 deletion chance)
const TOLERANCE = 0.01   # Tolerance for statistical fluctuation (e.g., +/- 1%)

# Load the script resource once
var ChunkSpawnerScript = load(SPACE_CHUNK_SPAWNER_SCRIPT_PATH)
const MOCK_ORB_SCENE = preload("res://scenes/Orb3D.tscn") 

# Load the Assertion Utility Script
var Asserts = load(ASSERTION_UTIL_PATH)

# Instantiate the script instance globally
var ChunkSpawner = null

# --- GDUnit Setup Hook ---
func before_all():
    # Check if the Assertion Utility loaded correctly before proceeding
    if not is_instance_valid(Asserts):
        push_error("GDUnit Assertions Utility failed to load at: " + ASSERTION_UTIL_PATH)
        return
        
    ChunkSpawner = ChunkSpawnerScript.new()
    randomize() 


# --- Test 1: Verifies the Statistical Sparseness (95% Deletion) ---
func test_density_survival_rate():
    # Arrange
    var requested_count = ITERATIONS
    var deleted_count = 0
    var survived_count = 0
    
    var deletion_prob = ChunkSpawner.content_free_zone_reduction
    
    # Act: Simulate running the density check ITERATIONS times
    for i in range(requested_count):
        if randf() < deletion_prob:
            deleted_count += 1
        else:
            survived_count += 1
            
    # Assert
    var actual_survival_rate = float(survived_count) / float(requested_count)
    
    var lower_bound = EXPECTED_SURVIVAL_RATE - TOLERANCE
    var upper_bound = EXPECTED_SURVIVAL_RATE + TOLERANCE
    
    # FIX: Use the manually loaded Asserts resource to call assert_true
    var is_within_range = (actual_survival_rate >= lower_bound) and (actual_survival_rate <= upper_bound)
    
    Asserts.assert_true(is_within_range) \
        .with_message("Survival rate should be between %s and %s. Actual survival: %s" % [lower_bound, upper_bound, actual_survival_rate])


# --- Test 2: Verifies Uniform Z-Axis Placement (No Clumping) ---
func test_uniform_z_placement():
    # Arrange
    var spawner = ChunkSpawner 
    spawner.spawn_volume_z = 200.0 
    
    # Act: Simulate spawning a single object 100 times and record its Z position
    var z_positions = []
    
    for i in range(100):
        var end_z_range = spawner.spawn_volume_z
        var rand_z = randf_range(-end_z_range, 0.0)
        
        z_positions.append(rand_z)
        
    # Assert: Check that the average Z position is near the middle, proving uniformity.
    var average_z = 0.0
    for z in z_positions:
        average_z += z
    average_z /= float(z_positions.size())
    
    var expected_average = -100.0
    var average_tolerance = 10.0
    var lower_bound = expected_average - average_tolerance
    var upper_bound = expected_average + average_tolerance
    
    # FIX: Use the manually loaded Asserts resource to call assert_true
    var is_within_range = (average_z >= lower_bound) and (average_z <= upper_bound)
    
    Asserts.assert_true(is_within_range) \
        .with_message("Average Z position should be near the center (%s). Actual average: %s" % [expected_average, average_z])
