extends Control

const PlayerID = GameStateManager.PlayerID

@onready var game_state_manager: GameStateManager = $/root/GameStateManager
@export var winning_score:float 

func quit():
	get_tree().paused = false
	$".".visible = false
	MenuManager.enter_menu()

func pause():
	 #figure out a way to detect if the player is charging 
	#should be another if statement? 
	
	if GameStateManager.get_player_energy(PlayerID.PLAYER_1) >= 1:
	#ChargingStation.WIN_THRESHOLD:
		#get_tree().paused = true
		$".".visible = true
		$VBoxContainer/Label.text = "PLAYER 1 WINS"
	elif GameStateManager.get_player_energy(PlayerID.PLAYER_2) >= 1:
	#ChargingStation.WIN_THRESHOLD:
		#get_tree().paused = true
		$".".visible = true
		$VBoxContainer/Label.text = "PLAYER 2 WINS"

func _on_quit_pressed() -> void:
	quit() # Replace with function body.
