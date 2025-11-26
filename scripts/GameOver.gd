## Manages the game over screen.
#
# This script handles the user input on the game over screen, specifically the restart button.
extends Control

## Called when the restart button is pressed. Reloads the current scene, effectively restarting the game.
func _on_restart_button_pressed():
	get_tree().reload_current_scene()
