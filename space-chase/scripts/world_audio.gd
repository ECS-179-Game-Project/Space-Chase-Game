class_name WorldAudio
extends AudioStreamPlayer2D

func _ready() -> void:
	SceneManager.scene_loaded.connect(_on_level_entered)
	GameStateManager.final_zone_entered.connect(_on_final_zone_entered)
	


func _on_level_entered() -> void:
	pitch_scale = 1.0
	play()


func _on_final_zone_entered():
	pitch_scale = 1.2
