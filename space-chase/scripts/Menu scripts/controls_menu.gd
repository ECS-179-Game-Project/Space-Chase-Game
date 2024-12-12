class_name ControlsMenu
extends Control


func _on_back_pressed() -> void:
	$Click.play()
	MenuManager.enter_menu(true)
