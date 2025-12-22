extends CharacterBody3D
class_name Angel

signal player_changed_chunk(chunk: Node3D)
signal speed_changed(new_speed: float)

# --- CONFIGURATION ---
@export var min_travel_speed: float = 10.0
@export var max_travel_speed: float = 50.0
@export var travel_speed: float = 20.0
@export var arc_height: float = 5.0

@onready var path_track: Path3D = $Path3D
@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D
@onready var model: Node3D = $Path3D/PathFollow3D/AngelModel

# --- STATE ---
var current_orb: Node3D = null
var target_orb: Node3D = null
var is_traveling: bool = false
var intended_lane_choice: int = 0
var highlighted_orb: Node3D = null
var arc_direction: int = 1

func _ready():
    travel_speed = clamp(travel_speed, min_travel_speed, max_travel_speed)
    speed_changed.emit(travel_speed)
func _physics_process(delta):
    _update_selection_highlight()

    if is_traveling:
        _handle_locked_movement(delta)
    
    _handle_input_buffering()

    if not is_traveling and current_orb and not current_orb.neighbors.is_empty():
        var next_node = _pick_node_from_choice(current_orb.neighbors, intended_lane_choice)
        if next_node:
            start_travel(next_node)
            intended_lane_choice = 0

func _handle_input_buffering():
    if is_traveling:
        if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
            var choice = 1 if Input.is_action_just_pressed("ui_right") else -1
            
            if target_orb == null or target_orb.neighbors.is_empty():
                return

            var new_target = _pick_node_from_choice(target_orb.neighbors, choice)
            
            if new_target and new_target != target_orb:
                # Move the whole Angel to the current flight position
                global_position = path_follow.global_position

                # Reroute to the new target
                var local_end = to_local(new_target.global_position)
                _create_arc_path(Vector3.ZERO, local_end)

                path_follow.progress = 0
                target_orb = new_target
    else:
        # Original logic for when stationary
        if Input.is_action_just_pressed("ui_left"):
            intended_lane_choice = -1
        elif Input.is_action_just_pressed("ui_right"):
            intended_lane_choice = 1
        elif Input.is_action_just_pressed("ui_up"):
            intended_lane_choice = 0

func _handle_locked_movement(delta):
    # Calculate a speed based on the position on the curve
    # 0.0 = start, 0.5 = peak, 1.0 = end
    var dist_from_mid = abs(path_follow.progress_ratio - 0.5) # Range: 0.0 (peak) to 0.5 (start/end)
    var t = dist_from_mid * 2.0 # Convert to a 0.0-1.0 range for lerp
    var current_speed = lerp(min_travel_speed, travel_speed, t)
    
    # Also emit the signal to update the UI
    speed_changed.emit(current_speed)

    path_follow.progress += current_speed * delta
    
    if path_follow.progress_ratio >= 1.0:
        _arrive_at_junction()

func _arrive_at_junction():
    global_position = target_orb.global_position
    current_orb = target_orb
    target_orb = null
    is_traveling = false
    arc_direction *= -1 # Flip the direction for the next arc
    
    if current_orb and current_orb.owner:
        player_changed_chunk.emit(current_orb.owner)
    
    _update_selection_highlight()

func _pick_node_from_choice(neighbors: Array, choice: int) -> Node3D:
    if neighbors.is_empty():
        return null

    neighbors.sort_custom(_sort_neighbors_by_x)

    if neighbors.size() == 1:
        return neighbors[0]
    if neighbors.size() == 2:
        if choice == -1:
            return neighbors[0]
        else:
            return neighbors[1]

    # For 3 or more neighbors
    if choice == -1: # Left
        return neighbors[0]
    elif choice == 1: # Right
        return neighbors.back()
    else: # Center
        var mid_index = neighbors.size() / 2
        return neighbors[mid_index]

func _sort_neighbors_by_x(a: Node3D, b: Node3D) -> bool:
    return a.global_position.x < b.global_position.x

func start_travel(next_orb: Node3D):
    target_orb = next_orb
    is_traveling = true
    path_follow.progress = 0
    
    var local_end = to_local(next_orb.global_position)
    _create_arc_path(Vector3.ZERO, local_end)
    
    current_orb = null
    
func start_at_orb(orb: Node3D):
    global_position = orb.global_position
    current_orb = orb
    is_traveling = false
    if current_orb and current_orb.owner:
        player_changed_chunk.emit(current_orb.owner)
    _update_selection_highlight()

func _update_selection_highlight() -> void:
    var node_to_get_neighbors_from = target_orb if is_traveling else current_orb
        
    if node_to_get_neighbors_from == null:
        # Clear any existing highlight if there's nothing to select
        if is_instance_valid(highlighted_orb):
            highlighted_orb.set_highlight(false)
            highlighted_orb = null
        return

    var neighbors: Array = node_to_get_neighbors_from.neighbors
    if neighbors.is_empty():
        if is_instance_valid(highlighted_orb):
            highlighted_orb.set_highlight(false)
            highlighted_orb = null
        return

    var selected_neighbor: Node3D = _pick_node_from_choice(neighbors, intended_lane_choice)

    if selected_neighbor != highlighted_orb:
        if is_instance_valid(highlighted_orb) and highlighted_orb.has_method("set_highlight"):
            highlighted_orb.set_highlight(false)
        
        if is_instance_valid(selected_neighbor) and selected_neighbor.has_method("set_highlight"):
            selected_neighbor.set_highlight(true)
            highlighted_orb = selected_neighbor
        else:
            # The selected neighbor is not highlightable (e.g., a Ghost)
            # or is null, so we set highlighted_orb to null.
            highlighted_orb = null

func collect_orb(_orb, amount):
    travel_speed = clamp(travel_speed + amount, min_travel_speed, max_travel_speed)
    speed_changed.emit(travel_speed)

func decrease_speed(amount):
    travel_speed = clamp(travel_speed - amount, min_travel_speed, max_travel_speed)
    speed_changed.emit(travel_speed)


func _create_arc_path(start_pos_local: Vector3, end_pos_local: Vector3):
    var curve = path_track.curve
    if not curve:
        curve = Curve3D.new()
        path_track.curve = curve
    curve.clear_points()

    var direction = (end_pos_local - start_pos_local).normalized()
    
    # Handle straight-up or straight-down case
    var sideways = direction.cross(Vector3.UP)
    if sideways.is_zero_approx():
        sideways = Vector3.RIGHT
    sideways = sideways.normalized()

    var offset = sideways * arc_height * arc_direction
    
    # Define control points in local space
    var cp1 = start_pos_local.lerp(end_pos_local, 0.25) + offset
    var cp2 = start_pos_local.lerp(end_pos_local, 0.75) + offset
    
    # Define the handles relative to their anchor points
    var start_handle_out = cp1 - start_pos_local
    var end_handle_in = cp2 - end_pos_local
    
    curve.add_point(start_pos_local, Vector3.ZERO, start_handle_out)
    curve.add_point(end_pos_local, end_handle_in, Vector3.ZERO)
