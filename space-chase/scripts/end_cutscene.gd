class_name EndCutscene
extends Node

@export var skip_cutscene: bool = false

@onready var cutscene_animation_player: AnimationPlayer = $CutsceneAnimationPlayer
@onready var red_win_animation_player: AnimationPlayer = $RedWinAnimationPlayer
@onready var green_win_animation_player: AnimationPlayer = $GreenWinAnimationPlayer
@onready var background_music: AudioStreamPlayer2D = $Audio/BackgroundMusic
@onready var explosion_sound: AudioStreamPlayer2D = $Planet/Explosion/Explosion
@onready var red_lazer_sound: AudioStreamPlayer2D = $RedShip/RedFire/LazerRedShip
@onready var blue_lazer_sound: AudioStreamPlayer2D = $GreenShip/GreenFire/LazerBlueShip
@onready var end_ui: Control = $EndUI
@onready var label: Label = $EndUI/VBoxContainer/Label


func _ready() -> void:
	SceneManager.scene_loaded.connect(_on_cutscene_entered)
	background_music.play()
	end_ui.visible = false


func _process(_delta: float) -> void:
	if SceneManager.is_transitioning:
		return
	
	#if Input.is_anything_pressed():
		#end_cutscene()


func end_cutscene() -> void:
	end_ui.visible= true
	#SceneManager.change_scene(GameScene.world_1, {
		#"pattern": "circle",
		#"skip_fade_out": skip_cutscene,
		#"skip_fade_in": skip_cutscene,
		#"on_fade_out": cutscene_animation_player.play.bind("RESET")
	#})


func play_explosion_sound():
	explosion_sound.play()


func play_red_ship_shoot_sound():
	red_lazer_sound.play()


func play_blue_ship_shoot_sound():
	blue_lazer_sound.play()


func _on_quit_pressed() -> void:
	MenuManager.enter_menu()


func _on_cutscene_entered() -> void:
	if skip_cutscene:
		end_cutscene()
	else:
		cutscene_animation_player.play("start_cutscene") # Will eventually call end_cutscene()
		if GameStateManager.winning_player == GameStateManager.PlayerID.PLAYER_1:
			red_win_animation_player.play("start_cutscene")
			label.text = "PLAYER 1 WINS!"
		else:
			green_win_animation_player.play("start_cutscene")
			label.text = "PLAYER 2 WINS!"
