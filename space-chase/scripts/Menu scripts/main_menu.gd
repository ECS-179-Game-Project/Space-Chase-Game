class_name MainMenu
extends Control

@onready var menu_manager: MenuManager = $".."


func _on_start_pressed() -> void:
	menu_manager.button_click()
	menu_manager.leave_menu(MenuManager.ExitOption.INTRO)


func _on_settings_pressed() -> void:
	menu_manager.button_click()
	menu_manager.change_menu(MenuManager.MenuState.SETTINGS)


func _on_extras_pressed() -> void:
	menu_manager.button_click()
	menu_manager.change_menu(MenuManager.MenuState.EXTRAS)


func _on_quit_pressed() -> void:
	menu_manager.button_click()
	menu_manager.leave_menu(MenuManager.ExitOption.QUIT)


func _on_controls_pressed() -> void:
	menu_manager.button_click()
	menu_manager.change_menu(MenuManager.MenuState.CONTROLS)
