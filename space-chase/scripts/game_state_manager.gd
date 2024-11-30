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

enum PlayerID {
	PLAYER_1,
	PLAYER_2,
}


var _active_camera: Camera2D ## Stored reference to current camera used to disable when switching.
var _player_points: Vector2i = Vector2i.ZERO ## Player points stored as an integer Vector2.
var _total_distance: float = 0.0 ## Total distance of the level. Equal to (Final zone position - Initial position).
var _camera_position: float = 0.0 ## The x position of the current camera.
var _level_progress: float = 0.0 ## The ratio of camera position to total distance.

## Resets game state to 0.
## All variables are reinitialized to 0 except for _active_camera.
func clear() -> void:
	_player_points = Vector2i.ZERO
	_total_distance = 0.0
	_camera_position = 0.0
	_level_progress = 0.0


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
	_player_points[id] = energy


## Increases the score of player with ID [param id] by [param energy]
func add_player_energy(energy: int, id: PlayerID) -> void:
	_player_points[id] += energy


## Sets [member _camera_position] to [param new_camera_pos]
## Does not affect the actual camera. Is used for updating the HUD and game state.
func set_camera_pos(new_camera_pos: float) -> void:
	_camera_position = new_camera_pos


## Returns the current level progress of the camera.
func get_level_progress() -> float:
	return _total_distance / _level_progress


## Returns the winning player based on current score.
func get_player_victory() -> PlayerID:
	return PlayerID.PLAYER_1 if _player_points[0] > _player_points[1] else PlayerID.PLAYER_2
