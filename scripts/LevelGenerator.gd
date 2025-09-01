# res://scripts/LevelGenerator.gd
# Edit file: res://scripts/LevelGenerator.gd
extends Node3D

@export var player_path_follow: PathFollow3D

@export_group("Player Spacing")
# Drag your Angel.tscn file here in the Inspector
@export var player_scene: PackedScene
@export var safety_margin: float = 1.0

@export_group("Path Generation")
@export var generation_ahead_distance: float = 200.0
@export var segment_length: float = 5.0
@export var curve_amplitude: float = 10.0

@export_group("Item Spawning")
@export var item_spacing: float = 15.0

# Internal runtime helpers
var rng = RandomNumberGenerator.new()
var noise = FastNoiseLite.new()
@export_group("Spawnables")
## Drag your 'rock_item.tres' and other obstacle resources here.
@export var obstacle_items: Array[SpawnableItem]
@export var orb_scene: PackedScene = preload("res://scenes/Orb3D.tscn")
@export var orb_spawn_chance: float = 0.7
@export var orb_circle_radius_min: float = 2.0
@export var orb_circle_radius_max: float = 5.0

var path3d: Path3D
var curve: Curve3D

var generated_distance: float = 0.0
# This will now track ALL spawned items, not just orbs.
var active_items: Array = []
var orb_pool: Array = []
var last_spawn_distance: float = 0.0

# We'll store the calculated player width here (fallback default)
var player_width: float = 2.0

func _ready():
    # Configure the noise for generating obstacle patterns
    rng.randomize()
    noise.seed = rng.randi()
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = 0.02

    # Calculate player width automatically from the provided player scene (if set)
    if player_scene:
        var player_instance = player_scene.instantiate()
        # Try to find a named mesh node first, then fall back to the first MeshInstance3D child
        var mesh_instance = player_instance.get_node_or_null("PlayerMesh")
        if not mesh_instance:
            for c in player_instance.get_children():
                if c is MeshInstance3D:
                    mesh_instance = c
                    break
        if mesh_instance and mesh_instance is MeshInstance3D:
            var aabb_size = mesh_instance.get_aabb().size
            # Assume width is along the X axis
            player_width = aabb_size.x
            print("Calculated player width:", player_width)
        else:
            push_warning("Could not find 'PlayerMesh' in the player scene to calculate width.")
        player_instance.queue_free()
    else:
        push_warning("Player Scene is not set in the LevelGenerator. Cannot calculate width for spacing.")

    path3d = get_parent().get_node("Path3D")
    if not path3d:
        push_error("LevelGenerator Error: Path3D node not found!")
        set_process(false)
        return

    if not player_path_follow:
        push_error("LevelGenerator Error: 'Player Path Follow' node has not been assigned in the Inspector!")
        set_process(false)
        return

    if not path3d.curve:
        path3d.curve = Curve3D.new()
    curve = path3d.curve

    generate_path_segment(0, 600.0)
    spawn_items_on_path()

func _process(_delta):
    if not is_instance_valid(player_path_follow):
        return

    var player_progress = player_path_follow.progress
    var needed_distance = player_progress + generation_ahead_distance

    if needed_distance > generated_distance:
        generate_path_segment(generated_distance, segment_length)
        spawn_items_on_path()
        cleanup_old_items(player_progress - 100.0)

func generate_path_segment(start_distance: float, length: float):
    var start_point = Vector3.ZERO
    if curve.point_count > 0:
        start_point = curve.get_point_position(curve.point_count - 1)
    else:
        curve.add_point(Vector3.ZERO)

    var last_point = start_point
    var points_to_add = 10
    var step_z = length / float(points_to_add)

    for i in range(1, points_to_add + 1):
        var progress = start_distance + (i * step_z)

        var x_offset = sin(progress * 0.05) * curve_amplitude
        var y_offset = 0.0

        var new_point = start_point + Vector3(x_offset, y_offset, -i * step_z)

        # Smooth handle calculation - this is what matters for smoothness
        var dir = (new_point - last_point).normalized()
        var handle_length = step_z * 0.4

        curve.add_point(new_point, -dir * handle_length, dir * handle_length, -1)

        last_point = new_point

    generated_distance = start_distance + length
    curve.bake_interval = 0.15

