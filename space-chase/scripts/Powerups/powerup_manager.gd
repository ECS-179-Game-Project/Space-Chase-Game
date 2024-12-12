extends Node # No class name because autoloaded script

"""
Manages powerups between players
Applies and unapplies powerup for a player (unapplying is for temporary powerups)
Uses a powerup enum (autoload this script so powerup scenes have access to this enum)
"""

const SPEED_MULTIPLIER: float = 1.25
const JUMP_MULTIPLIER: float = 1.25
const THROW_MULTIPLIER: float = 1.5
const SCALE_MULTIPLIER: float = 1.5



enum PowerupType {
	SPEED_BOOST,
	JUMP_BOOST,
	SHIELD,
	ENERGY_GAIN,
	GET_BIG,
	GET_SMALL,
}

# { Player_Id: { SPEED_BOOST: { active: true, timer: Timer }, JUMP_BOOST: { active: true, timer: Timer } } }
var active_powerups: Dictionary = {}
@onready var game_state_manager = $/root/GameStateManager
func apply_powerup(type: PowerupType, player: Player, duration: float) -> void:
	# Initialize player's active power-ups if not already set
	if not active_powerups.has(player.player_id):
		active_powerups[player.player_id] = {}

	# If power-up is not already active, apply it
	if not active_powerups[player.player_id].has(type) or not active_powerups[player.player_id][type]["active"]:
		match type:
			PowerupType.SPEED_BOOST:
				player.speed *= SPEED_MULTIPLIER
			PowerupType.JUMP_BOOST:
				player.jump_force *= JUMP_MULTIPLIER
			PowerupType.SHIELD: # Permanent, no timer needed
				player.active_shield = true
			PowerupType.GET_BIG:
				player.scale *= SCALE_MULTIPLIER
				player.throw_strength *= THROW_MULTIPLIER
			PowerupType.GET_SMALL:
				player.scale /= SCALE_MULTIPLIER
				player.max_dashes += 1
			PowerupType.ENERGY_GAIN:
				game_state_manager.add_player_energy(25, player.player_id) # Permanent, no timer needed
		
		print("Applied power-up: %s to player %s" % [PowerupType.keys()[type], player])

		# If temporary, start a timer
		if type != PowerupType.ENERGY_GAIN and type != PowerupType.SHIELD:
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
				player.speed /= SPEED_MULTIPLIER
			PowerupType.JUMP_BOOST:
				player.jump_force /= JUMP_MULTIPLIER
			PowerupType.GET_BIG:
				player.throw_strength /= THROW_MULTIPLIER
				player.scale /= SCALE_MULTIPLIER
			PowerupType.GET_SMALL:
				player.scale *= SCALE_MULTIPLIER
				player.max_dashes -= 1

		# Stop and remove the timer
		var powerup_data = active_powerups[player.player_id][type]
		if powerup_data["timer"].is_queued_for_deletion() == false:
			powerup_data["timer"].queue_free()
		
		# Update dictionary
		active_powerups[player.player_id].erase(type)
		print("Unapplied power-up: %s from player %s" % [PowerupType.keys()[type], player])

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

func _clear_all_buffs(player: Player) -> void:
	
	for player_id in PowerupManager.active_powerups.keys():
		for powerup_type in PowerupManager.active_powerups[player_id].keys():
			unapply_powerup(powerup_type, player)
