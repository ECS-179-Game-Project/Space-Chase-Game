class_name AutoscrollCameraController
extends Camera2D

"""
Manages the camera’s movement mechanics
Horizontal auto scroll
- Stops at the final zone of the level
- Speed up autoscroll by player pushing to the right
"""
## Stores references to players.
@export var players: Array[Player] = []

## Defines the x position of the push line as a ratio of the
## screen length.
@export_range (0, 1, 0.05) var push_line_ratio: float = 0.0

## Defines the speed at which the camera moves at [member autoscroll_speed]
## units per second.
@export var autoscroll_speed: float = 0.0
## Defines the x where the camera will stop scrolling right.
## Checks the right bound of the camera.
@export var end_zone: float
## Draw the push line.
@export var debug_lines: bool = true


## Stores the length of the viewport with respect to zoom.
var _viewport_length: float = 0.0
## Stores the length of half the viewport with respect to zoom.
var _half_vp_length: float = 0.0
## Stores the position of the push line relative to the center of the camera.
var _push_line_x: float = 0.0


func _ready() -> void:
	_viewport_length = get_viewport_rect().size.x / zoom.x
	_push_line_x = (push_line_ratio - 0.5) * _viewport_length
	_half_vp_length = 0.5 * _viewport_length
	GameStateManager.set_active_camera(self)
	GameStateManager.initialize_camera_pos(global_position.x + _half_vp_length, end_zone)
	

func _physics_process(delta: float) -> void:
	if !enabled:
		pass
	else:
		if debug_lines:
			draw_debug()
			
		var global_push_line_x: float = global_position.x + _push_line_x
		for player in players:
			if player.is_ghost:
				continue
			
			# Push right if player crosses the line
			if player.global_position.x > global_push_line_x:
				global_position.x += player.global_position.x - global_push_line_x
				
			# Move player right if player off screen left
			if player.global_position.x < global_position.x - _half_vp_length:
				player.global_position.x += (global_position.x - _half_vp_length
											- player.global_position.x)
				
		global_position.x += autoscroll_speed * delta
		
		# When the right bound of the camera reaches the end_zone,
		# disable logic for the camera.
		if global_position.x >= end_zone - _half_vp_length:
			global_position.x = end_zone - _half_vp_length
			set_physics_process(false)
		
		GameStateManager.set_camera_pos(global_position.x + _half_vp_length)
		
		
		
func draw_debug() -> void:
	_push_line_x = (push_line_ratio - 0.5) * _viewport_length
	var line_instance = Line2D.new()
	line_instance.add_point(Vector2(_push_line_x, 300))
	line_instance.add_point(Vector2(_push_line_x, -300))
	line_instance.default_color = Color.BLUE
	line_instance.width = 2
	add_child(line_instance)
	await Engine.get_main_loop().physics_frame
	line_instance.queue_free()
	

		
