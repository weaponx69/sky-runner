## A resource that defines the properties of a spawnable item in the game.
#
# This class is used to create assets that can be procedurally spawned in the game world.
# Each `SpawnableItem` holds information about its scene, spawn weight, spawn radius, and scale.
extends Resource
class_name SpawnableItem

## The `PackedScene` to instance for this item.
@export var scene: PackedScene
## How likely this item is to be chosen for spawning. Higher values are more common (e.g., 10 for common, 1 for rare).
@export var weight: float = 1.0
## The minimum distance from the spawn path that this item can be placed.
@export var radius_min: float = 5.0
## The maximum distance from the spawn path that this item can be placed.
@export var radius_max: float = 10.0

@export_group("Sizing")
## The minimum scale of the spawned item.
@export var scale_min: float = 1.0
## The maximum scale of the spawned item.
@export var scale_max: float = 1.0
