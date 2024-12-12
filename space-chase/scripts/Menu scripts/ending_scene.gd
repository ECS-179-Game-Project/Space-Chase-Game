class_name EndingScene
extends Control

const PlayerID = GameStateManager.PlayerID

func quit():
	get_tree().paused = false
	$".".visible = false
	MenuManager.enter_menu()

func pause():
	 #figure out a way to detect if the player is charging 
	#should be another if statement? 
	if PlayerID.PLAYER_1:
		#get_tree().paused = true
		$".".visible = true
		$VBoxContainer/Label.text = "PLAYER 1 WINS"
	elif PlayerID.PLAYER_2:
		#get_tree().paused = true
		$".".visible = true
		$VBoxContainer/Label.text = "PLAYER 2 WINS"

func _on_quit_pressed() -> void:
	quit() # Replace with function body.