# Unified spawning: obstacles + orbs
func spawn_items_on_path():
    if not curve or curve.point_count < 2:
        return

    var spawn_start = max(last_spawn_distance, 0)
    var spawn_end = generated_distance
    if spawn_end <= spawn_start:
        return

    var temp_follower = PathFollow3D.new()
    path3d.add_child(temp_follower)

    var path_length = curve.get_baked_length()
    # The minimum spacing between obstacles is the player's width plus a safety margin.
    var min_spacing_for_obstacles = player_width + safety_margin
    # A smaller, regular distance to check for orb spawns.
    var orb_check_step = 5.0

    var distance = spawn_start

    while distance < spawn_end and distance < path_length:
        temp_follower.progress = distance

        # 1. Decide if we spawn an obstacle at this location.
        var noise_val = noise.get_noise_1d(distance)
        if noise_val > 0.1:
            var item_to_spawn = _get_random_obstacle_item()
            if item_to_spawn:
                _spawn_item(temp_follower, item_to_spawn)
                # If we spawned an obstacle, jump forward by the large safe distance.
                distance += min_spacing_for_obstacles + rng.randf_range(0.0, 5.0)
                # Skip orb spawn at the same position.
                continue

        # 2. If we didn't spawn an obstacle, check for an orb.
        if rng.randf() < orb_spawn_chance:
            _spawn_orb(temp_follower)

        # 3. Always advance by a small, consistent step to allow frequent orb checks.
        distance += orb_check_step

    last_spawn_distance = spawn_end
    temp_follower.queue_free()
func _spawn_item(follower: PathFollow3D, item_data: SpawnableItem):
    if not item_data or not item_data.scene:
        push_error("Attempting to spawn null item or item with null scene!")
        return
    
    var random_angle = rng.randf_range(0, TAU)
    var random_radius = rng.randf_range(item_data.radius_min, item_data.radius_max)

    follower.h_offset = cos(random_angle) * random_radius
    follower.v_offset = 0.0

    var new_item = item_data.scene.instantiate()
    
    if item_data.scale_min < item_data.scale_max:
        var random_scale = rng.randf_range(item_data.scale_min, item_data.scale_max)
        new_item.scale = Vector3(random_scale, random_scale, random_scale)

    # --- THIS IS THE CORRECTED LINE ---
    # We connect the signal directly to the method. This is the modern Godot 4 way.
    if new_item.has_signal("player_collided"):
        if is_instance_valid(player_path_follow):
            new_item.player_collided.connect(player_path_follow._on_obstacle_collision)
    # ------------------------------------

    add_child(new_item)
    new_item.global_position = follower.global_position
    active_items.append(new_item)

func _spawn_orb(follower: PathFollow3D):
    var random_angle = rng.randf_range(0, TAU)
    var random_radius = rng.randf_range(orb_circle_radius_min, orb_circle_radius_max)

    follower.h_offset = cos(random_angle) * random_radius
    follower.v_offset = 0.0

    var orb = get_orb_from_pool()
    if orb:
        orb.global_position = follower.global_position
        active_items.append(orb)

func _get_random_obstacle_item() -> SpawnableItem:
    if obstacle_items.is_empty():
        return null
    # Filter out items with null scenes
    var valid_items = []
    for item in obstacle_items:
        if item and item.scene:
            valid_items.append(item)
    if valid_items.is_empty():
        push_warning("No valid obstacle items found - all have null scenes!")
        return null
    var total_weight = 0.0
    for item in valid_items:
        total_weight += item.weight
    var random_val = rng.randf() * total_weight
    for item in valid_items:
        if random_val < item.weight:
            return item
        random_val -= item.weight
    return valid_items[-1]

func cleanup_old_items(cleanup_progress: float):
    var remaining = []
    for item in active_items:
        if not is_instance_valid(item):
            continue

        var local_pos = path3d.to_local(item.global_position)
        var item_progress = curve.get_closest_offset(local_pos)
        if item_progress < cleanup_progress:
            if item.is_in_group("orbs"):
                _recycle_orb(item)
            else:
                item.queue_free()
        else:
            remaining.append(item)
    active_items = remaining

func get_orb_from_pool() -> Area3D:
    var orb: Area3D
    if not orb_pool.is_empty():
        orb = orb_pool.pop_back()
        orb.visible = true
        orb.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        orb = orb_scene.instantiate()
        add_child(orb)

    if orb.has_signal("collected"):
        var orb_callable = Callable(self, "_on_orb_collected")
        if orb.collected.is_connected(orb_callable):
            orb.collected.disconnect(orb_callable)
        orb.collected.connect(orb_callable)
    return orb

func _on_orb_collected(orb: Area3D):
    if orb.has_signal("collected"):
        var orb_callable = Callable(self, "_on_orb_collected")
        if orb.collected.is_connected(orb_callable):
            orb.collected.disconnect(orb_callable)

    if is_instance_valid(player_path_follow) and player_path_follow.has_method("add_speed_boost"):
        player_path_follow.add_speed_boost()

    if active_items.has(orb):
        active_items.erase(orb)
    if is_instance_valid(orb):
        call_deferred("_recycle_orb", orb)

func _recycle_orb(orb: Area3D):
    if not is_instance_valid(orb):
        return
    orb.visible = false
    orb.process_mode = Node.PROCESS_MODE_DISABLED
    orb_pool.append(orb)
