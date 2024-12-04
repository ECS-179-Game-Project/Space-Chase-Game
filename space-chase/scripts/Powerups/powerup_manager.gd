extends Node # No class name because autoloaded script

"""
Manages powerups between players
Applies and unapplies powerup for a player (unapplying is for temporary powerups)
Uses a powerup enum (autoload this script so powerup scenes have access to this enum)
"""

enum PowerupType {
	SPEED_BOOST,
	JUMP_BOOT,
}


func apply_powerup(type:PowerupType, player:Player) -> void: # Add param for player
	pass


func unapply_powerup(type:PowerupType, player:Player) -> void: # Add param for player
	pass
