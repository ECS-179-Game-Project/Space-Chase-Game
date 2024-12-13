class_name ControlsMenu
extends Control

@onready var click_sound: AudioStreamPlayer2D = $Node2D/Click
@onready var p1_jump_with_up: CheckButton = $Control/Settings/VBoxContainer/P1JumpWithUp
@onready var p2_jump_with_up: CheckButton = $Control/Settings/VBoxContainer/P2JumpWithUp

func _ready() -> void:
	p1_jump_with_up.button_pressed = PlayerControls.use_up_as_jump[GameStateManager.PlayerID.PLAYER_1]
	p2_jump_with_up.button_pressed = PlayerControls.use_up_as_jump[GameStateManager.PlayerID.PLAYER_2]


func _on_back_pressed() -> void:
	click_sound.play()
	MenuManager.enter_menu(true)


func _on_p1_jump_with_up_toggled(toggled_on: bool) -> void:
	PlayerControls.use_up_as_jump[GameStateManager.PlayerID.PLAYER_1] = toggled_on


func _on_p2_jump_with_up_toggled(toggled_on: bool) -> void:
	PlayerControls.use_up_as_jump[GameStateManager.PlayerID.PLAYER_2] = toggled_on
