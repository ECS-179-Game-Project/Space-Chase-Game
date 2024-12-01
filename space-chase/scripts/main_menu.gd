class_name MainMenu
extends Control

@export var instant_start:bool = false # Skips the main menu and instantly starts the game

@onready var click_sound = $Music/click

var _world_1:String = "res://scenes/world_1.tscn"
var _settings_menu:String = "res://scenes/settings_menu.tscn"

func _on_ready() -> void:
	if $Music/backgroundmusic.playing == false:
		$Music/backgroundmusic.play()
	
	if instant_start:
		SceneManager.change_scene(_world_1, {"skip_fade_out": true, "skip_fade_in": true})


func _on_start_pressed() -> void:
	click_sound.play()
	SceneManager.change_scene(_world_1, {"pattern": "circle"})


func _on_settings_pressed() -> void:
	click_sound.play()
	SceneManager.change_scene(_settings_menu, {"skip_fade_out": true, "skip_fade_in": true})


func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()
