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

signal final_zone_entered
signal player_win(id: PlayerID)
signal request_charge(charger: ChargingStation, id: PlayerID, delta: float)

enum PlayerID {
	PLAYER_1,
	PLAYER_2,
}

const CHARGE_PER_TICK = 0.15

var _player_points: Vector2 = Vector2.ZERO ## Player points stored as a Vector2.

var _active_camera: Camera2D ## Stored reference to current camera used to disable when switching.
var _camera_position: float = 0.0 ## The x position of the current camera's right bound.
var _final_position_x: float = 0.0 ## Final right bound x, passed by the camera on ready
var _total_distance: float = 0.0 ## Total distance to travel, calculated by final - initial
var _remaining_level_progress: float = 0.0 ## The ratio of remaining level to total distance.


func _ready() -> void:
	player_win.connect(_on_player_win)
	request_charge.connect(_on_request_charge)


## Resets game state to 0.
## All variables are reinitialized to 0 except for _active_camera.
func clear() -> void:
	_player_points = Vector2i.ZERO
	_camera_position = 0.0
	_remaining_level_progress = 0.0


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


## Increases the score of player with ID [param id] by [param energy]
func add_player_energy(energy: int, id: PlayerID) -> void:
	if (_player_points[id] + float(energy) < 0):
		_player_points[id] = 0.0
	else:
		_player_points[id] += energy


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
	return _remaining_level_progress


## Starts victory sequence
## @experimental: Incomplete
func _on_player_win(id: PlayerID) -> void:
	return


## Give energy to charging station
## @experimental: Needs testing
func _on_request_charge(charger: ChargingStation, id: PlayerID, delta) -> void:
	var charge_exchange = CHARGE_PER_TICK * _player_points[id] * delta
	charge_exchange = charger.charge_energy(charge_exchange)
	add_player_energy(charge_exchange, id)
