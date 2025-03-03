extends Node # No class name because autoloaded script

"""
Stores and manages energy between players
- Held energy (with methods to add/remove energy)
- Charge station energy (with methods to slowly move held energy into charge station)
Centralizes game logic to communicate with other systems such as HUD, CutsceneManager
Stores and manages level progress
- Reference to camera for its position
- Total distance = Final zone position - Initial position
- Level progress = (Final zone position - Camera position) / (Total distance)
Will trigger the win cutscene once enough energy is collected in one of the charge stations
Initialized when game starts (not needed when game is not playing)
Autoloaded script
"""

signal level_entered
signal final_zone_entered
signal player_ready(id: PlayerID)
signal player_win(id: PlayerID)
signal powerup_collected(id: PlayerID)
signal end_cutscene_finished
signal player_mashing_while_held
signal request_charge(charger: ChargingStation, id: PlayerID, delta: float)
signal play_powerup_audio(powerup_type: PowerupManager.PowerupType, position: Vector2)


enum PlayerID {
	PLAYER_1,
	PLAYER_2,
}

const CHARGE_PER_SECOND: float = 10
const WINNING_THRESHOLD: float = 250.0
const OVERCHARGE_CAP: float = 100.0

var winning_player: PlayerID = PlayerID.PLAYER_1

var player_colors: Array[Color] = [Color.WHITE, Color.WHITE]

var _player_points: Vector2 = Vector2.ZERO ## Player points stored as a Vector2.
var _player_won: bool = false

var _active_camera: Camera2D ## Stored reference to current camera used to disable when switching.
var _camera_position: float = 0.0 ## The x position of the current camera's right bound.
var _final_position_x: float = 0.0 ## Final right bound x, passed by the camera on ready
var _total_distance: float = 0.0 ## Total distance to travel, calculated by final - initial
var _remaining_level_progress: float = 0.0 ## The ratio of remaining level to total distance.

@onready var powerup_sound = preload("res://assets/Sound Effects/Powerups/Getbig.ogg")

func _ready() -> void:
	player_win.connect(_on_player_win)
	request_charge.connect(_on_request_charge)
	level_entered.connect(_on_level_entered)
	play_powerup_audio.connect(_on_picked_powerup)

		
## Resets game state to 0.
## All variables are reinitialized to 0 except for _active_camera.
func clear() -> void:
	_player_points = Vector2.ZERO
	_camera_position = 0.0
	_remaining_level_progress = 0.0
	_player_won = false


## Sets the active camera to [param new_camera].
## This disables the current camera and enables [param new_camera].
## Assumes _active_camera is set on world ready.
## @experimental: Incomplete or unnecessary. 
func set_active_camera(new_camera: Camera2D) -> void:
	if _active_camera != null:
		_active_camera.enabled = false
	new_camera.enabled = true
	_active_camera = new_camera


## Sets the score of player with ID [param id] to [param energy]
func set_player_energy(energy: int, id: PlayerID) -> void:
	_player_points[id] = float(energy)


## Increases the score of player with ID [param id] by [param energy]. Returns the change in score
func add_player_energy(energy: float, id: PlayerID) -> float:
	if (_player_points[id] + float(energy) < 0.0):
		var temp = _player_points[id]
		_player_points[id] = 0.0
		return _player_points[id] - temp
	elif (_player_points[id] + float(energy) > WINNING_THRESHOLD + OVERCHARGE_CAP):
		var temp = _player_points[id]
		_player_points[id] = WINNING_THRESHOLD + OVERCHARGE_CAP
		return WINNING_THRESHOLD + OVERCHARGE_CAP - temp
	else:
		_player_points[id] += energy
		return energy


## Decreases the score of player with ID [param id] by [param energy]. Returns the change in score
func remove_player_energy(energy: float, id: PlayerID) -> float:
	if (_player_points[id] - float(energy) < 0.0):
		_player_points[id] = 0.0
		return 0.0
	else:
		_player_points[id] -= energy
		return energy


## Returns the score of player with ID [param id].
func get_player_energy(id: PlayerID) -> float:
	return _player_points[id]

## Sets [member _camera_position] to [param new_camera_pos], called by the camera
## Does not affect the actual camera. Is used for updating the HUD and game state.
func set_camera_pos(new_camera_pos: float) -> void:
	_camera_position = new_camera_pos
	_remaining_level_progress = (_final_position_x - _camera_position) / _total_distance
	if is_zero_approx(_remaining_level_progress):
		final_zone_entered.emit()


# Initializes the camera variables, called by the camera.
func initialize_camera_pos(init_pos: float, final_pos: float) -> void:
	_final_position_x = final_pos
	_total_distance = final_pos - init_pos


## Returns the current level progress of the camera as a ratio.
func get_level_progress() -> float:
	return 1.0 - _remaining_level_progress


## Starts victory sequence
func _on_player_win(_id: PlayerID) -> void:
	if _player_won:
		return
	
	_player_won = true
	winning_player = _id
	SceneManager.change_scene(GameScene.end_cutscene, {
		"pattern": "squares",
	})


func _on_level_entered() -> void:
	clear()


## Give energy to charging station
## @experimental: Needs testing
func _on_request_charge(charger: ChargingStation, id: PlayerID, delta) -> void:
	var charge_exchange = CHARGE_PER_SECOND * delta
	
	if _player_points[id] > WINNING_THRESHOLD:
		charge_exchange *= 2
	elif is_zero_approx(_player_points[id]):
		charge_exchange = 0
	
	charge_exchange = charger.charge_energy(charge_exchange)
	add_player_energy(charge_exchange, id)


func _on_picked_powerup() -> void:
	return
