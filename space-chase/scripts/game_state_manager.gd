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

var _active_camera: Camera2D
var _player_points: Vector2i = Vector2i.ZERO
var _total_distance: float = 0.0
var _camera_pos: float = 0.0
var _level_progress: float = 0.0


func set_active_camera(new_camera: Camera2D) -> void:
	_active_camera.enabled = false
	new_camera.enabled = true
	_active_camera = new_camera


func set_player_energy(energy: int, player: PlayerID) -> void:
	_player_points[player] = energy


func add_player_energy(energy: int, player: PlayerID) -> void:
	_player_points[player] += energy


# Used instead of a camera reference.
# This is called from the camera instead of using camera ref
# in process to update.
func update_camera_pos(new_camera_pos: float) -> void:
	_camera_pos = new_camera_pos


func calculate_victory() -> PlayerID:
	return PlayerID.PLAYER_1 if _player_points[0] > _player_points[1] else PlayerID.PLAYER_2
