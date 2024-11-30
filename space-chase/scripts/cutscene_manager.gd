class_name CutsceneManager
extends Node

"""
Stores references to both players
"""

# Consider storing references to ships, wall of death as well,
# if we want more stuff in cutscenes.

# Reference to PLAYER_1
@export var player_1: Player
# Reference to PLAYER_2
@export var player_2: Player


func start_cutscene() -> void:
	pass


func end_cutscene() -> void:
	pass
