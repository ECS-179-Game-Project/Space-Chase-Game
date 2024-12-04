class_name SettingsMenu
extends Control

@onready var menu_manager: MenuManager = $".."


func _on_back_pressed() -> void:
	menu_manager.button_click()
	menu_manager.change_menu(MenuManager.MenuState.MAIN)
