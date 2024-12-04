extends Node # No class name because autoloaded script

"""
Manages powerups between players
Applies and unapplies powerup for a player (unapplying is for temporary powerups)
Uses a powerup enum (autoload this script so powerup scenes have access to this enum)
"""

enum PowerupType {
	SPEED_BOOST,
	JUMP_BOOST,
	SHIELD,
	POWER_BOOST,
	FLOATY_JUMP,
	ENERGY_GAIN
}


# { Player_Id: { SPEED_BOOST: true, JUMP_BOOST: true } }
var active_powerups: Dictionary = {}

func apply_powerup(type: PowerupType, player: Player, duration: float) -> void:
	# Initialize player's active power-ups if not already set
	if not active_powerups.has(player.player_id):
		active_powerups[player.player_id] = {}

	match type:
		PowerupType.SPEED_BOOST:
			player.speed *= 1.5
		PowerupType.JUMP_BOOST:
			player.jump_force *= 1.5
		# Has to be implemented inside player class
		PowerupType.SHIELD:
			player.shield_active = true
		PowerupType.POWER_BOOST:
			player.throw_strength *= 1.5
		PowerupType.FLOATY_JUMP:
			player.gravity *= 0.5
		PowerupType.ENERGY_GAIN:
			player.energy += 5 # This is permanent

	active_powerups[player][type] = true
	print("Applied power-up: %s to player %s" % [type, player])

	# If temporary, set a timer to automatically unapply
	if type != PowerupType.ENERGY_GAIN:  # Permanent power-ups don't need timers
		_start_unapply_timer(type, player, duration)  # Adjust duration as needed

func unapply_powerup(type: PowerupType, player: Player) -> void:
	# Apply to active powerups
	if not active_powerups[player][type] == false:
		return

	# Remove the specific powerups effect
	match type:
		PowerupType.SPEED_BOOST:
			player.speed /= 1.5
		PowerupType.JUMP_BOOST:
			player.jump_force /= 1.5
		PowerupType.SHIELD:
			player.shield_active = false
		PowerupType.POWER_BOOST:
			player.throw_strength /= 1.5
		PowerupType.FLOATY_JUMP:
			player.gravity /= 0.5

	# The powerup as inactive
	active_powerups[player.player_id].pop(type)
	print("Unapplied power-up: %s from player %s" % [type, player])

func _start_unapply_timer(type: PowerupType, player: Player, duration: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout.bind(type, player))
	timer.start(duration)

func _on_timer_timeout(type: PowerupType, player:Player):
	unapply_powerup(type, player)
	
