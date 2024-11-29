class_name MainMenu
extends Control


func _on_start_pressed() -> void:
	SceneManager.change_scene("res://scenes/world_1.tscn", {"pattern": "circle"})


func _on_settings_pressed() -> void:
	SceneManager.change_scene("res://scenes/settings_menu.tscn", {"skip_fade_out": true, "skip_fade_in": true})


func _on_quit_pressed() -> void:
	get_tree().quit()
