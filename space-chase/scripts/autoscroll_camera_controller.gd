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

## Defines the width of the speedup zone left of the push line in pixels.
@export var speedup_zone_width: float = 60.0

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
		var global_speedup_line_x: float = global_push_line_x - speedup_zone_width
		for player in players:
			if player.is_ghost:
				continue
			
			var player_pos = player.global_position.x
			
			# Push right if player crosses the line
			if player_pos > global_push_line_x:
				global_position.x += player.global_position.x - global_push_line_x
			
			# Push faster if player is past the speedup line and is moving faster
			# than autoscroll.
			elif player_pos > global_speedup_line_x and player.velocity.x > autoscroll_speed:
				var push_ratio = ((player_pos - global_speedup_line_x) / 
					(global_push_line_x - global_speedup_line_x))
				global_position.x += lerp(0.0, player.velocity.x - autoscroll_speed, push_ratio) * delta
				
				
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
	var speedup_line = _push_line_x - speedup_zone_width
	var line_instance = Line2D.new()
	line_instance.add_point(Vector2(_push_line_x, 300))
	line_instance.add_point(Vector2(_push_line_x, -300))
	line_instance.default_color = Color.BLUE
	line_instance.width = 2
	add_child(line_instance)
	
	var speedline_instance = Line2D.new()
	speedline_instance.add_point(Vector2(speedup_line, 300))
	speedline_instance.add_point(Vector2(speedup_line, -300))
	speedline_instance.default_color = Color.ROYAL_BLUE
	speedline_instance.width = 1
	add_child(speedline_instance)
	
	await Engine.get_main_loop().physics_frame
	line_instance.queue_free()
	speedline_instance.queue_free()
	

		
