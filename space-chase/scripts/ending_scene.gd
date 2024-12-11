extends Label

@onready var game_state_manager = $/root/GameStateManager
const PlayerID = GameStateManager.PlayerID

func pause():
	#figure out a way to detect if the player is charing 
	if  GameStateManager.get_player_energy(PlayerID.PLAYER_1) >= ChargingStation.WIN_THRESHOLD:
		get_tree().paused = true
		$AutoscrollCameraController/EndingScene.visible = true
		$AutoscrollCameraController/EndingScene.text = "PLAYER 1 WINS"
	elif GameStateManager.get_player_energy(PlayerID.PLAYER_2) >= ChargingStation.WIN_THRESHOLD:
		get_tree().paused = true
		$AutoscrollCameraController/EndingScene.visible = true
		$AutoscrollCameraController/EndingScene.text = "PLAYER 2 WINS"
		
func _process(delta):
	pause()
