class_name PauseMenu
extends Control

@onready var game_state_manager = $/root/GameStateManager
const PlayerID = GameStateManager.PlayerID

func resume():
	get_tree().paused = false 
	$".".visible = false  

func quit():
	get_tree().paused = false 
	$".".visible = false  
	MenuManager.enter_menu()
	
func restart():
	get_tree().paused = false 
	$".".visible = false  
	get_tree().reload_current_scene()
	game_state_manager.set_player_energy(PlayerID.PLAYER_1,0)
	game_state_manager.set_player_energy(PlayerID.PLAYER_2,0)

func pause():
	get_tree().paused = true
	$".".visible = true


func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	restart()


func _on_quit_pressed() -> void:
	quit()


func _process(delta):
	testEsc()
