class_name ControlsMenu
extends Control

@onready var click_sound: AudioStreamPlayer2D = $Node2D/Click


func _on_back_pressed() -> void:
	click_sound.play()
	MenuManager.enter_menu(true)


func _on_p1_jump_with_up_toggled(toggled_on: bool) -> void:
	PlayerControls.use_up_as_jump[GameStateManager.PlayerID.PLAYER_1] = toggled_on


func _on_p2_jump_with_up_toggled(toggled_on: bool) -> void:
	PlayerControls.use_up_as_jump[GameStateManager.PlayerID.PLAYER_1] = toggled_on
