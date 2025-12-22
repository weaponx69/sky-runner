# SpaceChunkSpawner.gd
extends Node3D

var player_reference: Node3D 

@export_group("Spawning Config")
@export var orb_scene: PackedScene
@export var ghost_scene: PackedScene
@export_range(0.0, 1.0) var ghost_chance: float = 0.1
# @export var beam_scene: PackedScene # Beam scene is now handled by Angel.gd

@export_group("Generation Settings")
@export var chunk_depth: int = 10     
@export var min_lanes: int = 2       
@export var max_lanes: int = 4        
@export var forward_step: float = 20.0 
@export var lane_width: float = 12.0 # Increased slightly for wider turns

func populate_chunk(start_nodes: Array) -> Array:
    var previous_layer_nodes = start_nodes
    
    # Handle first chunk (if LevelGenerator calls with empty start_nodes)
    if previous_layer_nodes.is_empty():
        var root_node = _create_orb(Vector3.ZERO)
        # If even the root node can't be created (e.g. orb_scene not set), return empty
        if not root_node: return []
        previous_layer_nodes = [root_node]

    # Defensive check: if previous_layer_nodes somehow becomes empty here, return
    if previous_layer_nodes.is_empty():
        print("Warning: populate_chunk called with empty previous_layer_nodes and no root could be created.")
        return []

    # LOOP: Rows
    for i in range(chunk_depth):
        var current_layer_nodes = []
        var orb_count = randi_range(min_lanes, max_lanes)
        
        # Get previous height
        var prev_pos = previous_layer_nodes[0].global_position # This line was causing error 2 if previous_layer_nodes was empty
        var base_z = prev_pos.z
        var base_y = prev_pos.y
        
        # Calculate new height (Slope)
        var row_z = base_z - forward_step
        var row_y = base_y + randf_range(-8.0, 8.0) # +/- 8 units per step is a steep hill
        
        # Clamp height to prevent flying into space or the void
        row_y = clamp(row_y, -60.0, 60.0)

        # LOOP: Orbs in Row
        for j in range(orb_count):
            # Center the lanes
            var total_row_width = (orb_count - 1) * lane_width
            var x_start = -total_row_width / 2.0
            var x_pos = x_start + (j * lane_width)
            
            # Position with Height variation
            var spawn_pos_global = Vector3(x_pos, row_y, row_z)
            var spawn_pos_local = to_local(spawn_pos_global)
            
            var new_orb = _create_orb(spawn_pos_local)
            if new_orb:
                current_layer_nodes.append(new_orb)
        
        # If no orbs were created in this layer, break the loop to prevent further errors
        if current_layer_nodes.is_empty():
            print("Warning: No orbs created in layer %s. Stopping chunk generation." % i)
            break

        _connect_layers(previous_layer_nodes, current_layer_nodes)
        previous_layer_nodes = current_layer_nodes
        
        # Mark Exit Nodes
        if i == chunk_depth - 1:
            for node in current_layer_nodes:
                node.is_exit_node = true

    return previous_layer_nodes

func _connect_layers(from_layer: Array, to_layer: Array):
    if from_layer.is_empty() or to_layer.is_empty():
        return

    for node_a in from_layer:
        # Sort the 'to_layer' nodes by their X distance from 'node_a'
        # This helps in creating more structured left/center/right connections
        to_layer.sort_custom(func(n_b, n_c): 
            return abs(node_a.global_position.x - n_b.global_position.x) < abs(node_a.global_position.x - n_c.global_position.x)
        )

        # Always try to connect to the "straightest" (closest X) node
        if not to_layer.is_empty():
            node_a.connect_to(to_layer[0])

        # Occasionally connect to a left/right node for branching paths
        if to_layer.size() > 1:
            # Connect to a "left" node (if available and not already connected)
            if randf() < 0.4: # 40% chance for a left branch
                var left_candidate = to_layer[0]
                for n_b in to_layer:
                    if n_b.global_position.x < left_candidate.global_position.x:
                        left_candidate = n_b
                if left_candidate != to_layer[0]: # Avoid connecting to the same straight node twice
                    node_a.connect_to(left_candidate)

            # Connect to a "right" node (if available and not already connected)
            if randf() < 0.4: # 40% chance for a right branch
                var right_candidate = to_layer[0]
                for n_b in to_layer:
                    if n_b.global_position.x > right_candidate.global_position.x:
                        right_candidate = n_b
                if right_candidate != to_layer[0]: # Avoid connecting to the same straight node twice
                    node_a.connect_to(right_candidate)
        
        # Fallback: if no connections were made (unlikely with current logic but good for robustness)
        # This part might need further refinement based on desired branching complexity
        # For now, it ensures at least one connection.
        if node_a.neighbors.is_empty() and not to_layer.is_empty():
            var random_target = to_layer.pick_random()
            node_a.connect_to(random_target)


func _create_orb(pos: Vector3) -> Node3D:
    var scene_to_spawn = orb_scene
    if randf() < ghost_chance and ghost_scene:
        scene_to_spawn = ghost_scene
    
    if not scene_to_spawn: return null

    var orb = scene_to_spawn.instantiate()
    orb.position = pos
    add_child(orb)

    # This ensures the Angel script detects this orb belongs to this chunk
    orb.owner = self 
    # -------------------------------

    if orb.has_signal("collected"):
        if is_instance_valid(player_reference) and player_reference.has_method("collect_orb"):
            orb.connect("collected", Callable(player_reference, "collect_orb"))
        else:
            print("Warning: SpaceChunkSpawner: Player reference is null or does not have 'collect_orb' method when connecting orb signal.")
            
    return orb
