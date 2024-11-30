class_name AutoscrollCameraController
extends Camera2D

"""
Manages the camera’s movement mechanics
Horizontal auto scroll
- Stops at the final zone of the level
- Speed up autoscroll by player pushing to the right
"""

## Defines the x position of the push line as a ratio of the
## screen length.
@export_range (0, 1, 0.05) var push_line_ratio: float = 0.0

## Defines the speed at which the camera moves at [member autoscroll_speed]
## units per second.
@export var autoscroll_speed: float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if !enabled:
		pass
	else:
		position.x += autoscroll_speed * delta
