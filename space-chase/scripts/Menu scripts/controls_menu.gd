class_name ControlsMenu
extends Control

@onready var click_sound: AudioStreamPlayer2D = $Node2D/Click


func _on_back_pressed() -> void:
	click_sound.play()
	MenuManager.enter_menu(true)
