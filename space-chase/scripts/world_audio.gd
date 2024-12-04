class_name WorldAudio
extends AudioStreamPlayer2D

func _ready() -> void:
	SceneManager.scene_loaded.connect(_on_level_entered)


func _on_level_entered() -> void:
	play()
