extends ProgressBar


@onready var game_state_manager = $/root/GameStateManager
const PlayerID = GameStateManager.PlayerID
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		value = game_state_manager.get_player_energy(PlayerID.PLAYER_1)
