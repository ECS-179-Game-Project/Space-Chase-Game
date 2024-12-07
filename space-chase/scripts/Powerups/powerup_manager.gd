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
	ENERGY_GAIN,
	GET_BIG,
}

# { Player_Id: { SPEED_BOOST: { active: true, timer: Timer }, JUMP_BOOST: { active: true, timer: Timer } } }
var active_powerups: Dictionary = {}

func apply_powerup(type: PowerupType, player: Player, duration: float) -> void:
	# Initialize player's active power-ups if not already set
	if not active_powerups.has(player.player_id):
		active_powerups[player.player_id] = {}

	# If power-up is not already active, apply it
	if not active_powerups[player.player_id].has(type) or not active_powerups[player.player_id][type]["active"]:
		match type:
			PowerupType.SPEED_BOOST:
				player.speed *= 1.5
			PowerupType.JUMP_BOOST:
				player.jump_force *= 1.5
			PowerupType.SHIELD:
				player.shield_active = true
			PowerupType.POWER_BOOST:
				player.throw_strength *= 1.5
			PowerupType.FLOATY_JUMP:
				player.gravity *= 0.5
			PowerupType.GET_BIG:
				player.scale *= 2
				player.position.y *= 2
			PowerupType.ENERGY_GAIN:
				player.energy += 5  # Permanent, no timer needed
				
		print("Applied power-up: %s to player %s" % [type, player])

		# If temporary, start a timer
		if type != PowerupType.ENERGY_GAIN:
			var timer = _start_unapply_timer(type, player, duration)
			active_powerups[player.player_id][type] = { "active": true, "timer": timer }
	else:
		# Increase the existing timer duration
		var powerup_data = active_powerups[player.player_id][type]
		_increase_timer(powerup_data["timer"], duration)

func unapply_powerup(type: PowerupType, player: Player) -> void:
	# Check if power-up is active
	if active_powerups.has(player.player_id) and active_powerups[player.player_id].has(type):
		# Remove the power-up effect
		match type:
			PowerupType.SPEED_BOOST:
				player.speed /= 1.5
			PowerupType.JUMP_BOOST:
				player.jump_force /= 1.5
			PowerupType.SHIELD:
				player.shield_active = false
			PowerupType.POWER_BOOST:
				player.throw_strength /= 1.5
			PowerupType.GET_BIG:
				player.scale /= 2
				player.position.y /= 2
			PowerupType.FLOATY_JUMP:
				player.gravity *= 0.5

		# Stop and remove the timer
		var powerup_data = active_powerups[player.player_id][type]
		if powerup_data["timer"].is_queued_for_deletion() == false:
			powerup_data["timer"].queue_free()
		
		# Update dictionary
		active_powerups[player.player_id].erase(type)
		print("Unapplied power-up: %s from player %s" % [type, player])

func _start_unapply_timer(type: PowerupType, player: Player, duration: float) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout.bind(type, player))
	timer.start(duration)
	return timer

func _increase_timer(timer: Timer, duration: float) -> void:
	timer.start(timer.time_left + duration)

func _on_timer_timeout(type: PowerupType, player: Player) -> void:
	unapply_powerup(type, player)
