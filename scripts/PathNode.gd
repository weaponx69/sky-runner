# PathNode.gd
# Base class for all entities that form the path (Orbs and Ghosts).

extends Area3D

var neighbors: Array[Node3D] = []
var is_exit_node: bool = false

# Base properties for things that extend this node
var is_collectible: bool = false
var momentum_value: float = 0.0

func connect_to(other_orb):
    if other_orb and other_orb not in neighbors:
        neighbors.append(other_orb)
