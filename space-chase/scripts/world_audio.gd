class_name WorldAudio
extends AudioStreamPlayer2D

func _ready() -> void:
	GameStateManager.level_entered.connect(_on_level_entered)


func _on_level_entered() -> void:
	play()
