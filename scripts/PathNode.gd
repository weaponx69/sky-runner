# PathNode.gd
# Base class for all entities that form the path (Orbs and Ghosts).

extends Area3D

# --- CRITICAL DATA ---
# The LevelGenerator writes to this array. 
# The Angel reads from this array to know where to fly next.
var neighbors: Array = [] 

# Base properties for things that extend this node
var is_collectible: bool = false
var momentum_value: float = 0.0

# --- CONNECTION REFERENCES (Set by the Level Generator) ---
# The next node in the forward chain (where the player flies next)
var next_node = null 
# Nodes to the immediate left/right (for switching lanes)
var neighbor_left = null
var neighbor_right = null
