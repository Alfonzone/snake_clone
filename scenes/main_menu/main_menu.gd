class_name MainMenu
extends ColorRect

## The game's main menu.

func _ready() -> void:
	$HBoxContainer/VBoxContainer/DifficultySlider.value = roundf(6.0 - TurnTimer.wait_time * 10.0)


func _on_h_slider_value_changed(value: float) -> void:
	$HBoxContainer/VBoxContainer/DifficultyLabel.text = "Difficulty: %s" % value
	TurnTimer.wait_time = (6.0 - value) / 10.0


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
