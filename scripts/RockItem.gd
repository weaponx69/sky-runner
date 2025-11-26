## Represents a rock item in the game.
#
# This script defines the properties of a rock, which is a type of `SpawnableItem`.
extends SpawnableItem
class_name RockItem

## The name of the rock item.
@export var name: String = "Rock"
## A boolean value that indicates whether the rock can be broken by the player.
@export var can_break: bool = true
