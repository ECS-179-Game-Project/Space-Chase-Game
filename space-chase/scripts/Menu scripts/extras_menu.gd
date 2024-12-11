class_name ExtrasMenu
extends Control

@onready var menu_manager: MenuManager = $".."


func _on_playground_pressed() -> void:
	menu_manager.button_click()
	menu_manager.leave_menu(MenuManager.ExitOption.PLAYGROUND)


func _on_back_pressed() -> void:
	menu_manager.button_click()
	menu_manager.change_menu(MenuManager.MenuState.MAIN)
