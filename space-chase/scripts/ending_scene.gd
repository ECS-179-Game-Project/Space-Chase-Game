extends Label

@onready var game_state_manager = $/root/GameStateManager
const PlayerID = GameStateManager.PlayerID

func pause():
	#figure out a way to detect which player wins 
	#should via player score 
	#also add an option to return back to main menu
	get_tree().paused = true
	$AutoscrollCameraController/EndingScene.visible = true
	 
