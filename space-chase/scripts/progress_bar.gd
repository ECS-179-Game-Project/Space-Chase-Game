extends ProgressBar

@onready var game_state_manager = $/root/GameStateManager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = game_state_manager.get_level_progress() * 500
