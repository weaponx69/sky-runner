## A smooth camera that follows the player.
#
# This script is attached to a `SpringArm3D` node, which automatically follows its parent (the Angel node).
# No code is needed in `_process()` to manage its position. All camera settings should be adjusted in the Godot Inspector.
extends SpringArm3D

## Called every frame. The `_process` function is intentionally left empty as the `SpringArm3D` handles all camera movement.
# - `_delta`: The time elapsed since the previous frame.
func _process(_delta):
    pass
