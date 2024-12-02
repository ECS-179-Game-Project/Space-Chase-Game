class_name MenuManager
extends Control

enum MenuState {
	MAIN,
	SETTINGS,
}

enum MenuOption {
	START,
	QUIT,
}

@export var instant_start:bool = false # Skips the main menu and instantly starts the game

var cur_menu: MenuState = MenuState.MAIN

var _world_1: String = "res://scenes/world_1.tscn"

@onready var menu_states := {
	MenuState.MAIN: $MainMenu,
	MenuState.SETTINGS: $SettingsMenu,
}
@onready var background_music: AudioStreamPlayer2D = $Audio/BackgroundMusic
@onready var click_sound: AudioStreamPlayer2D = $Audio/Click


func _ready() -> void:
	change_menu(MenuState.MAIN)
	
	if not background_music.playing:
		background_music.play()
	
	if instant_start:
		leave_menu(MenuOption.START, true)


func change_menu(new_menu: MenuState):
	if not new_menu in MenuState.values():
		print("ERROR: Invalid menu transition")
		return
	
	menu_states[cur_menu].visible = false
	menu_states[new_menu].visible = true
	cur_menu = new_menu


func leave_menu(menu_option: MenuOption, skip_transition: bool = false):
	if not menu_option in MenuOption.values():
		print("ERROR: Invalid menu option")
		return
	
	match menu_option:
		MenuOption.START:
			SceneManager.change_scene(_world_1, {
				"pattern": "squares",
				"skip_fade_out": skip_transition,
				"skip_fade_in": skip_transition,
				"on_fade_in": GameStateManager.level_entered.emit,
			})
		MenuOption.QUIT:
			SceneManager.fade_out({
				"pattern": "curtains",
				"on_fade_out": get_tree().quit
			})


func button_click():
	click_sound.play()
