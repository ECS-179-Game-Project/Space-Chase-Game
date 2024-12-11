extends ProgressBar


const PlayerID = GameStateManager.PlayerID
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = GameStateManager.get_player_energy(PlayerID.PLAYER_1)
