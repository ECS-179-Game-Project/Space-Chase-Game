class_name BasePowerup
extends CharacterBody2D

"""
Custom powerup types should extend this class
Make sure each powerup type has its own scene

If player collects it, gives the player energy (through game state manager)
Gives abilities to the player (through powerup manager)
"""

@export var duration: float = 5.0  


func apply_power_up(player: Player) -> void:
	pass


func revert(player: Player) -> void:
	pass
