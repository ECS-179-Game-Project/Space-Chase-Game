class_name PauseMenu
extends Control


func resume():
	get_tree().paused = false 
	$".".visible = false  


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
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	MenuManager.enter_menu()


func _process(delta):
	testEsc()
