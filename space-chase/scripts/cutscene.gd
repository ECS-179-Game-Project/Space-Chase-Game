class_name Cutscene
extends Node

@export var skip_cutscene: bool = false

@onready var cutscene_animation_player: AnimationPlayer = $CutsceneAnimationPlayer


func _ready() -> void:
	SceneManager.scene_loaded.connect(_on_cutscene_entered)


func _process(delta: float) -> void:
	if SceneManager.is_transitioning:
		return
	
	if Input.is_anything_pressed():
		end_cutscene()


func end_cutscene() -> void:
	SceneManager.change_scene(GameScene.world_1, {
		"pattern": "circle",
		"skip_fade_out": skip_cutscene,
		"skip_fade_in": skip_cutscene,
		"on_fade_out": cutscene_animation_player.play.bind("RESET")
	})


func _on_cutscene_entered() -> void:
	if skip_cutscene:
		end_cutscene()
	else:
		cutscene_animation_player.play("start_cutscene") # Will eventually call end_cutscene()
		
