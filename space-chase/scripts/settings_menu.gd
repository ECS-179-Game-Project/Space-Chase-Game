class_name SettingsMenu
extends Control


func _on_back_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn", {"skip_fade_out": true, "skip_fade_in": true})
