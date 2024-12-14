class_name EndingScene
extends Control

const PlayerID = GameStateManager.PlayerID

func _ready():
	pass

func quit():
	get_tree().paused = false
	$".".visible = false
	MenuManager.enter_menu()


func pause(id: GameStateManager.PlayerID = GameStateManager.PlayerID.PLAYER_1):
	$".".visible = true
	$VBoxContainer/Label.text = str("PLAYER ", id + 1, " WINS")


func _on_quit_pressed() -> void:
	quit() # Replace with function body.


#func _on_player_win(id: GameStateManager.PlayerID):
	#pause(id)
