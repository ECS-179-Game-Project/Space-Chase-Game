class_name MenuManager
extends Control

enum MenuState {
	MAIN,
	SETTINGS,
	CONTROLS,
	VOLUME,
	EXTRAS,
}

enum ExitOption {
	INTRO,
	START,
	PLAYGROUND,
	CONTROLS_AREA,
	QUIT,
}

@export var instant_start:bool = true # Skips the main menu and instantly starts the game

var cur_menu: MenuState = MenuState.MAIN

@onready var menu_states := {
	MenuState.MAIN: $MainMenu,
	MenuState.SETTINGS: $SettingsMenu,
	MenuState.VOLUME: $VolumeMenu,
	MenuState.EXTRAS: $ExtrasMenu,
}
@onready var background_music: AudioStreamPlayer2D = $Audio/BackgroundMusic
@onready var click_sound: AudioStreamPlayer2D = $Audio/Click


func _ready() -> void:
	change_menu(MenuState.MAIN)
	
	# Center the audio players
	background_music.global_position = get_viewport_rect().size / 2
	click_sound.global_position = get_viewport_rect().size / 2
	
	if not background_music.playing:
		background_music.play()
		
	if instant_start:
		leave_menu(ExitOption.START, true)
	

func change_menu(new_menu: MenuState):
	if not new_menu in MenuState.values():
		print("ERROR: Invalid menu transition")
		return
	
	menu_states[cur_menu].visible = false
	menu_states[new_menu].visible = true
	cur_menu = new_menu


static func enter_menu(skip_transition: bool = false):
	SceneManager.change_scene(GameScene.menu_manager, {
		"pattern": "curtains",
		"skip_fade_out": skip_transition,
		"skip_fade_in": skip_transition,
	})


func leave_menu(exit_option: ExitOption, skip_transition: bool = false):
	if not exit_option in ExitOption.values():
		print("ERROR: Invalid exit option")
		return
	
	cur_menu = MenuState.MAIN # Reset to default menu so we can return to it
	
	match exit_option:
		ExitOption.INTRO:
			SceneManager.change_scene(GameScene.intro_cutscene, {
				"pattern": "squares",
				"skip_fade_out": skip_transition,
				"skip_fade_in": skip_transition,
			})
		ExitOption.START:
			SceneManager.change_scene(GameScene.world_1, {
				"pattern": "squares",
				"skip_fade_out": skip_transition,
				"skip_fade_in": skip_transition,
			})
		ExitOption.PLAYGROUND:
			SceneManager.change_scene(GameScene.playground, {
				"pattern": "circle",
				"skip_fade_out": skip_transition,
				"skip_fade_in": skip_transition,
			})
		ExitOption.CONTROLS_AREA:
			SceneManager.change_scene(GameScene.controls_area, {
				"pattern": "circle",
				"skip_fade_out": skip_transition,
				"skip_fade_in": skip_transition,
			})
		ExitOption.QUIT:
			SceneManager.fade_out({
				"pattern": "curtains",
				"on_fade_out": get_tree().quit
			})


func button_click():
	click_sound.play(0.152)
