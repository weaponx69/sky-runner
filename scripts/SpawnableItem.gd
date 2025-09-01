# res://scripts/SpawnableItem.gd
extends Resource
class_name SpawnableItem

## The scene to instance for this item.
@export var scene: PackedScene
## How likely this item is to be chosen (e.g., 10 for common, 1 for rare).
@export var weight: float = 1.0
## Minimum distance from the path to spawn.
@export var radius_min: float = 5.0
## Maximum distance from the path to spawn.
@export var radius_max: float = 10.0

@export_group("Sizing")
@export var scale_min: float = 1.0
@export var scale_max: float = 1.0
