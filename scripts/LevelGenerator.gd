extends Node3D

@export var chunk_scene: PackedScene
@export var initial_chunk_count: int = 3
@export var chunks_behind_player: int = 2

var last_chunk_exit_nodes: Array = []
var spawned_chunks: Array = []
var _current_player_chunk: Node3D = null
var player: Node3D

func _ready():
    player = get_tree().get_first_node_in_group("player")
    
    # 1. REMOVE THE CONNECTION FROM HERE
    # if player:
    #    player.player_changed_chunk.connect(_on_player_changed_chunk)

    # 2. Create the start line
    var start_orb = _create_initial_orb()
    last_chunk_exit_nodes = [start_orb]
    
    # 3. Manually spawn the initial world
    for i in range(initial_chunk_count):
        spawn_next_chunk()
        
    # 4. NOW connect the signal (The "Engine Start" button)
    # We only want to listen for updates AFTER the initial world is built.
    if player:
        player.player_changed_chunk.connect(_on_player_changed_chunk)

func spawn_next_chunk():
    if not chunk_scene: return
    
    var new_chunk = chunk_scene.instantiate()
    spawned_chunks.append(new_chunk)
    
    var avg_pos = Vector3.ZERO
    if not last_chunk_exit_nodes.is_empty():
        for node in last_chunk_exit_nodes:
            avg_pos += node.global_position
        avg_pos /= last_chunk_exit_nodes.size()
    
    add_child(new_chunk)
    new_chunk.global_position = avg_pos
    
    if new_chunk.has_method("populate_chunk"):
        new_chunk.player_reference = player # Set the player reference
        var new_exits = new_chunk.populate_chunk(last_chunk_exit_nodes) # Removed player argument
        last_chunk_exit_nodes = new_exits

func _on_player_changed_chunk(chunk: Node3D):
    _current_player_chunk = chunk
    _despawn_chunks()
    spawn_next_chunk()

func _despawn_chunks():
    if not _current_player_chunk: return
    
    var current_index = spawned_chunks.find(_current_player_chunk)
    if current_index > chunks_behind_player:
        var chunks_to_remove_count = current_index - chunks_behind_player
        for i in range(chunks_to_remove_count):
            var chunk_to_remove = spawned_chunks.pop_front()
            if chunk_to_remove:
                chunk_to_remove.queue_free()

func _create_initial_orb() -> Node3D:
    var orb_scene = preload("res://scenes/Orb3D.tscn")
    var orb = orb_scene.instantiate()
    orb.position = Vector3.ZERO
    add_child(orb)
    # The initial orb is not in a chunk, so we need to handle its "chunk"
    # For now, let's just use the LevelGenerator itself as a dummy chunk.
    # This is a bit of a hack, but it will work for the signal.
    # A better solution might be to have a dedicated "StartChunk".
    if player and player.has_method("start_at_orb"):
         player.start_at_orb(orb)
         orb.owner = self # Set owner so player can emit player_changed_chunk
    return orb
