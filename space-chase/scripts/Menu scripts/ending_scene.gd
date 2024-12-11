extends Control


@onready var game_state_manager = $/root/GameStateManager
const PlayerID = GameStateManager.PlayerID
@export var winning_score:float 
func pause():
	#figure out a way to detect if the player is charging 
	#should be another if statement? 
	if  GameStateManager.get_player_energy(PlayerID.PLAYER_1) >= winning_score:
	#ChargingStation.WIN_THRESHOLD:
		get_tree().paused = true
		$".".visible = true
		$VBoxContainer/Label.text = "PLAYER 1 WINS"
	elif GameStateManager.get_player_energy(PlayerID.PLAYER_2) >= winning_score:
	#ChargingStation.WIN_THRESHOLD:
		get_tree().paused = true
		$".".visible = true
		$VBoxContainer/Label.text = "PLAYER 2 WINS"
		
func _process(delta):
	pause()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	$".".visible = false
	MenuManager.enter_menu()
