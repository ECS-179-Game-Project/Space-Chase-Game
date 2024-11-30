class_name SettingsMenu
extends Control

var _main_menu:String = "res://scenes/main_menu.tscn"

func _on_back_pressed() -> void:
	SceneManager.change_scene(_main_menu, {"skip_fade_out": true, "skip_fade_in": true})
