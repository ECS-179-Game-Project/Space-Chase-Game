extends Control

func quit():
	get_tree().paused = false
	$".".visible = false
	MenuManager.enter_menu()


func _on_pressed() -> void:
	quit()
