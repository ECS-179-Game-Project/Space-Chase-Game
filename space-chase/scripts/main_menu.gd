class_name MainMenu
extends Control

@onready var menu_manager: MenuManager = $".."


func _on_start_pressed() -> void:
	menu_manager.button_click()
	menu_manager.leave_menu(MenuManager.MenuOption.START)


func _on_settings_pressed() -> void:
	menu_manager.button_click()
	menu_manager.change_menu(MenuManager.MenuState.SETTINGS)


func _on_quit_pressed() -> void:
	menu_manager.button_click()
	menu_manager.leave_menu(MenuManager.MenuOption.QUIT)
