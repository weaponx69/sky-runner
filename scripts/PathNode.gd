# PathNode.gd
# Base class for all entities that form the path (Orbs and Ghosts).

extends Area3D

# --- CONNECTION REFERENCES (Set by the Level Generator) ---
# The next node in the forward chain (where the player flies next)
var next_node = null 
# Nodes to the immediate left/right (for switching lanes)
var neighbor_left = null
var neighbor_right = null

# --- CUSTOM PROPERTIES ---
@export var is_collectible: bool = true 
@export var momentum_value: float = 5.0 # Positive value for orbs, 0 or negative for hazards
